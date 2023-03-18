import hre from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const CalculateGlobalRatingFactory = await hre.ethers.getContractFactory(
    'CalculateGlobalRating',
  );
  const calculateGlobalRating = await CalculateGlobalRatingFactory.deploy(
    DevContractsAddresses.BONBONUS,
  );

  await calculateGlobalRating.deployed();
  console.log(
    'calculateGlobalRating -> deployed to address:',
    calculateGlobalRating.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: calculateGlobalRating.address,
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
