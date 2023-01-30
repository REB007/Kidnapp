pragma solidity ^0.8.0;

import "./KDNP.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface StableToken {
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function balanceOf(address guy) external view returns (uint);
}

contract RewardPool is Context{
    StableToken _stableCoin;
    KDNP _kdnp;

    mapping(uint256 => uint256) _totalSupply;

    constructor(address stableTokenContract, address kdnpContract){
        _stableCoin = StableToken(stableTokenContract);
        _kdnp = KDNP(kdnpContract);
    }

    function updatePool() public {
        _totalSupply[_kdnp.getCurrentWeekKDNP()] = _stableCoin.balanceOf(address(this));
    }

    function claimPoolShare() public {
        uint256 week = _kdnp.getLastWeekKDNP();
        uint256 amount =  _totalSupply[week] * _kdnp.balanceOf(_msgSender(), week) / _kdnp.getTotalSupply(week);
        _stableCoin.transfer(_msgSender(), amount);
        _kdnp.burn(_msgSender(), amount);
        updatePool();
    }
}