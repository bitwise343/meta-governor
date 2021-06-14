// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IMetaGovernor.sol";

contract CommitmentAdmin {

    event AdminChanged(address indexed admin, bool oldStatus, bool newStatus);

    event AaveCommitment(
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        bool[] withDelegateCalls,
        bytes32 ipfsHash
    );

    event CompoundCommitment(
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        string description
    );

    event UniCommitment(
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        string description
    );

    uint256 private _delayPeriod;
    IMetaGovernor private _metaGovernor;

    mapping (address => bool) private _isAdmin;
    mapping (bytes32 => uint256) private _aaveCommitment;
    mapping (bytes32 => uint256) private _compoundCommitment;
    mapping (bytes32 => uint256) private _uniCommitment;

    constructor(address metaGovernor_) {
        _isAdmin[msg.sender] = true;
        _metaGovernor = IMetaGovernor(metaGovernor_);
        _delayPeriod = 17_280; // ~3 days worth of 15s blocks
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

    function delayPeriod() public view returns (uint256) {
        return _delayPeriod;
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
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
        uint256 commitmentBlock = _aaveCommitment[commitmentId];
        require(commitmentBlock > 0, "Failed: not commited");
        require(
            block.number > commitmentBlock + _delayPeriod,
            "Failed: delay not passed"
        );
        return _metaGovernor.aaveCreate(
            executor,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
    }

    function aaveCommit(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) public onlyAdmin {
        bytes32 commitmentId = _hashAaveProposal(
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
        _aaveCommitment[commitmentId] = block.number;
        emit AaveCommitment(
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            ipfsHash
        );
    }

    function _hashAaveProposal(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                targets,
                values,
                signatures,
                calldatas,
                withDelegatecalls,
                ipfsHash
            )
        );
    }

    function compoundPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin returns (uint256) {
        bytes32 commitmentId = _hashCompoundProposal(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        uint256 commitmentBlock = _compoundCommitment[commitmentId];
        require(commitmentBlock > 0, "Failed: not commited");
        require(
            block.number > commitmentBlock + _delayPeriod,
            "Failed: delay not passed"
        );
        return _metaGovernor.compoundPropose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function compoundCommit(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin {
        bytes32 commitmentId = _hashCompoundProposal(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        _compoundCommitment[commitmentId] = block.number;
        emit CompoundCommitment(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function _hashCompoundProposal(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                targets,
                values,
                signatures,
                calldatas,
                description
            )
        );
    }

    function uniPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin returns (uint256) {
        bytes32 commitmentId = _hashUniProposal(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        uint256 commitmentBlock = _uniCommitment[commitmentId];
        require(commitmentBlock > 0, "Failed: not commited");
        require(
            block.number > commitmentBlock + _delayPeriod,
            "Failed: delay not passed"
        );
        return _metaGovernor.uniPropose(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function uniCommit(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public onlyAdmin {
        bytes32 commitmentId = _hashUniProposal(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
        _uniCommitment[commitmentId] = block.number;
        emit UniCommitment(
            targets,
            values,
            signatures,
            calldatas,
            description
        );
    }

    function _hashUniProposal(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
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
