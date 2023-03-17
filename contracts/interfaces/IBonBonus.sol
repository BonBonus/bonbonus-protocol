// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBonBonus {
    struct Provider {
        bool exists;
        bool active;
        uint256 providerType;
        address[] trustedAddresses;
    }

    struct TokenData {
        bool exists;
        bool isProvider;
        uint256 score;
        uint256 birthday;
        mapping(bytes32 => ProviderData) providerData;
    }

    struct ProviderData {
        bool exists;
        uint256 score;
    }

    struct Score {
        bool exists;
        bytes32 provider;
        uint256 score;
    }
}