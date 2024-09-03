// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @notice A mock implementation of ERC-1155 that implements the {IERC1155} interface
contract MockERC1155Collection is ERC1155 {
    uint256 private _tokenTypeIdCounter;

    constructor(string memory uri) ERC1155(uri) {
        // Start the token type ID counter at 1
        _tokenTypeIdCounter = 1;
    }

    function mint(address to, uint256 amount) public returns (uint256) {
        // Generate a new token ID
        uint256 tokenId = _tokenTypeIdCounter;

        // Mint the token to the specified address
        _mint(to, tokenId, amount, "");

        // Increment the token ID counter
        unchecked {
            _tokenTypeIdCounter++;
        }

        // Return the token ID
        return tokenId;
    }

    function mintBatch(address to, uint256[] memory amounts) public returns (uint256[] memory) {
        // Create a new array to store the token IDs
        uint256 cachedAmount = amounts.length;
        uint256[] memory tokenIds = new uint256[](cachedAmount);

        for (uint256 i; i < cachedAmount; ++i) {
            // Generate a new token ID for each amount
            tokenIds[i] = _tokenTypeIdCounter;

            // Increment the token ID counter
            unchecked {
                ++_tokenTypeIdCounter;
            }
        }

        // Mint the tokens to the specified address
        _mintBatch(to, tokenIds, amounts, "");

        // Return the token IDs
        return tokenIds;
    }

    function burn(uint256 tokenId, uint256 amount) public {
        _burn(msg.sender, tokenId, amount);
    }

    function burnBatch(uint256[] memory tokenIds, uint256[] memory amounts) public {
        _burnBatch(msg.sender, tokenIds, amounts);
    }
}
