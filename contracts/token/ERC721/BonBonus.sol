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

    string public contractURI;
    string private tokenImageRenderURL;

    mapping(uint256 => Provider) public providers;
    mapping(uint256 => TokenData) public tokens;
    mapping(address => uint256[]) private addressProviders;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _contractURI, string memory _tokenImageRenderURL) public initializer {
        __ERC721_init("BonBonus", "BONBONUS");
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        contractURI = _contractURI;
        tokenImageRenderURL = _tokenImageRenderURL;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function safeMint(
        address to,
        uint256 birthday
    ) public {
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
        address trustedAddress
    ) external onlyRole(OPERATOR_ROLE) {
        uint256 providerId = _providerIdCounter.current();
        _providerIdCounter.increment();

        providers[providerId].exists = true;
        providers[providerId].providerType = _providerType;
        providers[providerId].trustedAddress = trustedAddress;

        addressProviders[trustedAddress].push(providerId);
    }

    function getProviderTrustedAddresses(
        uint256 _provider
    ) public view returns (address) {
        require(providers[_provider].exists, "Provider doesn't exist");

        return providers[_provider].trustedAddress;
    }

    function getAddressProviders(
        address _wallet
    ) public view returns (uint256[] memory) {

        return addressProviders[_wallet];
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

    function getTokenParticipatingProviders(
        uint256 _tokenId
    ) public view returns (uint256[] memory) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");

        return tokens[_tokenId].participatingProviders;
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
    ) external onlyRole(ORACLE_ROLE) {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");
        require(_points >= 1 && _points <= 5, "Incorrect points amount"); // add checking on integer

        tokens[_tokenId].providerData[_provider].exists = true;
        tokens[_tokenId].providerData[_provider].ratings.push(_points);

        bool providerFlag = false;

        for (uint256 i; i < tokens[_tokenId].participatingProviders.length; i++) {
            if (tokens[_tokenId].participatingProviders[i] == _provider) {
                providerFlag = true;
            }
        }

        if (!providerFlag) {
            tokens[_tokenId].participatingProviders.push(_provider);
        }
    }

    function updateTokenLoyaltyPointsByProvider(
        uint256 _tokenId,
        uint256 _provider,
        uint256 _points
    ) external {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(providers[_provider].exists, "Provider doesn't exist");

        require(providers[_provider].trustedAddress == msg.sender, "Sender not in trusted addresses");

        tokens[_tokenId].providerData[_provider].exists = true;
        tokens[_tokenId].providerData[_provider].loyaltyPoints = _points;
    }

    function updateTokenRating(
        uint256 _token,
        uint256 _provider,
        uint256 _providerRating,
        uint256 _globalRating
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
        tokens[_token].globalRating = _globalRating;
        tokens[_token].ratingUpdatedDate = block.timestamp;

        emit MetadataUpdate(_token);
    }

    function checkTokenExists(uint256 _token) public view returns (bool) {
        return _exists(_token);
    }

    function checkProviderExists(uint256 _provider) public view returns (bool) {
        return providers[_provider].exists;
    }

    function updateTokenImageRenderURL(string memory _newTokenImageRenderURL)
    external
    onlyRole(OPERATOR_ROLE)
    {
        tokenImageRenderURL = _newTokenImageRenderURL;
    }

    function setContractURI(string memory _contractURI)
    external
    onlyRole(OPERATOR_ROLE)
    {
        contractURI = _contractURI;
    }

    function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
    {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");

        bytes memory data = abi.encodePacked(
            baseSection(_tokenId),
            attributesSection(_tokenId)
        );
        return
        string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64Upgradeable.encode(data)
            )
        );
    }

    function baseSection(uint256 _tokenId) private view returns (bytes memory) {
        return
        abi.encodePacked(
            "{",
            '"description":"BonBonus token",',
            '"name": "',
            string.concat("BonBonus  #", _tokenId.toString(), " token"),
            '",',
            '"image":"',
            tokenImageRenderURL,
            _tokenId.toString(),
            '",'
        );
    }

    function attributesSection(uint256 _tokenId)
    private
    view
    returns (bytes memory)
    {
        return
        abi.encodePacked(
            '"attributes":',
            "[{",
            '"trait_type":"Global rating","value":',
            tokens[_tokenId].globalRating.toString(),
            "",
            "},{",
            '"display_type":"date","trait_type":"Birthday","value":',
            tokens[_tokenId].birthday.toString(),
            "",
            "},{",
            '"display_type":"date","trait_type":"Updated date","value":',
            tokens[_tokenId].ratingUpdatedDate.toString(),
            "",
            "}]}"
        );
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
