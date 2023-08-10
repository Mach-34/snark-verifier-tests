# snark-verifier-tests

Demonstration of using halo2 proofs on the EVM generated from the [Halo2 Backend for Aztec Noir](https://github.com/ethan-000/halo2_backend). Assumes that you have installed this repository (see that readme) and can access the halo2 backend using `nargo` from the cli.

## Generating Contracts
Simply run `nargo codegen-verifier` to generate a yul verifier. You can reuse the deployment code in one of the test scripts in to make a foundry deployment script to put the contract on a target chain. Alternatively, look at [Axiom V1](https://github.com/axiom-crypto/axiom-v1-contracts/tree/main/script/mainnet) for alternative options using foundry's cast CLI.

## Encoding Calldata
This repository includes a cli utility to encode calldata and write it to a file. Prerequisites, in a noir folder (ex: `./calldata_encoder/programs/10_public_io`):
1. run `nargo compile main` -> creates artifact `10_public_io/target/main.json` (compiled circuit containing public input indices)
2. run `nargo execute witness` -> creates artifact `10_public_io/target/witness.nr` (executed witnesses to pull pub inputs from)
3. run `nargo prove p` -> halo2 proof

Once these artifacts are created, you can run the calldata_encoder cli utility (in `./calldata_encoder`)
1. build the cli: `cargo build --release`
2. run the cli: `./target/release/calldata_encoder ./programs/10_public_io`
3. artifact is generated at `./proof.calldata`

You can now draw this artifact in using forge ffi as is shown in the tests.

## Testing
`forge test --ffi`