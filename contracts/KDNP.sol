pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KDNP is ERC1155, Ownable {
    address _marketplace;
    address _rewardPool;

    uint256 WEEK = 7 * 24 * 60 * 60;
    uint256 UNIX_2022 = 1640995200;

    mapping(uint256 => uint256) _totalMintedSupply;

    constructor(string memory uri_) ERC1155(uri_){}

    function setMarketPlace(address marketAddress) public onlyOwner {
        _marketplace = marketAddress;
    }

    //-------------------- TimeUtils ----------------------
    function getYearInSec(uint256 year) public pure returns (uint256) {
        uint256 length = ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) ? 365 : 366;
        return length * 24 * 60 * 60;
    }

    function getYear(uint256 timestamp) public view returns (uint256 year) {
        uint256 temp = timestamp - UNIX_2022;
        year = 2022 - 1;
        while(temp > 0) {
            year += 1;
            temp -= getYearInSec(year) ;
        }
    }

    function getWeekKDNP(uint256 timestamp) public view returns(uint256 Week){
        uint256 year = getYear(timestamp);
        uint256 weekNumber = (timestamp % (getYearInSec(year)))/(WEEK);
        Week = weekNumber * 100 + (year - 2000);
    }

    function getCurrentWeekKDNP() public view returns(uint256){
        return getWeekKDNP(block.timestamp);
    }

    function getLastWeekKDNP() public view returns(uint256 lastWeek){
        return getWeekKDNP(block.timestamp - WEEK);
    }
    //----------------------------------------------------

    function getTotalSupply(uint256 week) public view returns(uint256 supply){
        supply = _totalMintedSupply[week];
    }

    function mint(address to, uint256 amount) public {
        require(_msgSender() == _marketplace, "only MarketPlace can mint KDNP");
        uint256 week = getCurrentWeekKDNP();
        super._mint(to, week, amount, bytes(""));
        _totalMintedSupply[week] += amount;
    }

    function burn(address to, uint256 amount) public {
        require(_msgSender() == _marketplace, "only RewardPool can burn KDNP");
        super._burn(to, getLastWeekKDNP(), amount);
    }
}