// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {Attack} from "../src/Attack.sol";

contract DeployAttack is Script {
    address dexAddr = 0xb73303b339346b7B220e239856757eDF5e8Dd918;

    function run() external returns (Attack) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        Attack attack = new Attack(dexAddr, "Renzo", "RZO", 1000);
        vm.stopBroadcast();

        return (attack);
    }
}

// forge script script/DeployAttack.s.sol:DeployAttack --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvv
