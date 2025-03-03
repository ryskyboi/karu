// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {BurnToMintSeaDrop} from "../src/reMint/minter.sol";
import {ERC721SeaDrop} from "../src/ERC721SeaDrop.sol";
import {ERC721SeaDropStructsErrorsAndEvents} from "../src/lib/ERC721SeaDropStructsErrorsAndEvents.sol";
import {ISeaDropTokenContractMetadata} from "../src/interfaces/ISeaDropTokenContractMetadata.sol";
import {INonFungibleSeaDropToken} from "../src/interfaces/INonFungibleSeaDropToken.sol";

contract DeployKaru is Script {
    // Original Karu contract address
    address public originalKaruAddress; // Replace with the actual address

    // Blacklisted token IDs
    uint256[] public blackListedTokens;

    function run() external {
        // Begin recording transactions for deployment
        vm.startBroadcast();

        // Set up black listed tokens - replace with actual blacklisted IDs if needed
        blackListedTokens = new uint256[](5);
        blackListedTokens[0] = 145;
        blackListedTokens[0] = 137;
        blackListedTokens[0] = 132;
        blackListedTokens[0] = 119;
        blackListedTokens[0] = 117;

        originalKaruAddress = 0x409EF8712741258cDA2aeD4577353cd3e7E44a34;
        // If you need to add blacklisted tokens, uncomment and modify:
        // blackListedTokens.push(6);
        // blackListedTokens.push(8);

        // Deploy the new Karu contract
        ERC721SeaDrop karu = new ERC721SeaDrop(
            "K-16 a.k.a KARU", // Name
            "KARU", // Symbol
            new address[](0) // No initial seaDrops
        );
        console2.log("New Karu contract deployed at:", address(karu));

        // Set max supply
        karu.setMaxSupply(1600);
        console2.log("Max supply set to: 1600");

        // Deploy BurnToMintSeaDrop contract
        BurnToMintSeaDrop minter = new BurnToMintSeaDrop(originalKaruAddress, address(karu), blackListedTokens);
        console2.log("Minter contract deployed at:", address(minter));

        // Allow minter contract to mint on Karu
        address[] memory allowedSeaDrops = new address[](1);
        allowedSeaDrops[0] = address(minter);
        karu.updateAllowedSeaDrop(allowedSeaDrops);
        console2.log("Minter added to allowed SeaDrop addresses");

        // Set base URI
        ERC721SeaDropStructsErrorsAndEvents.MultiConfigureStruct memory config;
        config.baseURI = "ipfs://bafkreibhwww25kifa4tfvsrl2fyliovnkadlefyp4lvtua4h6d2k344xny";
        karu.multiConfigure(config);
        console2.log("Base URI set");

        // Set royalty info
        ISeaDropTokenContractMetadata.RoyaltyInfo memory royaltyInfo = ISeaDropTokenContractMetadata.RoyaltyInfo({
            royaltyAddress: 0xdEAD000000000000000042069420694206942069, // Burn address
            royaltyBps: 0 // 0% royalty
        });
        karu.setRoyaltyInfo(royaltyInfo);

        // Optional: Transfer ownership if needed
        // karu.transferOwnership(newOwner);
        // minter.transferOwnership(newOwner);

        // Pre-mint all tokens to the minter contract
        minter.mintAll();
        console2.log("All tokens minted to minter contract");

        vm.stopBroadcast();

        console2.log("\n===============================");
        console2.log("Deployment summary:");
        console2.log("===============================");
        console2.log("Original Karu: ", originalKaruAddress);
        console2.log("New Karu: ", address(karu));
        console2.log("Minter: ", address(minter));
        console2.log("Max supply: 1600");
        console2.log("===============================");
        console2.log("\nNext steps:");
        console2.log("1. Verify contracts on Etherscan");
        console2.log("2. Airdrop tokens using minter.airdrop()");
    }
}
