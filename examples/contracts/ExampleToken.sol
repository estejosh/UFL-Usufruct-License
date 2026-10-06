// SPDX-License-Identifier: LicenseRef-UFL-3.6-D-K
// Usufruct License (UFL) 3.6, Operational Scope: Decentralized, Contract Release.
// Canonical text: https://github.com/estejosh/UFL-Usufruct-License
// License file SHA-256: 02cefe7691b070696d834c45058077654a564030ca3804f80a43fa0d73aa7379
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
