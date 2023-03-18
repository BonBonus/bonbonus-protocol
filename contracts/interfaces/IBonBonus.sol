// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBonBonus {
    struct Provider {
        bool exists;
        uint256 providerType;
        address[] trustedAddresses;
    }

    struct TokenData {
        bool exists;
        uint256 finalRating;
        uint256 ratingUpdatedDate;
        uint256 birthday;
        mapping(uint256 => TokenProviderData) providerData;
    }

    struct TokenProviderData {
        bool exists;
        uint256 finalRating;
        uint256 loyaltyPoints;
        uint256[] ratings;
    }
}
