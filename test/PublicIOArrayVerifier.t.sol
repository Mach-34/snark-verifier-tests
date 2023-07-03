// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9;

import "forge-std/Test.sol";
import {PublicIOArrayVerifierWrapper} from "../contracts/PublicIOArrayVerifierWrapper.sol";
import {YulDeployer} from "../contracts/YulDeployer.sol";

contract PublicIOArrayVerifierTest is Test {
    address verifierAddress;
    PublicIOArrayVerifierWrapper verifierWrapper;
    YulDeployer yulDeployer;

    function setUp() public {
        yulDeployer = new YulDeployer();
        verifierAddress = address(
            yulDeployer.deployContract("../snark-verifiers/10_public_io_array")
        );
        verifierWrapper = new PublicIOArrayVerifierWrapper(verifierAddress);
    }

    function test_verifier() external {
        // Read in proof from calldata file
        string memory proofStr = vm.readFile(
            "snark-verifiers/data/10_public_io_array.calldata"
        );

        // Verify proof and assert success
        verifierWrapper.validProof(
            [uint256(341), uint256(219), uint256(499)],
            vm.parseBytes(proofStr)
        );
    }
}
