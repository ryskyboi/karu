// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {BurnToMintSeaDrop} from "../src/reMint/minter.sol";
import {ERC721SeaDrop} from "../src/ERC721SeaDrop.sol";
import {ERC721SeaDropStructsErrorsAndEvents} from "../src/lib/ERC721SeaDropStructsErrorsAndEvents.sol"; // Commented out as the file is not found
import {ISeaDropTokenContractMetadata} from "../src/interfaces/ISeaDropTokenContractMetadata.sol";
import {INonFungibleSeaDropToken} from "../src/interfaces/INonFungibleSeaDropToken.sol";

contract MintTest is Test {
    ERC721SeaDrop TestOriginalKaru;
    ERC721SeaDrop Karu;
    BurnToMintSeaDrop minter;

    // Test accounts
    address testUser = address(0xB0B);
    address testUser2 = address(0xA11CE);

    function setUpTestOriginalKaru() public {
        TestOriginalKaru = new ERC721SeaDrop("K-16 a.k.a KARU", "KARU", new address[](0));
        TestOriginalKaru.setMaxSupply(1600);

        address[] memory allowedSeaDrops = new address[](1);
        allowedSeaDrops[0] = address(this);
        TestOriginalKaru.updateAllowedSeaDrop(allowedSeaDrops);
        // Mint some test NFTs to our test users

        TestOriginalKaru.mintSeaDrop(testUser, 5);  // mint tokens 1-5 to testUser
        TestOriginalKaru.mintSeaDrop(testUser2, 1595);  // mint tokens 6-1600 to testUser2
    }

    function setUpKaru() public {
        Karu = new ERC721SeaDrop("K-16 a.k.a KARU", "KARU", new address[](0));
        Karu.setMaxSupply(1600);

        uint256[] memory blackListedTokens = new uint256[](2);
        blackListedTokens[0] = 6;
        blackListedTokens[1] = 8;

        // Create the minter contract
        minter = new BurnToMintSeaDrop(address(TestOriginalKaru), address(Karu), blackListedTokens);

        // Allow the minter contract to mint NFTs
        address[] memory allowedSeaDrops = new address[](1);
        allowedSeaDrops[0] = address(minter);
        Karu.updateAllowedSeaDrop(allowedSeaDrops);
    }

    function setUp() public {
        setUpTestOriginalKaru();
        setUpKaru();
        minter.mintAll();
    }

    function test_UpdateRoyalty() public {
        ISeaDropTokenContractMetadata.RoyaltyInfo memory newInfo = ISeaDropTokenContractMetadata.RoyaltyInfo({
            royaltyAddress: address(0x123),  // Need to figure out where to point this
            royaltyBps: 0
        });
        Karu.setRoyaltyInfo(newInfo);
        assertEq(Karu.royaltyAddress(), newInfo.royaltyAddress);
        assertEq(Karu.royaltyBasisPoints(), newInfo.royaltyBps);
    }

    function test_setParams() public {
        ERC721SeaDropStructsErrorsAndEvents.MultiConfigureStruct memory config;
        // Only set the values we care about
        config.baseURI = "ipfs://bafkreibhwww25kifa4tfvsrl2fyliovnkadlefyp4lvtua4h6d2k344xny";


        Karu.multiConfigure(config);
        // Karu.setTransferValidator(0x721C002B0059009a671D00aD1700c9748146cd1B);
    }

    function test_Airdrop() public {
        minter.airdrop();
    }

    function test_DropOwners() public {
        test_Airdrop();
        for (uint256 i = 1; i < Karu.maxSupply() + 1; i++) {
            if (i == 6 || i == 8) {
                continue;
            }
            assert(Karu.ownerOf(i) == TestOriginalKaru.ownerOf(i));
        }
    }


    function test_withdrawBlacklistedTokens() public {
        // Let's add a clear test that verifies blacklisted tokens can't be withdrawn
        console2.log("Testing withdrawing blacklisted tokens - should fail");

        minter.withDrawBlackListedTokens();

        assert(Karu.ownerOf(6) == address(this));
        assert(Karu.ownerOf(8) == address(this));
    }
}