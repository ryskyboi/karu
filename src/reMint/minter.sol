// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {INonFungibleSeaDropToken} from "../interfaces/INonFungibleSeaDropToken.sol";
import {TwoStepOwnable} from "lib/utility-contracts/src/TwoStepOwnable.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";

/**
 * @title BurnToMintSeaDrop
 * @notice A custom SeaDrop implementation that requires burning a specific NFT to mint.
 */
contract BurnToMintSeaDrop is TwoStepOwnable {
    /// @notice Address of the NFT contract to burn tokens from.
    address public immutable burnTokenContract;

    /// @notice Address of the NFT contract to mint tokens to.
    address public immutable nftContract;

    /// @notice List of blacklisted token IDs.
    uint256[] public blackListedTokens;

    /// @notice Event emitted when a token is minted.
    event SeaDropMint(address indexed nftContract, address indexed minter, uint256 tokenId);

    /**
     * @dev Constructor to set the burn token contract address, mint token contract address, and blacklisted tokens.
     * @param _burnTokenContract Address of the NFT contract to burn tokens from.
     * @param _nftContract Address of the NFT contract to mint tokens to.
     * @param _blackListedTokens Array of blacklisted token IDs.
     */
    constructor(address _burnTokenContract, address _nftContract, uint256[] memory _blackListedTokens) {
        blackListedTokens = _blackListedTokens;
        nftContract = _nftContract;
        burnTokenContract = _burnTokenContract;
    }

    /**
     * @notice Mints all tokens to the contract address.
     * @dev Only callable by the owner.
     */
    function mintAll() public onlyOwner {
        INonFungibleSeaDropToken(nftContract).mintSeaDrop(
            address(this), INonFungibleSeaDropToken(nftContract).maxSupply()
        );
    }

    /**
     * @dev Returns the offset value.
     * @return The offset value.
     */
    function _offset() internal pure returns (uint256) {
        return 1;
    }

    /**
     * @notice Checks if a token ID is blacklisted.
     * @param tokenId The token ID to check.
     * @return True if the token ID is blacklisted, false otherwise.
     */
    function isBlackListed(uint256 tokenId) public view returns (bool) {
        for (uint256 i = 0; i < blackListedTokens.length; i++) {
            if (blackListedTokens[i] == tokenId) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Mints tokens by transferring them to the owners of the corresponding burn tokens.
     * @dev Only callable by the owner.
     */
    function airdrop() external onlyOwner {
        for (
            uint256 tokenId = _offset();
            tokenId < INonFungibleSeaDropToken(burnTokenContract).maxSupply() + _offset();
            tokenId++
        ) {
            if (isBlackListed(tokenId)) {
                continue;
            }
            address owner = IERC721A(burnTokenContract).ownerOf(tokenId);
            IERC721A(nftContract).transferFrom(address(this), owner, tokenId);
            emit SeaDropMint(nftContract, owner, tokenId);
        }
    }

    /**
     * @notice Sets the list of blacklisted token IDs.
     * @param _blackListedTokens Array of blacklisted token IDs.
     * @dev Only callable by the owner.
     */
    function setBlackListedTokens(uint256[] memory _blackListedTokens) external onlyOwner {
        blackListedTokens = _blackListedTokens;
    }

    /**
     * @notice Withdraws blacklisted tokens to the owner's address.
     * @dev Only callable by the owner.
     */
    function withDrawBlackListedTokens() external onlyOwner {
        for (uint256 i = 0; i < blackListedTokens.length; i++) {
            IERC721A(nftContract).transferFrom(address(this), msg.sender, blackListedTokens[i]);
        }
    }

    /**
     * @dev Implementation of the IERC721Receiver interface.
     * This allows the contract to receive ERC721 tokens.
     * @return The selector of the onERC721Received function.
     */
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
