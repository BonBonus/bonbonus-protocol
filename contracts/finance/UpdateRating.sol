// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "../token/ERC721/BonBonus.sol";
import "./CalculateGlobalRating.sol";
import "./CalculateProviderRating.sol";

contract UpdateRating is AccessControl {

    BonBonus public bonBonus;
    CalculateGlobalRating public calculateGlobalRating;
    CalculateProviderRating public calculateProviderRating;

    constructor(BonBonus _bonBonus, CalculateGlobalRating _calculateGlobalRating, CalculateProviderRating _calculateProviderRating) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        bonBonus = _bonBonus;
        calculateGlobalRating = _calculateGlobalRating;
        calculateProviderRating = _calculateProviderRating;
    }


    function addTokenProviderRating(uint256 _token, uint256 _provider, uint256 _rating) external {
        require(
            bonBonus.checkTokenExists(_token),
            "ERC721Metadata: The token doesn't exist"
        );
        require(
            bonBonus.checkProviderExists(_provider),
            "Provider doesn't exist"
        );

        bonBonus.addNewTokenPointByProvider(_token, _provider, _rating);

        calculateProviderRating.calculateProviderTokenRating(_token, _provider);
        calculateGlobalRating.calculateGlobalTokenRating(_token);
    }
}