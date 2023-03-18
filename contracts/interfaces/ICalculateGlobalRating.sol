// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICalculateGlobalRating {
    struct RequestStatus {
        bool fulfilled;
        uint256 token;
        uint256 globalRating;
    }

    function calculateGlobalTokenRating(
        uint256 token
    ) external returns (bytes32);

    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 globalRating
    ) external;

    function withdrawLink() external;

    event TokenRatingUpdated(
        bytes32 requestId,
        uint256 token,
        uint256 globalRating
    );
}
