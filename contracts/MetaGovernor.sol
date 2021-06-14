// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IAaveVoter.sol";
import "./interfaces/ICompoundVoter.sol";
import "./interfaces/IUniVoter.sol";

contract MetaGovernor {

    event AdminChanged(address indexed admin, bool oldStatus, bool newStatus);

    event AaveProposal(uint256 indexed proposalId);
    event CompoundProposal(uint256 indexed proposalId);
    event UniProposal(uint256 indexed proposalId);

    event AaveVote(uint256 indexed proposalId, bool support);
    event CompoundVote(uint256 indexed proposalId, uint8 support);
    event UniVote(uint256 indexed proposalId, bool support);

    IAaveVoter private _aave;
    ICompoundVoter private _compound;
    IUniVoter private _uni;

    mapping (address => bool) private _isAdmin;

    constructor(address aave_, address compound_, address uni_) {
        _isAdmin[msg.sender] = true;
        _aave = IAaveVoter(aave_);
        _compound = ICompoundVoter(compound_);
        _uni = IUniVoter(uni_);
    }

    function isAdmin(address account) public view returns (bool) {
        return _isAdmin[account];
    }

    function changeAdminStatus(address account, bool status) public onlyAdmin {
        bool oldStatus = _isAdmin[account];
        require(oldStatus != status, 'Failed: no change');
        _isAdmin[account] = status;
        emit AdminChanged(account, oldStatus, status);
    }

    function aave() public view returns (address) {
        return address(_aave);
    }

    function compound() public view returns (address) {
        return address(_compound);
    }

    function uni() public view returns (address) {
        return address(_uni);
    }

    function aaveVote(uint256 proposalId, bool support) public onlyAdmin {
        _aave.submitVote(proposalId, support);
        emit AaveVote(proposalId, support);
    }

    function aaveCreate(
        address executor,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) public onlyAdmin returns (uint256) {
        uint256 proposalId = _aave.create(
            executor,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
        emit AaveProposal(proposalId);
        return proposalId;
    }

    function compoundCastVote(
        uint256 proposalId, uint8 support
    ) public onlyAdmin {
        _compound.castVote(proposalId, support);
        emit CompoundVote(proposalId, support);
    }

    function compoundCastVoteWithReason(
        uint256 proposalId, uint8 support, string memory reason
    ) public onlyAdmin {
        _compound.castVoteWithReason(proposalId, support, reason);
        emit CompoundVote(proposalId, support);
    }

    function compoundPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin returns (uint256) {
        uint256 proposalId = _compound.propose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        emit CompoundProposal(proposalId);
        return proposalId;
    }

    function uniCastVote(uint256 proposalId, bool support) public onlyAdmin {
        _uni.castVote(proposalId, support);
        emit UniVote(proposalId, support);
    }

    function uniPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin returns (uint256) {
        uint256 proposalId = _uni.propose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        emit UniProposal(proposalId);
        return proposalId;
    }

    modifier onlyAdmin() {
        require(_isAdmin[msg.sender], 'Failed: not admin');
        _;
    }
}
