# MetaGovernor
The MetaGovernor contract is designed to be the target of vote delegation.

# Philosophy
The philosophy behind this metagovernor contract is to enable multiple means of initiating proposals and/or votes on other DeFi governance contracts. For example, one admin slot can be set to a multisig wallet that does only voting, and another admin slot can be set to a contract that only does proposals.

# CommitmentAdmin
New proposals require a three day delay, giving delegators a window of time to remove their delegates from the MetaGovernor contract or giving would-be delegators a window of time to add their delegates to the contract.
