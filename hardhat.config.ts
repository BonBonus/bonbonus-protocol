import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
import 'dotenv/config';

const { NETWORK, API_URL, PRIVATE_KEY, BSCSCAN_API_KEY } = process.env;

if (!NETWORK || !API_URL || !PRIVATE_KEY || !BSCSCAN_API_KEY) {
    throw new Error('Not all variables are specified in the env file!');
}

if (!['local', 'bsctestnet'].includes(NETWORK)) {
    throw new Error('Network not supported!');
}

export default {
    solidity: {
        compilers: [
            {
                version: '0.8.19',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
        overrides: {
            'contracts/token/ERC721/BonBonus.sol': {
                version: '0.8.19',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        },
    },
    defaultNetwork: NETWORK,
    networks: {
        local: {
            url: 'http://127.0.0.1:8545',
            accounts: [
                '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
                '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
                '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a',
                '0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6',
            ], // Just for the test. Do not use these keys in public networks!
        },
        bsctestnet: {
            url: API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
    },
    bscscan: {
        apiKey: BSCSCAN_API_KEY,
    },
    typechain: {
        outDir: 'types',
        target: 'ethers-v5',
    },
    gasReporter: {
        currency: 'USD',
        coinmarketcap: 'test',
        enabled: true,
        token: 'MATIC',
        gasPriceApi:
            'https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice',
    },
};