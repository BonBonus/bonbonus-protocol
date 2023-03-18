// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../interfaces/ICalculateGlobalRating.sol";
import "../token/ERC721/BonBonus.sol";

contract CalculateGlobalRating is
    ICalculateGlobalRating,
    ChainlinkClient,
    AccessControl
{
    using Chainlink for Chainlink.Request;

    BonBonus public bonBonus;

    mapping(bytes32 => RequestStatus) public s_requests;

    bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");

    constructor(BonBonus _bonBonus) {
        setChainlinkToken(0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06);
        setChainlinkOracle(0x71eDDb50c79bA241B0469bb0Ae08E4f8F7dca45E);

        bonBonus = _bonBonus;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function calculateGlobalTokenRating(
        uint256 _token
    ) external onlyRole(CONTRACT_ROLE) returns (bytes32 requestId) {
        require(
            bonBonus.checkTokenExists(_token),
            "ERC721Metadata: The token doesn't exist"
        );

        Chainlink.Request memory req = buildChainlinkRequest(
            "d7a6e9257779464da1440eb5deea8fa0", // job id
            address(this),
            this.fulfillMultipleParameters.selector
        );

        req.addUint("token", _token);

        requestId = sendChainlinkRequest(req, 0);

        s_requests[requestId] = RequestStatus({
            fulfilled: false,
            token: _token,
            globalRating: 0
        });

        return requestId;
    }

    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 _globalRating
    ) public recordChainlinkFulfillment(requestId) {
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].globalRating = _globalRating;

        bonBonus.updateGlobalRating(
            s_requests[requestId].token,
            _globalRating
        );

        emit TokenRatingUpdated(
            requestId,
            s_requests[requestId].token,
             _globalRating
        );
    }

    function withdrawLink() public onlyRole(DEFAULT_ADMIN_ROLE) {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
