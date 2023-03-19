import hre from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const CalculateTokenRatingFactory = await hre.ethers.getContractFactory(
    'CalculateTokenRating',
  );
  const calculateTokenRating = await CalculateTokenRatingFactory.deploy(
    DevContractsAddresses.BONBONUS,
  );

  await calculateTokenRating.deployed();
  console.log(
    'calculateTokenRating -> deployed to address:',
    calculateTokenRating.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: calculateTokenRating.address,
      constructorArguments: [DevContractsAddresses.BONBONUS],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
