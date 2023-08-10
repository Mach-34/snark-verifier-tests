use acvm::{
    acir::{circuit::Circuit, native_types::WitnessMap},
    FieldElement,
};
use pse_halo2wrong::curves::bn256::Fr;
use pse_snark_verifier::loader::evm::encode_calldata;
use serde_json::Value;
use std::io::Read;
use clap::Parser;

#[derive(Parser, Debug)]
#[command(name = "Noir Halo2 Backend Calldata Encoder")]
#[command(author = "Mach 34 <jp4g@mach34.space>")]
#[command(version = "1.0")]
#[command(about = "Encodes the calldata for a halo2 proof using Noir artifacts. Takes a path to a Noir circuit. Expects `nargo compile main`, `nargo execute witness`, and `nargo prove p` to already be executed using the Halo2 Backend.")]
struct Args {
    // path to the circuit
    path: String
}

pub fn main() {
    let args = Args::parse();

    let path = args.path.as_str();

    // get artifacts needed for calldata
    let instance = get_instances(path);

    // get proof
    let proof = get_proof(path);

    // encode calldata
    let calldata = encode_calldata(&vec![instance], &proof);

    // write calldata
    let hex_calldata = hex::encode(calldata);
    std::fs::write("proof.calldata", hex_calldata).unwrap();
    let out_path = std::fs::canonicalize("proof.calldata").unwrap();
    println!("Calldata written to {}", out_path.to_str().unwrap());
}

/**
 * Reads a proof artifact into the calldata encoder
 *
 * @param path: &str path to the circuit containing proof
 * @return: Vec<u8> halo2 kzg proof
 */
fn get_proof(path: &str) -> Vec<u8> {
    // get full path to artifact
    let proof_path = std::fs::canonicalize(format!("{path}/proofs/p.proof")).unwrap();

    // read in proof
    hex::decode(std::fs::read(proof_path).unwrap()).unwrap()
}

/**
 * Reads the compiled circuit and witness artifacts to obtain the public inputs
 * @notice - could have read verifier.toml but doing this way makes sure verifier.toml is parsed safely
 *
 * @param path: &str path to the circuit being targeted
 * @return: Vec<Fr> public inputs to the circuit
 */
fn get_instances(path: &str) -> Vec<Fr> {
    // get full path to artifacts
    let circuit_path = std::fs::canonicalize(format!("{path}/target/main.json")).unwrap();
    let witness_path = std::fs::canonicalize(format!("{path}/target/witness.tr")).unwrap();

    // load witness
    let mut witness_buffer = Vec::new();
    std::fs::File::open(witness_path)
        .unwrap()
        .read_to_end(&mut witness_buffer)
        .unwrap();
    let witness = WitnessMap::try_from(&witness_buffer[..]).unwrap();

    // load compiled circuit
    let mut contents = String::new();
    std::fs::File::open(circuit_path)
        .unwrap()
        .read_to_string(&mut contents)
        .unwrap();

    let json: Value = serde_json::from_str(&contents).unwrap();
    let bytecode: Vec<u8> = json
        .get("bytecode")
        .and_then(Value::as_array)
        .unwrap()
        .iter()
        .filter_map(|v| v.as_u64().map(|n| n as u8))
        .collect();
    let circuit = Circuit::read(&*bytecode).unwrap();

    // extract public inputs
    let instance: Vec<Fr> = circuit
        .public_inputs()
        .indices()
        .iter()
        .map(|index| match witness.get_index(*index) {
            Some(val) => noir_field_to_halo2_field(*val),
            None => noir_field_to_halo2_field(FieldElement::zero()),
        })
        .collect();

    instance
}

/**
 * Converts a Noir Field element to a Halo2 Field element
 * @param felt: FieldElement bn254 field element wrapped in noir api
 * @return: Fr bn254 field element wrapped in halo2 api
 */
fn noir_field_to_halo2_field(felt: FieldElement) -> Fr {
    let mut bytes = felt.to_be_bytes();
    bytes.reverse();
    let mut halo_ele: [u8; 32] = [0; 32];
    halo_ele[..bytes.len()].copy_from_slice(&bytes[..]);
    Fr::from_bytes(&halo_ele).unwrap()
}
