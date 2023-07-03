// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9;

import "forge-std/Test.sol";
import {PublicIOVerifierWrapper} from "../contracts/PublicIOVerifierWrapper.sol";
import {YulDeployer} from "../contracts/YulDeployer.sol";

contract PublicIOVerifierTest is Test {
    address verifierAddress;
    PublicIOVerifierWrapper verifierWrapper;
    YulDeployer yulDeployer;

    function setUp() public {
        yulDeployer = new YulDeployer();
        verifierAddress = address(
            yulDeployer.deployContract("../snark-verifiers/9_public_io")
        );
        verifierWrapper = new PublicIOVerifierWrapper(verifierAddress);
    }

    function test_verifier() external {
        // Read in proof from calldata file
        string memory proofStr = vm.readFile(
            "snark-verifiers/data/9_public_io.calldata"
        );

        // Verify proof and assert success
        verifierWrapper.validProof(7, vm.parseBytes(proofStr));
    }
}
