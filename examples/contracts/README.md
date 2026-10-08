# Example: new contracts under UFL 3.8 (Decentralized, Contract Release)

Contracts already deployed under another license, such as MIT,
stay under it. A deployment's license is
fixed when it is deployed, and nothing here changes it. This example is for
new contracts and new implementations behind a proxy.

```sh
sh generate.sh -y 2026 -c "Example Holder" -p "Example Project" -s decentralized -k EXMPL -K -o LICENSE
sh generate.sh -r -s decentralized -k EXMPL -K
# UFL 3.8, Operational Scope: Decentralized, Contract Release (LicenseRef-UFL-3.8-D-K)
sha256sum LICENSE   # goes in each source header
```

[`LICENSE`](./LICENSE) is that output, and [`ExampleToken.sol`](./WHONE.sol) shows
the header. Checklist for each new deployment:

1. Generate the license, compute its SHA-256, and put the header at the top
   of every project-written source file before the compile you will deploy. The
   SPDX line and comments change the metadata hash.
2. Imported libraries (OpenZeppelin and similar) stay in their own files with
   their own SPDX lines. If you flatten for verification, use one SPDX
   expression, for example `MIT AND LicenseRef-UFL-3.8-D-K`.
3. Publish the Release statement with the deployment: chain, address, hash of
   the verified source, and the line above, in the release notes or the docs.
4. For a proxy, give each new implementation its own header and Release
   statement, and announce the change where you announce upgrades.
5. Ship the Section 9 step in every front end, app, wallet, or tool you
   provide. It names UFL 3.8, the Decentralized scope, the one-dollar limit,
   and the arbitration terms, and it records acceptance on the user's own
   machine. Do not write acceptance to a chain.
6. Redeployers of the project's contract must credit the project, naming the origin chain
   and address, and keep the header. Plain callers owe nothing and are not
   bound by anything that needs acceptance.
7. Check how each block explorer you use displays a `LicenseRef` SPDX line on
   a test network before mainnet.
