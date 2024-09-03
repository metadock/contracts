// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @notice A mock implementation of ERC-721 that implements the {IERC721} interface
contract MockERC721Collection is ERC721 {
    uint256 private _tokenIdCounter;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        // Start the token ID counter at 1
        _tokenIdCounter = 1;
    }

    function mint(address to) public returns (uint256) {
        // Generate a new token ID
        uint256 tokenId = _tokenIdCounter;

        // Mint the token to the specified address
        _safeMint(to, tokenId);

        // Increment the token ID counter
        unchecked {
            _tokenIdCounter++;
        }

        // Return the token ID
        return tokenId;
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
