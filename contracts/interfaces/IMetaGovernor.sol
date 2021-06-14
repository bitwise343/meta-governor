pragma solidity ^0.8.0;


interface IMetaGovernor {

    event AdminChanged(address indexed admin, bool oldStatus, bool newStatus);

    event AaveProposal(uint256 indexed proposalId);
    event CompoundProposal(uint256 indexed proposalId);
    event UniProposal(uint256 indexed proposalId);

    event AaveVote(uint256 indexed proposalId, bool support);
    event CompoundVote(uint256 indexed proposalId, uint8 support);
    event UniVote(uint256 indexed proposalId, bool support);

    function isAdmin(address account) external view returns (bool);

    function changeAdminStatus(address account, bool status) external;

    function aave() external view returns (address);

    function compound() external view returns (address);

    function uni() external view returns (address);

    function aaveVote(uint256 proposalId, bool support) external;

    function aaveCreate(
        address executor,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls,
        bytes32 ipfsHash
    ) external returns (uint256) ;

    function compoundCastVote(
        uint256 proposalId, uint8 support
    ) external;

    function compoundCastVoteWithReason(
        uint256 proposalId, uint8 support, string memory reason
    ) external;

    function compoundPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);

    function uniCastVote(uint256 proposalId, bool support) external;

    function uniPropose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
}
