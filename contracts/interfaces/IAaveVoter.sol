// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


// https://github.com/aave/governance-v2/blob/master/contracts/interfaces/IAaveGovernanceV2.sol
interface IAaveVoter {

    struct AaveProposal {
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        bool[] withDelegatecalls;
        bytes32 ipfsHash;
    }

    function submitVote(uint256 proposalId, bool support) external;

    function create(
        address executor,
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        bool[] calldata withDelegatecalls,
        bytes32 ipfsHash
  ) external returns (uint256);
}
