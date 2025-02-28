// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IMintSpecific} from "./interfaces/mintSpecific.sol";

import { IERC721A } from "lib/ERC721A/contracts/IERC721A.sol";

/**
 * @title BurnToMintSeaDrop
 * @notice A custom SeaDrop implementation that requires burning a specific NFT to mint.
 */
contract BurnToMintSeaDrop {
    /// @notice Address of the NFT contract to burn tokens from
    address public immutable burnTokenContract;

    /// @notice Mapping to track if a token has been minted using this mechanism
    mapping(uint256 => bool) public tokenIdRedeemed;

    /// @notice Event emitted when a token is minted
    event SeaDropMint(
        address indexed nftContract,
        address indexed minter
    );

    /// @dev Constructor to set the burn token contract address
    constructor(address _burnTokenContract) {
        burnTokenContract = _burnTokenContract;
    }

    /**
     * @notice Mint by burning a specific NFT
     * @dev This is the only mint method that will be enabled
     *
     * @param nftContract      The nft contract to mint from
     * @param burnTokenId      The ID of the token to burn
     */
    function mintByBurning(
        address nftContract,
        uint256 burnTokenId
    ) external {
        // Check that the token hasn't already been redeemed
        require(!tokenIdRedeemed[burnTokenId], "Token already redeemed");

        // Check that the caller owns the token to be burned
        require(
            IERC721A(burnTokenContract).ownerOf(burnTokenId) == msg.sender,
            "Not token owner"
        );

        // Burn the token by transferring to address(0)
        // Note: The burn token contract must support transfers to address(0)
        // If it doesn't, you'll need to use its burn method instead
        IERC721A(burnTokenContract).transferFrom(msg.sender, address(0), burnTokenId);

        // Mark the token as redeemed
        tokenIdRedeemed[burnTokenId] = true;

        // Mint the new NFT
        IMintSpecific(nftContract).mintSpecific(msg.sender, burnTokenId);

        // Emit mint event
        emit SeaDropMint(
            nftContract,
            msg.sender
        );
    }
}
