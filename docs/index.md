# Solidity API

## CalculateTokenRating

### bonBonus

```solidity
contract BonBonus bonBonus
```

### RequestStatus

```solidity
struct RequestStatus {
  bool fulfilled;
  uint256 token;
  uint256 provider;
  uint256 providerRating;
  uint256 globalRating;
}
```

### RatingUpdated

```solidity
event RatingUpdated(bytes32 requestId, uint256 token, uint256 provider, uint256 providerRating, uint256 globalRating)
```

### s_requests

```solidity
mapping(bytes32 => struct CalculateTokenRating.RequestStatus) s_requests
```

### constructor

```solidity
constructor(contract BonBonus _bonBonus) public
```

### updateTokenRating

```solidity
function updateTokenRating(uint256 _token, uint256 _provider, uint256 _rating) external returns (bytes32 requestId)
```

### fulfillMultipleParameters

```solidity
function fulfillMultipleParameters(bytes32 requestId, uint256 _providerRating, uint256 _globalRating) public
```

### withdrawLink

```solidity
function withdrawLink() public
```

## IBonBonus

### Provider

```solidity
struct Provider {
  bool exists;
  uint256 providerType;
  address trustedAddress;
}
```

### TokenData

```solidity
struct TokenData {
  bool exists;
  uint256 globalRating;
  uint256 ratingUpdatedDate;
  uint256 birthday;
  mapping(uint256 => struct IBonBonus.TokenProviderData) providerData;
  uint256[] participatingProviders;
}
```

### TokenProviderData

```solidity
struct TokenProviderData {
  bool exists;
  uint256 finalRating;
  uint256 loyaltyPoints;
  uint256[] ratings;
}
```

## IERC4906

### MetadataUpdate

```solidity
event MetadataUpdate(uint256 _tokenId)
```

_This event emits when the metadata of a token is changed.
So that the third-party platforms such as NFT market could
timely update the images and related attributes of the NFT._

### BatchMetadataUpdate

```solidity
event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId)
```

_This event emits when the metadata of a range of tokens is changed.
So that the third-party platforms such as NFT market could
timely update the images and related attributes of the NFTs._

## BonBonus

### contractURI

```solidity
string contractURI
```

### providers

```solidity
mapping(uint256 => struct IBonBonus.Provider) providers
```

### tokens

```solidity
mapping(uint256 => struct IBonBonus.TokenData) tokens
```

### OPERATOR_ROLE

```solidity
bytes32 OPERATOR_ROLE
```

_Roles definitions_

### ORACLE_ROLE

```solidity
bytes32 ORACLE_ROLE
```

### UPGRADER_ROLE

```solidity
bytes32 UPGRADER_ROLE
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(string _contractURI, string _tokenImageRenderURL) public
```

### safeMint

```solidity
function safeMint(address to, uint256 birthday) public
```

### addNewProvider

```solidity
function addNewProvider(uint256 _providerType, address trustedAddress) external
```

### getProviderTrustedAddresses

```solidity
function getProviderTrustedAddresses(uint256 _provider) public view returns (address)
```

### getAddressProviders

```solidity
function getAddressProviders(address _wallet) public view returns (uint256[])
```

### getTokenProviderData

```solidity
function getTokenProviderData(uint256 _tokenId, uint256 _provider) public view returns (struct IBonBonus.TokenProviderData)
```

### getTokenProviderRatings

```solidity
function getTokenProviderRatings(uint256 _tokenId, uint256 _provider) public view returns (uint256[])
```

### getTokenParticipatingProviders

```solidity
function getTokenParticipatingProviders(uint256 _tokenId) public view returns (uint256[])
```

### getTokenProviderFinalRating

```solidity
function getTokenProviderFinalRating(uint256 _tokenId, uint256 _provider) public view returns (uint256)
```

### getTokenProviderLoyaltyPoints

```solidity
function getTokenProviderLoyaltyPoints(uint256 _tokenId, uint256 _provider) public view returns (uint256)
```

### addNewTokenPointByProvider

```solidity
function addNewTokenPointByProvider(uint256 _tokenId, uint256 _provider, uint256 _points) external
```

### updateTokenLoyaltyPointsByProvider

```solidity
function updateTokenLoyaltyPointsByProvider(uint256 _tokenId, uint256 _provider, uint256 _points) external
```

### updateTokenRating

```solidity
function updateTokenRating(uint256 _token, uint256 _provider, uint256 _providerRating, uint256 _globalRating) external
```

### checkTokenExists

```solidity
function checkTokenExists(uint256 _token) public view returns (bool)
```

### checkProviderExists

```solidity
function checkProviderExists(uint256 _provider) public view returns (bool)
```

### updateTokenImageRenderURL

```solidity
function updateTokenImageRenderURL(string _newTokenImageRenderURL) external
```

### setContractURI

```solidity
function setContractURI(string _contractURI) external
```

### tokenURI

```solidity
function tokenURI(uint256 _tokenId) public view returns (string)
```

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address newImplementation) internal
```

_Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
{upgradeTo} and {upgradeToAndCall}.

Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.

```solidity
function _authorizeUpgrade(address) internal override onlyOwner {}
```_

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

