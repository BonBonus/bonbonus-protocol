// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../interfaces/ICalculateProviderRating.sol";
import "../token/ERC721/BonBonus.sol";

contract CalculateProviderRating is
    ICalculateProviderRating,
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

    function calculateProviderTokenRating(
        uint256 _token,
        uint256 _provider
    ) external onlyRole(CONTRACT_ROLE) returns (bytes32 requestId)  {
        require(
            bonBonus.checkTokenExists(_token),
            "ERC721Metadata: The token doesn't exist"
        );

        require(
            bonBonus.checkProviderExists(_provider),
            "Provider doesn't exist"
        );

        Chainlink.Request memory req = buildChainlinkRequest(
            "dda63b140044433fa793942b3d050069", // job id
            address(this),
            this.fulfillMultipleParameters.selector
        );

        req.addUint("token", _token);
        req.addUint("provider", _provider);

        requestId = sendChainlinkRequest(req, 0);

        s_requests[requestId] = RequestStatus({
            fulfilled: false,
            token: _token,
            provider: _provider,
            providerRating: 0
        });

        return requestId;
    }

    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 _providerRating
    ) public recordChainlinkFulfillment(requestId) {
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].providerRating = _providerRating;

        bonBonus.updateProviderRating(
            s_requests[requestId].token,
            s_requests[requestId].provider,
            _providerRating
        );

        emit RatingUpdated(
            requestId,
            s_requests[requestId].token,
            s_requests[requestId].provider,
            _providerRating
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
