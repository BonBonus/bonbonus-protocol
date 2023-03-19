import { ethers, upgrades, run } from 'hardhat';

import { DevLinks } from '../../../../arguments/development/consts';

async function main() {
  const BonBonusFactory = await ethers.getContractFactory('BonBonus');
  const bonBonus = await upgrades.deployProxy(
    BonBonusFactory,
    [
      DevLinks.BONBONUS_TOKEN_CONTRACT_URI,
      DevLinks.BONBONUS_TOKEN_IMAGE_RENDER,
    ],
    {
      kind: 'uups',
    },
  );

  await bonBonus.deployed();
  console.log('BonBonus -> deployed to address:', bonBonus.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        bonBonus.address,
      ),
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
