import { ethers, run } from 'hardhat';

async function main() {
  const [owner] = await ethers.getSigners();

  const ChainlinkOperatorFactory = await ethers.getContractFactory('Operator');
  const chainlinkOperator = await ChainlinkOperatorFactory.deploy(
    '0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06',
    owner.address,
  );

  await chainlinkOperator.deployed();
  console.log(
    'Chainlik Operator -> deployed to address:',
    chainlinkOperator.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: chainlinkOperator.address,
      contract: 'contracts/oracle/Operator:Operator',
      constructorArguments: [
        '0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06',
        owner.address,
      ],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
