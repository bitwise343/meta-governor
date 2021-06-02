// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


// https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/GovernorBravoDelegate.sol
interface ICompoundVoter {

    struct CompoundProposal {
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        string description;
    }

    function castVote(uint proposalId, uint8 support) external;

    function castVoteWithReason(
        uint proposalId, uint8 support, string memory reason
    ) external;

    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
}
