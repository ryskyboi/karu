// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {BurnToMintSeaDrop} from "../src/reMint/minter.sol";
import {ERC721SeaDrop} from "../src/ERC721SeaDrop.sol";
import {ISeaDropTokenContractMetadata} from "../src/interfaces/ISeaDropTokenContractMetadata.sol";

contract HelloWorldTest is Test {
    ERC721SeaDrop Karu;

    function setUp() public {
        Karu = new ERC721SeaDrop("K-16 a.k.a KARU", "KARU", new address[](0));
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


}