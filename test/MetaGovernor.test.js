// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const utils = require("../scripts/hardhat.utils.js");


const aaveGovAddr = "0xEC568fffba86c094cf06b22134B23074DFE2252c";
const compoundAddr = "0xAAAaaAAAaaaa8FdB04F544F4EEe52939CddCe378";
const uniGovAddr = "0x5e4be8Bc9637f0EAA1A755019e06A68ce081D58F";

describe("MetaGovernor", () => {
    let account;
    let metaGovernor;

    before(async () => {
        [ account ] = await ethers.getSigners();
        metaGovernor = await utils.deployContract("MetaGovernor",
            [
                aaveGovAddr,
                compoundAddr,
                uniGovAddr,
            ]
        );
    });

    it("Should have deployed", async () => {
        expect(metaGovernor.address).to.be.properAddress;
    });
});
