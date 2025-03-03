// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {
    INonFungibleSeaDropToken
} from "../interfaces/INonFungibleSeaDropToken.sol";

import { TwoStepOwnable } from "lib/utility-contracts/src/TwoStepOwnable.sol";

import { IERC721A } from "lib/ERC721A/contracts/IERC721A.sol";


/**
 * @title BurnToMintSeaDrop
 * @notice A custom SeaDrop implementation that requires burning a specific NFT to mint.
 */
contract BurnToMintSeaDrop is TwoStepOwnable {
    /// @notice Address of the NFT contract to burn tokens from
    address public immutable burnTokenContract;

    /// @notice Address of the NFT contract to mint tokens to
    address public immutable nftContract;

    uint256[] public blackListedTokens;

    /// @notice Event emitted when a token is minted
    event SeaDropMint(
        address indexed nftContract,
        address indexed minter,
        uint256 tokenId
    );

    /// @dev Constructor to set the burn token contract address
    constructor(address _burnTokenContract, address  _nftContract, uint256[] memory _blackListedTokens) {
        blackListedTokens = _blackListedTokens;
        nftContract = _nftContract;
        burnTokenContract = _burnTokenContract;
    }

    function mintAll() public onlyOwner {
        //This will mint all the tokens to the contract address
        INonFungibleSeaDropToken(nftContract).mintSeaDrop(address(this), INonFungibleSeaDropToken(nftContract).maxSupply());
    }

    function _offset() internal pure returns (uint256) {
        // Hardcoded as cannot be fetched from the contract
        return 1;
    }

    function isBlackListed(uint256 tokenId) public view returns (bool) {
        for (uint256 i = 0; i < blackListedTokens.length; i++) {
            if (blackListedTokens[i] == tokenId) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Mint by burning a specific NFT
     * @dev This is the only mint method that will be enabled
     */
    function airdrop() external onlyOwner(){
        // Check that the token hasn't already been redeemed

        for (uint256 tokenId = _offset(); tokenId < INonFungibleSeaDropToken(burnTokenContract).maxSupply() + _offset(); tokenId++) {
            if (isBlackListed(tokenId)) {
                continue;
            }
            address owner = IERC721A(burnTokenContract).ownerOf(tokenId);
            IERC721A(nftContract).transferFrom(address(this), owner, tokenId);
            // Emit mint event
            emit SeaDropMint(
                nftContract,
                owner,
                tokenId
            );
        }
    }

    function setBlackListedTokens(uint256[] memory _blackListedTokens) external onlyOwner{
        blackListedTokens = _blackListedTokens;
    }

    function withDrawBlackListedTokens() external onlyOwner {
        for (uint256 i = 0; i < blackListedTokens.length; i++) {
            IERC721A(nftContract).transferFrom(address(this), msg.sender, blackListedTokens[i]);
        }
    }

    /**
     * @dev Implementation of IERC721Receiver interface
     * This allows the contract to receive ERC721 tokens
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}