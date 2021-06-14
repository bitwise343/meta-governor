const { deployContract } = require('./hardhat.utils');


const deployer = async () => {
    /**
    * @note deployment details:
    *       1. timelock
    *         - constructorArgs: admin, delay
    *       2. uni token
    *         - constructorArgs: account, minter, mintingAllowedAfter
    *       3. governoralpha
    *         - constructorArgs: timelock, uni
    */
    const [ account1 ] = await hre.ethers.getSigners();

    const admin = account1.address;
    const delay = 120; // 2 minutes
    const uniTimelock = await deployContract("UniTimelock", [admin, delay]);

    const account = account1.address;
    const minter = account1.address;
    const mintingAllowedAfter = 1623374762 + 86400 * 7; // ~ 17 june 2021
    const uniToken = await deployContract(
        "Uni", [account, minter, mintingAllowedAfter]
    );

    const timelock = uniTimelock.address;
    const uni = uniToken.address;
    const uniGovernorAlpha = await deployContract(
        "UniGovernorAlpha", [timelock, uni]
    );
}

try {
    deployer();
} catch(err) {
  console.error(err);
}
