// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9;

import "forge-std/Test.sol";
import {VerifierWrapper} from "../contracts/VerifierWrapper.sol";
import {YulDeployer} from "../contracts/YulDeployer.sol";

contract YulDeployerTest is Test {
    address verifierAddress;
    VerifierWrapper verifierWrapper;
    YulDeployer yulDeployer;

    function setUp() public {
        yulDeployer = new YulDeployer();
        verifierAddress = address(
            yulDeployer.deployContract("../snark-verifiers/9_public_io")
        );
        verifierWrapper = new VerifierWrapper(verifierAddress);
    }

    function test_verifier() external {
        // Read in proof from calldata file
        string memory proofStr = vm.readFile(
            "snark-verifiers/data/9_public_io.calldata"
        );
        bytes memory proof = vm.parseBytes(proofStr);

        // Verify proof and assert success
        uint256 num = verifierWrapper.validProof(7, proof);
    }
}
