// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

interface PriceOracleInterface {
    event PriceUpdate(uint256 chainID, uint256 price);
    event DecimalsUpdate(uint256 chainID, uint256 decimal);
    event InitCurrencyInfo(uint256 chainID, uint256 price, uint256 decimal);

    function setPrice(uint256 chainID, uint128 price) external;

    function getPrice(uint256 chainID) external view returns (uint256 price);

    function setDecimal(uint256 chainID, uint64 decimal) external;

    function getDecimal(uint256 chainID)
        external
        view
        returns (uint256 decimal);

    function initCurrencyInfo(
        uint256 chainID,
        uint128 price,
        uint64 decimal
    ) external;

    function getCurrencyInfo(uint256 chainID)
        external
        view
        returns (
            uint256 price,
            uint256 decimal,
            uint256 lastUpdateTime
        );
}
