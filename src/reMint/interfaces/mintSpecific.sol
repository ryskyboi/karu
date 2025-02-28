// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title IMintSpecific
 * @notice Interface for minting a specific NFT by its token ID
 */
interface IMintSpecific {
    /**
     * @notice Mint a specific NFT with the given token ID
     * @param to The address to mint the NFT to
     * @param tokenId The specific token ID to mint
     * @return success Whether the minting was successful
     */
    function mintSpecific(address to, uint256 tokenId) external returns (bool success);

    /**
     * @notice Event emitted when a specific NFT is minted
     * @param to The address the NFT was minted to
     * @param tokenId The token ID that was minted
     */
    event SpecificNFTMinted(address indexed to, uint256 indexed tokenId);
}