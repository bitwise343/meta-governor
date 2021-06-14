const utils = require('./hardhat.utils.js');

const aaveGovAddr = "0xEC568fffba86c094cf06b22134B23074DFE2252c";
const compoundGovAddr = "0xAAAaaAAAaaaa8FdB04F544F4EEe52939CddCe378";
const uniGovAddr = "0x5e4be8Bc9637f0EAA1A755019e06A68ce081D58F";

const deployer = async () => {
    const [ account1 ] = await hre.ethers.getSigners();
    const governor = await utils.deployContract("MetaGovernor",
        [
            aaveGovAddr,
            compoundGovAddr,
            uniGovAddr
        ]
    );
}

try {
    deployer();
} catch(err) {
  console.error(err);
}
