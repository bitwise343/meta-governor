// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


// https://github.com/Uniswap/governance/blob/master/contracts/GovernorAlpha.sol
interface IUniVoter {

    struct UniProposal {
        uint256 uniNonce;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        string description;
    }

    function castVote(uint proposalId, bool support) external;

    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
}
