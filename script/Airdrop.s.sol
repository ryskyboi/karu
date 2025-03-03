// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {BurnToMintSeaDrop} from "../src/reMint/minter.sol";

contract AirdropKaru is Script {
    // Address of the previously deployed minter contract
    address public minterContractAddress;

    function run() external {
        // Load minter address from command line args or configure here
        minterContractAddress = vm.envOr("MINTER_ADDRESS", address(0));

        // Ensure we have a valid minter address
        if (minterContractAddress == address(0)) {
            console2.log("Error: Please provide the MINTER_ADDRESS environment variable");
            console2.log("Example: forge script script/AirdropKaru.s.sol --rpc-url <URL> --private-key <KEY> --broadcast -vvv --env MINTER_ADDRESS=0x12345...");
            return;
        }

        console2.log("Starting airdrop from minter contract:", minterContractAddress);
        console2.log("This may take a while and consume significant gas...");

        // Start recording transactions for blockchain interaction
        vm.startBroadcast();

        // Execute the airdrop
        BurnToMintSeaDrop minter = BurnToMintSeaDrop(minterContractAddress);
        minter.airdrop();

        vm.stopBroadcast();

        console2.log("Airdrop completed successfully!");
        console2.log("Tokens have been distributed to the owners of the original collection.");
    }
}