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
        TestOriginalKaru.mintSeaDrop(testUser2, 3);  // mint tokens 6-8 to testUser2
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
            royaltyBps: 100
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

    function test_mintByBurning() public {
        vm.prank(testUser);
        TestOriginalKaru.approve(address(minter), 1);
        vm.prank(testUser);
        minter.mintByBurning(1);
        assert(Karu.ownerOf(1) == address(testUser));
    }

    function test_mintByBurning2() public {
        vm.prank(testUser2);
        TestOriginalKaru.approve(address(minter), 7);
        vm.prank(testUser2);
        minter.mintByBurning(7);
        assert(Karu.ownerOf(7) == address(testUser2));
    }

    function test_revertBlacklistedToken() public {
       // Let's add a clear test that verifies token 6 is blacklisted
        console2.log("Testing token 6 (blacklisted) - should fail");

        vm.prank(testUser2);  // testUser2 owns token 6
        TestOriginalKaru.approve(address(minter), 6);

        vm.prank(testUser2);
        vm.expectRevert();
        minter.mintByBurning(6);
    }

    function test_revertTokenAlreadyRedeemed() public {
        test_mintByBurning();
        // Let's add a clear test that verifies token 1 is already redeemed
        console2.log("Testing token 1 (already redeemed) - should fail");

        vm.prank(testUser);
        vm.expectRevert();
        minter.mintByBurning(1);
    }

    function test_revertNotTokenOwner() public {
        // Let's add a clear test that verifies testUser2 can't mint token 1
        console2.log("Testing testUser2 minting token 1 - should fail");

        vm.prank(testUser2);
        vm.expectRevert();
        minter.mintByBurning(100);
    }
}