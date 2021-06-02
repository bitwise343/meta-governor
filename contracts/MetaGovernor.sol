// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IAaveVoter.sol";
import "./interfaces/ICompoundVoter.sol";
import "./interfaces/IUniVoter.sol";

contract MetaGovernor {

    event AdminChanged(address indexed admin, bool oldStatus, bool newStatus);

    event AaveCommitment(
        uint256 indexed aaveNonce,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        bool[] withDelegateCalls,
        bytes32 ipfsHash
    );

    event CompoundCommitment(
        uint256 indexed compNonce,
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        string description
    );

    event UniCommitment(
        uint256 indexed uniNonce,
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        string description
    );

    event AaveProposal(uint256 indexed proposalId);
    event CompoundProposal(uint256 indexed proposalId);
    event UniProposal(uint256 indexed proposalId);

    event AaveVote(uint256 indexed proposalId, bool support);
    event CompoundVote(uint256 indexed proposalId, uint8 support);
    event UniVote(uint256 indexed proposalId, bool support);

    IAaveVoter private _aave;
    ICompoundVoter private _compound;
    IUniVoter private _uni;

    uint256 private _delayPeriod;

    uint256 private _aaveNonce;
    uint256 private _compoundNonce;
    uint256 private _uniNonce;

    mapping (address => bool) private _isAdmin;

    mapping (bytes32 => uint256) private _aaveCommitment;
    mapping (bytes32 => uint256) private _compoundCommitment;
    mapping (bytes32 => uint256) private _uniCommitment;

    constructor(address aave_, address compound_, address uni_) {
        _isAdmin[msg.sender] = true;
        _aave = IAaveVoter(aave_);
        _compound = ICompoundVoter(compound_);
        _uni = IUniVoter(uni_);
        _delayPeriod = 3 days;
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

    function delayPeriod() public view returns (uint256) {
        return _delayPeriod;
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
        bytes32 commitmentId = _hashAaveProposal(
            _aaveNonce,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
        uint256 commitmentBlock = _aaveCommitment[commitmentId];
        require(commitmentBlock > 0, "Failed: not precommited");
        require(
            block.number > commitmentBlock + _delayPeriod,
            "Failed: delay not passed"
        );
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

    function aaveCommit(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) public onlyAdmin {
        uint256 aaveNonce = _aaveNonce++;
        bytes32 commitmentId = _hashAaveProposal(
            aaveNonce,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
        _aaveCommitment[commitmentId] = block.number;
        emit AaveCommitment(
            aaveNonce,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
    }

    function _hashAaveProposal(
        uint256 aaveNonce,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                aaveNonce,
                targets,
                values,
                signatures,
                calldatas,
                withDelegatecalls,
                ipfsHash
            )
        );
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

    function compoundCommit(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin {
        uint256 compoundNonce = _compoundNonce++;
        bytes32 commitmentId = _hashCompoundProposal(
            compoundNonce,
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        _compoundCommitment[commitmentId] = block.number;
        emit CompoundCommitment(
            compoundNonce,
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function _hashCompoundProposal(
        uint256 compNonce,
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                compNonce,
                targets,
                values,
                signatures,
                calldatas,
                description
            )
        );
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

    function uniCommit(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin {
        uint256 uniNonce = _uniNonce++;
        bytes32 commitmentId = _hashUniProposal(
            uniNonce,
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        _uniCommitment[commitmentId] = block.number;
        emit UniCommitment(
            uniNonce,
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function _hashUniProposal(
        uint256 uniNonce,
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                uniNonce,
                targets,
                values,
                signatures,
                calldatas,
                description
            )
        );
    }

    modifier onlyAdmin() {
        require(_isAdmin[msg.sender], 'Failed: not admin');
        _;
    }
}
