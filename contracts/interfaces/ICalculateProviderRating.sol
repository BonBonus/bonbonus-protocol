// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICalculateProviderRating {
    struct RequestStatus {
        bool fulfilled;
        uint256 token;
        uint256 provider;
        uint256 providerRating;
    }

    function calculateProviderTokenRating(
        uint256 token,
        uint256 provider
    ) external returns (bytes32);

    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 providerRating
    ) external;

    function withdrawLink() external;

    event RatingUpdated(
        bytes32 requestId,
        uint256 token,
        uint256 provider,
        uint256 providerRating
    );
}
