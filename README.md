# SSS Wallet
Practical Multisignature Wallets in laconic Solidity 🐍🐍🐍

First iteration, SSSWallet.sol enables 2/3 multisig transfers of Ether from an address permissioned by balance of "signatures."

If you are a "signer" set on constructor, you can lock your signature to propose a new transfer of Ether from SSS wallet address.
However, after such proposal, and because your signature is thereby locked, you will be unable to vote again on your own proposed transfer, leaving either of the remaining 'signers' to confirm the proposal and 'unlock' the signature, resetting the wallet state and emptying the wallet to the transferee.
