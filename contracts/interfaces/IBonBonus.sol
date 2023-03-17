// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBonBonus {
    struct TokenData {
        bool exists;
        bool burned;
        address[] addresses;
        uint256 pistisScore;
        uint256 deFiScore;
        uint256 tradFiScore;
        uint256 personalScore;
        uint256 calculatedDate;
        string name;
        mapping(bytes32 => ProviderData) providerData;
    }

    struct Provider {
        bool exists;
        address[] trustedAddresses;
    }

    struct ProviderData {
        bool exists;
        uint256 score;
        uint256 calculatedDate;
    }
}