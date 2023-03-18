// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

import "../../interfaces/IBonBonus.sol";
import "../../interfaces/IERC4906.sol";

contract BonBonus is
    IBonBonus,
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IERC4906
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;
    CountersUpgradeable.Counter private _providerIdCounter;

    string private externalURL;

    mapping(uint256 => Provider) public providers;
    mapping(uint256 => TokenData) public tokens;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC721_init("BonBonus", "BONBONUS");
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function safeMint(
        address to,
        uint256 birthday
    ) public onlyRole(MINTER_ROLE) {
        require(
            birthday < block.timestamp,
            "ERC721Metadata: Invalid date"
        );
        require(
           balanceOf(to) == 0,
            "User already have token"
        );

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        tokens[tokenId].exists = true;
        tokens[tokenId].birthday = birthday;
    }

    function addNewProvider(
        uint256 _providerType,
        address[] memory _trustedAddreses
    ) external onlyRole(OPERATOR_ROLE) {
        uint256 providerId = _providerIdCounter.current();
        _providerIdCounter.increment();

        providers[providerId].exists = true;
        providers[providerId].providerType = _providerType;
        providers[providerId].trustedAddresses = _trustedAddreses;
    }

    function getProviderTrustedAddresses(
        uint256 _provider
    ) public view returns (address[] memory) {
        require(providers[_provider].exists, "Provider doesn't exist");

        return providers[_provider].trustedAddresses;
    }

    function getTokenProviderData(
        uint256 _tokenId,
        uint256 _provider
    ) public view returns (TokenProviderData memory) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        return tokens[_tokenId].providerData[_provider];
    }

    function getTokenProviderRatings(
        uint256 _tokenId,
        uint256 _provider
    ) public view returns (uint256[] memory) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        return tokens[_tokenId].providerData[_provider].ratings;
    }


    function getTokenProviderFinalRating(
        uint256 _tokenId,
        uint256 _provider
    ) public view returns (uint256) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        return tokens[_tokenId].providerData[_provider].finalRating;
    }

    function getTokenProviderLoyaltyPoints(
        uint256 _tokenId,
        uint256 _provider
    ) public view returns (uint256) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        return tokens[_tokenId].providerData[_provider].loyaltyPoints;
    }

    function addNewTokenPointByProvider(
        uint256 _tokenId,
        uint256 _provider,
        uint256 _points
    ) external {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");
        require(_points >= 1 && _points <= 5, "Incorrect points amount"); // add checking on integer

        bool flag = false;

        for (uint256 i; i < providers[_provider].trustedAddresses.length; i++) {
            if (providers[_provider].trustedAddresses[i] == msg.sender) {
                flag = true;
            }
        }

        require(flag, "Sender not in trusted addresses");

        tokens[_tokenId].providerData[_provider].exists = true;
        tokens[_tokenId].providerData[_provider].ratings.push(_points);
    }

    function updateTokenLoyaltyPointsByProvider(
        uint256 _tokenId,
        uint256 _provider,
        uint256 _points
    ) external {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        bool flag = false;

        for (uint256 i; i < providers[_provider].trustedAddresses.length; i++) {
            if (providers[_provider].trustedAddresses[i] == msg.sender) {
                flag = true;
            }
        }

        require(flag, "Sender not in trusted addresses");

        tokens[_tokenId].providerData[_provider].exists = true;
        tokens[_tokenId].providerData[_provider].loyaltyPoints = _points;
    }

    function updateGlobalRating(
        uint256 _token,
        uint256 _globalRating
    ) external onlyRole(ORACLE_ROLE) {
        require(
            checkTokenExists(_token),
            "ERC721Metadata: The token doesn't exist"
        );

        tokens[_token].finalRating = _globalRating;
        tokens[_token].ratingUpdatedDate = block.timestamp;

        emit MetadataUpdate(_token);
    }

    function updateProviderRating(
        uint256 _token,
        uint256 _provider,
        uint256 _providerRating
    ) external onlyRole(ORACLE_ROLE) {
        require(
            checkTokenExists(_token),
            "ERC721Metadata: The token doesn't exist"
        );
        require(
            checkProviderExists(_provider),
            "Provider doesnt exist"
        );

        tokens[_token].providerData[_provider].exists = true;
        tokens[_token].providerData[_provider].finalRating = _providerRating;

        emit MetadataUpdate(_token);
    }

    function checkTokenExists(uint256 _token) public view returns (bool) {
        return _exists(_token);
    }

    function checkProviderExists(uint256 _provider) public view returns (bool) {
        return providers[_provider].exists;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        require(
            from == address(0) || to == address(0),
            "This a SBT token. It can't be transferred."
        );

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable,
            IERC165Upgradeable
        )
        returns (bool)
    {
        return
            interfaceId == bytes4(0x49064906) ||
            super.supportsInterface(interfaceId);
    }
}
