import hre from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const UpdateRatingFactory = await hre.ethers.getContractFactory(
    'UpdateRating',
  );
  const updateRating = await UpdateRatingFactory.deploy(
    DevContractsAddresses.BONBONUS,
    DevContractsAddresses.CALCULATE_GLOBAL_RATING,
    DevContractsAddresses.CALCULATE_PROVIDER_RATING,
  );

  await updateRating.deployed();
  console.log('updateRating -> deployed to address:', updateRating.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: updateRating.address,
      constructorArguments: [
        DevContractsAddresses.BONBONUS,
        DevContractsAddresses.CALCULATE_GLOBAL_RATING,
        DevContractsAddresses.CALCULATE_PROVIDER_RATING,
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
