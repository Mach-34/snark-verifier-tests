// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9;

import "forge-std/Test.sol";
import {YulDeployer} from "../contracts/YulDeployer.sol";

contract YulDeployerTest is Test {
    address verifierAddress;
    YulDeployer yulDeployer;

    function setUp() public {
        yulDeployer = new YulDeployer();

        verifierAddress = address(
            yulDeployer.deployContract("../snark-verifiers/9_public_io")
        );
    }

    function verifyProof(bytes memory input) private returns (bool) {
        (bool success, ) = verifierAddress.call(input);
        return success;
    }

    function test_yulVerifier_verify() external {
        string memory proofStr = vm.readFile(
            "snark-verifiers/data/9_public_io.calldata"
        );
        bytes memory proofData = vm.parseBytes(proofStr);
        bool success = verifyProof(proofData);
        assert(success);
    }
}
