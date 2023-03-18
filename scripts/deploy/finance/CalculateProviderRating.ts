import hre from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const CalculateProviderRatingFactory = await hre.ethers.getContractFactory(
    'CalculateProviderRating',
  );
  const calculateProviderRating = await CalculateProviderRatingFactory.deploy(
    DevContractsAddresses.BONBONUS,
  );

  await calculateProviderRating.deployed();
  console.log(
    'calculateProviderRating -> deployed to address:',
    calculateProviderRating.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: calculateProviderRating.address,
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
