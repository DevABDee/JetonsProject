// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./Common/common.sol";
import "./JetonsDefaultPool.sol";

contract JetonsPoolFactory {
    address public owner;
    address public immutable managerContractAddress;

    constructor (address managerContract) {
        owner = msg.sender;
        managerContractAddress = managerContract;

        // Calling method from another contract
        bytes memory payload = abi.encodeWithSignature("setFactoryAddress(address)", owner);
        (bool success, bytes memory returnData) = address(managerContractAddress).call(payload);
        require(success);
    }

    function creaNewDefaultPool(address jackpotPoolAddress, address consolationPoolAddress, address lpAddress, uint[14] memory cfg) public isOwner
        returns (Pool memory)
    {
        JetonsDefaultPool defaultPool = new JetonsDefaultPool(owner, jackpotPoolAddress, consolationPoolAddress, lpAddress, cfg);

        Pool memory pool;
        pool.number = cfg[13];
        pool.poolAddress = address(defaultPool);
    
        return pool;
    }

    // MODIFIERS
    modifier isOwner() {
        require(msg.sender == managerContractAddress, "Not the manager contract address");
        _;
    }
}