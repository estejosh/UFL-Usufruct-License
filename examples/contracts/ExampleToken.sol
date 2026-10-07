// SPDX-License-Identifier: LicenseRef-UFL-3.6-D-K
// Usufruct License (UFL) 3.6, Operational Scope: Decentralized, Contract Release.
// Canonical text: https://github.com/estejosh/UFL-Usufruct-License
// License file SHA-256: 6d8061fc97f438f6b8348ef75c7193fee7bb7c6608ebe8e95c6d9143bacbb985
// Calling this contract is free for everyone. Redeploying it needs credit to
// Example Project (chain and address of the origin) and this notice kept intact (Section 1A, Contracts).
// Third-party imports below keep their own licenses.
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // MIT, its own license

contract ExampleToken {
    string public constant name = "Example Token";
    string public constant symbol = "EXMPL";
    uint8 public constant decimals = 18;
}
