// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
// import "forge-std/Test.sol";
import {YulDeployer} from "./YulDeployer.sol";

contract VerifierWrapper {
    address verifierAddress;

    constructor(address _verifierAddress) {
        verifierAddress = _verifierAddress;
    }

    function verifyProof(bytes memory proof) private returns (bool) {
        (bool success, ) = verifierAddress.call(proof);
        return success;
    }

    function validProof(uint256 pubInputOne, bytes calldata proof) external {
        // Extract calldata
        uint256 num = uint256(bytes32(proof[0:64]));
        assert(pubInputOne == num);
        // Verify proof
        bool success = verifyProof(proof);
        assert(success);
    }
}
