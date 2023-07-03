// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
// import "forge-std/Test.sol";
import {YulDeployer} from "./YulDeployer.sol";

contract PublicIOVerifierWrapper {
    address verifierAddress;

    constructor(address _verifierAddress) {
        verifierAddress = _verifierAddress;
    }

    function validProof(uint256 pubInputOne, bytes calldata proof) external {
        // Extract calldata
        uint256 num = uint256(bytes32(proof[0:32]));
        assert(pubInputOne == num);
        // Verify proof
        (bool success, ) = verifierAddress.call(proof);
        assert(success);
    }
}
