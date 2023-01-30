pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Targets is ERC721URIStorage, Ownable {
    address _marketplace;
    address _minter; 

    uint256 _counter;

    struct TargetInfos {
        string targetName;

        uint256 targetRank; //kstage
        uint256 coeff;

        uint256 nextRansomPrice;
        uint256 oldRansomPrice;

        uint256 lastAbducted;
        uint256 coolDownTime;

        address currentAbducter;
    }

    mapping(uint256 => TargetInfos) private _targetInfos;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_){
        _counter = 0;
    }

    function setMarketPlace(address marketAddress) public onlyOwner {
        _marketplace = marketAddress;
    }

    function setMinter(address minter) public onlyOwner {
        _minter = minter;
    }

    function getTargetInfos(uint256 tokenId) public view returns(TargetInfos memory){
        return _targetInfos[tokenId];
    }

    function kidnapp(uint256 tokenId, address kidnapper) public {
        TargetInfos memory ti = _targetInfos[tokenId];
        _transfer(ti.currentAbducter, kidnapper, tokenId);
        uint256 rank = ti.targetRank++;
        ti.oldRansomPrice = ti.nextRansomPrice;
        ti.nextRansomPrice = getNewRansomPrice(ti.coeff, rank);
        ti.lastAbducted = block.timestamp;
        ti.currentAbducter = kidnapper;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override { 
        require(_msgSender() == _marketplace, "transfer can only take place when kidnapped");
        super._transfer(from, to, tokenId);
    }

    function getNewRansomPrice(uint256 rank, uint256 coeff) public pure returns(uint256){
        return coeff * rank * rank; // formule prix 120%
    }

    function mint(address to, string memory name, uint256 rank, uint coeff, string memory metadata) public {
        require(_msgSender() == _minter, "");
        _counter++;
        super._mint(to, _counter);
        _targetInfos[_counter] = TargetInfos(name, rank, coeff, getNewRansomPrice(rank+1, coeff), 0, block.timestamp, 0, to);
    }
}