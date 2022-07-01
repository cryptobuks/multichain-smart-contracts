// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import "../access/MPCManageable.sol";

contract PriceOracleRouter is MPCManageable {
    mapping(uint256 => uint256) private prices;
    mapping(uint256 => uint256) private decimals;

    event PriceUpdate(uint256 chainID, uint256 price);
    event DecimalsUpdate(uint256 chainID, uint256 decimal);

    constructor(address _mpc) MPCManageable(_mpc) {}

    function setPrice(uint256 chainID, uint256 price) external onlyMPC {
        prices[chainID] = price;
        emit PriceUpdate(chainID, price);
    }

    function getPrice(uint256 chainID) public view returns (uint256) {
        return prices[chainID];
    }

    function setDecimal(uint256 chainID, uint256 decimal) external onlyMPC {
        decimals[chainID] = decimal;
        emit DecimalsUpdate(chainID, decimal);
    }

    function getDecimal(uint256 chainID) public view returns (uint256) {
        return decimals[chainID];
    }

    function getCurrencyInfo(uint256 chainID)
        public
        view
        returns (uint256, uint256)
    {
        return (prices[chainID], decimals[chainID]);
    }
}
