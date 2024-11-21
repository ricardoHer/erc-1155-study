// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply {

    uint256 public publicPrice = 0.01 ether;
    uint256 public maxSupply = 2000;

    constructor()
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        Ownable(msg.sender)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // add supply tracking
    function mint(uint256 id, uint256 amount)
        public
        payable
    {
        require(id < 2, "Sorry looks like you're trying to mint the wrong NFT");
        require(msg.value == (publicPrice * amount), "WRONG! Not enouth money sent");
        require(totalSupply(id) + amount <= maxSupply, "Sorry we have minted out!");
        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI nonexistent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    /**
    * @notice withdraw balance
    *
    * @param _addr the address we are sending the CAYYYYYYUSH to
    */
    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance; // get the balance of the contract
        payable(_addr).transfer(balance);
    }
}
