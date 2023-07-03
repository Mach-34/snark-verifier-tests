// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
// import "forge-std/Test.sol";
import {YulDeployer} from "./YulDeployer.sol";

contract PublicIOArrayVerifierWrapper {
    address verifierAddress;

    constructor(address _verifierAddress) {
        verifierAddress = _verifierAddress;
    }

    function validProof(
        uint256[3] memory publicInputs,
        bytes calldata proof
    ) external {
        // Extract calldata
        uint256 extractedVal1 = uint256(bytes32(proof[0:32]));
        uint256 extractedVal2 = uint256(bytes32(proof[32:64]));
        uint256 extractedVal3 = uint256(bytes32(proof[64:96]));

        // Assert extracted values equal public inputs
        assert(publicInputs[0] == extractedVal1);
        assert(publicInputs[1] == extractedVal2);
        assert(publicInputs[2] == extractedVal3);

        // Verify proof
        (bool success, ) = verifierAddress.call(proof);
        assert(success);
    }
}
