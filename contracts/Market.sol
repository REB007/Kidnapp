pragma solidity ^0.8.0;

import "./Targets.sol";
import "./KDNP.sol";
import "./RewardPool.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Marketplace is Context, Ownable {
    StableToken _stableCoin;
    Targets _targets;
    KDNP _kdnp;
    RewardPool _rewardPool;

    address _teamSplitter;

    uint256 poolShare = 25; //in %
    uint256 teamShare = 25;
    uint256 playerShare = 50;

    mapping(address => uint256) _totalKidnappings;

    constructor(
        address stableTokenContract, 
        address targetsContract, 
        address kdnpContract,
        address rewardPoolAddress,
        address teamSplitterAddress
    ){
        _stableCoin = StableToken(stableTokenContract);
        _targets = Targets(targetsContract);
        _kdnp = KDNP(kdnpContract);
        _rewardPool = RewardPool(rewardPoolAddress);
        _teamSplitter = teamSplitterAddress;
    }

    function getKDNPAmount(uint256 kStage) private view returns(uint256 kdnp){
        kdnp = 10; // base reward per kidnaping 
        kdnp += kStage; // kstage bonus

        // ACHIEVEMENTS: 10 per 10 kidnapings, 100 per 100, 1k per 1k, 10k per 10k 
        if(_totalKidnappings[_msgSender()] % 10000 == 0) kdnp += 10000;
        else if(_totalKidnappings[_msgSender()] % 1000 == 0) kdnp += 1000;
        else if(_totalKidnappings[_msgSender()] % 100 == 0) kdnp += 100;
        else if(_totalKidnappings[_msgSender()] % 10 == 0) kdnp += 10;
        else if(_totalKidnappings[_msgSender()] == 1) kdnp += 10;

        //ADD EVENTS
    }

    function kidnapp(uint256 tokenid) public {
        Targets.TargetInfos memory target = _targets.getTargetInfos(tokenid);

        uint256 pool = (target.nextRansomPrice - target.oldRansomPrice) * poolShare/100;
        uint256 team = (target.nextRansomPrice - target.oldRansomPrice) * teamShare/100;
        uint256 player = target.oldRansomPrice + (target.nextRansomPrice - target.oldRansomPrice) * playerShare/100;

        _stableCoin.transferFrom(_msgSender(), address(_rewardPool), pool);
        _rewardPool.updatePool();
        _stableCoin.transferFrom(_msgSender(), _teamSplitter, team);
        _stableCoin.transferFrom(_msgSender(), target.currentAbducter, player);

        _targets.kidnapp(tokenid, _msgSender());

        _kdnp.mint(_msgSender(), getKDNPAmount(target.targetRank)); 
    }
}