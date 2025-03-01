// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {BurnToMintSeaDrop} from "../src/reMint/minter.sol";
import {ERC721SeaDrop} from "../src/ERC721SeaDrop.sol";
import {ERC721SeaDropStructsErrorsAndEvents} from "../src/lib/ERC721SeaDropStructsErrorsAndEvents.sol"; // Commented out as the file is not found
import {ISeaDropTokenContractMetadata} from "../src/interfaces/ISeaDropTokenContractMetadata.sol";
import {INonFungibleSeaDropToken} from "../src/interfaces/INonFungibleSeaDropToken.sol";

contract HelloWorldTest is Test {
    ERC721SeaDrop TestOriginalKaru;
    ERC721SeaDrop Karu;
    BurnToMintSeaDrop minter;

    // Test accounts
    address testUser = address(0xB0B);
    address testUser2 = address(0xA11CE);

    function setUp() public {
        Karu = new ERC721SeaDrop("K-16 a.k.a KARU", "KARU", new address[](0));

        TestOriginalKaru = new ERC721SeaDrop("K-16 a.k.a KARU", "KARU", new address[](0));

        //Set up the original karu contract and give us rights to mint new NFTs
        address[] memory allowedSeaDrops = new address[](1);
        allowedSeaDrops[0] = address(this);
        TestOriginalKaru.updateAllowedSeaDrop(allowedSeaDrops);
        // Mint some test NFTs to our test users
        INonFungibleSeaDropToken(address(TestOriginalKaru)).mintSeaDrop(testUser, 5);  // mint tokens 1-5 to testUser
        INonFungibleSeaDropToken(address(TestOriginalKaru)).mintSeaDrop(testUser2, 3);  // mint tokens 6-8 to testUser2
        uint256[] memory blackListedTokens = new uint256[](2);
        blackListedTokens[0] = 6;
        blackListedTokens[1] = 8;


        // Create the minter contract
        minter = new BurnToMintSeaDrop(address(TestOriginalKaru), address(Karu), blackListedTokens);

        // Allow the minter contract to mint NFTs
        allowedSeaDrops[0] = address(minter);
        Karu.updateAllowedSeaDrop(allowedSeaDrops);
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
        config.maxSupply = 1600;
        config.baseURI = "ipfs://bafkreibhwww25kifa4tfvsrl2fyliovnkadlefyp4lvtua4h6d2k344xny";

        //These were set in the original but not sure what they do
        config.allowedPayers = new address[](1);
        config.allowedPayers[0] = 0xEF0B56692F78A44CF4034b07F80204757c31Bcc9;
        config.allowedFeeRecipients = new address[](1);
        config.allowedFeeRecipients[0] = 0x0000a26b00c1F0DF003000390027140000fAa719;

        Karu.multiConfigure(config);
        Karu.setTransferValidator(0x721C002B0059009a671D00aD1700c9748146cd1B);
    }

}