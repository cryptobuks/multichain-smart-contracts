// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import "../access/MPCManageable.sol";
import "../interfaces/PriceOracleInterface.sol";

contract PriceOracleRouter is MPCManageable, PriceOracleInterface {
    // managers of price update
    mapping(address => bool) private _managers;
    // currency details
    mapping(uint256 => CurrencyInfo) private _currencyInfos;
    // decimal of price
    uint256 public _decimal;

    struct CurrencyInfo {
        uint112 price;
        uint64 decimal;
        uint64 lateUpdateTime;
    }

    constructor(
        address mpc_,
        uint256 decimal_,
        address[] memory managers_
    ) MPCManageable(mpc_) {
        _decimal = decimal_;
        for (uint256 i = 0; i < managers_.length; i++) {
            require(!_managers[managers_[i]], "manager exists");
            require(
                managers_[i] != address(0),
                "manager must not equal address zero"
            );
            _managers[managers_[i]] = true;
        }
    }

    modifier onlyManager() {
        require(_managers[msg.sender], "only manager");
        _;
    }

    function setManagersBatch(
        address[] calldata managers,
        bool[] calldata availities
    ) external onlyManager {
        require(
            managers.length == availities.length,
            "managers length must equals availities length"
        );
        for (uint256 i = 0; i < managers.length; i++) {
            setManager(managers[i], availities[i]);
        }
    }

    function setManager(address manager, bool availity) public onlyMPC {
        require(_managers[manager] != availity, "Not change anything");
        _managers[manager] = availity;
    }

    function setPricesBatch(
        uint256[] calldata chainIDs,
        uint112[] calldata prices
    ) external onlyManager {
        require(
            chainIDs.length == prices.length,
            "chainIDs length must equals prices length"
        );
        for (uint256 i = 0; i < chainIDs.length; i++) {
            setPrice(chainIDs[i], prices[i]);
        }
    }

    function setPrice(uint256 chainID, uint112 price) public onlyManager {
        CurrencyInfo storage currencyInfo = _currencyInfos[chainID];
        currencyInfo.price = price;
        currencyInfo.lateUpdateTime = uint64(block.timestamp);
        emit PriceUpdate(chainID, price);
    }

    function getPrice(uint256 chainID) external view returns (uint256 price) {
        return _currencyInfos[chainID].price;
    }

    function setDecimal(uint256 chainID, uint64 decimal) external onlyManager {
        CurrencyInfo storage currencyInfo = _currencyInfos[chainID];
        currencyInfo.decimal = decimal;
        currencyInfo.lateUpdateTime = uint64(block.timestamp);
        emit DecimalsUpdate(chainID, decimal);
    }

    function getDecimal(uint256 chainID)
        external
        view
        returns (uint256 decimal)
    {
        return _currencyInfos[chainID].decimal;
    }

    function initCurrencyInfo(
        uint256 chainID,
        uint112 price,
        uint64 decimal
    ) external onlyManager {
        CurrencyInfo storage currencyInfo = _currencyInfos[chainID];
        currencyInfo.price = price;
        currencyInfo.decimal = decimal;
        currencyInfo.lateUpdateTime = uint64(block.timestamp);
        emit InitCurrencyInfo(chainID, price, decimal);
    }

    function getCurrencyInfo(uint256 chainID)
        external
        view
        returns (
            uint256 price,
            uint256 decimal,
            uint256 lastUpdateTime
        )
    {
        return (
            _currencyInfos[chainID].price,
            _currencyInfos[chainID].decimal,
            _currencyInfos[chainID].lateUpdateTime
        );
    }
}
