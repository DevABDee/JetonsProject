// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./Common/common.sol";
import "./JetonsDefaultPool.sol";

contract JetonsPoolsManager {
    address public owner;
    address public factoryAddress;
    address public jackpotPoolAddress;
    address public consolationPoolAddress;
    address public lpAddress;

    Pool[] public pools;
    uint256 public finishedPoolsCount;

    // Info about the last pool
    uint256 public lastPoolNumber;
    uint256 public lastPoolDrawDatetime;
    uint256 public lastPoolPrize; // wei
    address public lastPoolAddress;

    // Info about the biggest pool
    address public biggestAddress;
    uint256 public biggestPrize; // wei
    uint256 public biggestDate;

    // If contract is enabled or not
    bool public enabled;


    constructor(address jackpotPoolAddr, address consolationPoolAddr, address lpAddr) {
        owner = msg.sender;
        jackpotPoolAddress = jackpotPoolAddr;
        consolationPoolAddress = consolationPoolAddr;
        lpAddress = lpAddr;

        enabled = true;
    }

    // Change JackpotPool contract address
    function changeJackpotAddress(address newAddress) public isDisabled isOwner {
        jackpotPoolAddress = newAddress;
    }

    // Change ConsolationPool contract address
    function changeConsolationAddress(address newAddress) public isDisabled isOwner {
        consolationPoolAddress = newAddress;
    }

    // Change Liquidity Pool address
    function changeLpAddress(address newAddress) public isDisabled isOwner {
        lpAddress = newAddress;
    }

    // Enable/Disable manager
    function toggleEnabled() public isOwner {
        enabled = !enabled;
    }

    function setFactoryAddress(address addr) public {
        require(addr == owner, "Not certified factory.");
        factoryAddress = msg.sender;
    }

    // Get last cached information about the last pool
    function getLastPoolInfo() public view returns (uint256, uint256, uint256, address)
    {
        return (lastPoolNumber, lastPoolPrize, lastPoolDrawDatetime, lastPoolAddress);
    }  

    // Update last pool info
    function updateLastPoolInfo(Pool memory pool) public isLastPool {
        setLastPoolInfo(pool);

        finishedPoolsCount += 1;
    }

    function creaNewDefaultPool(uint[14] memory cfg) public isOwner {

        // Incrementing the pool number
        cfg[13] = pools.length + 1;

        // Calling method from another contract
        bytes memory payload = abi.encodeWithSignature("creaNewDefaultPool(address,address,address,uint256[14])", jackpotPoolAddress, consolationPoolAddress, lpAddress, cfg);
        (bool success, bytes memory returnData) = address(factoryAddress).call(payload);
        require(success);

        Pool memory createdPool = abi.decode(returnData, (Pool));

        lastPoolNumber = createdPool.number;
        lastPoolAddress = createdPool.poolAddress;

        pools.push(createdPool);
    }

    function getPoolsList() public view returns (Pool[] memory) {
        return pools;
    }

    // INTERNAL
    function setLastPoolInfo(Pool memory pool) internal {
        lastPoolNumber = pool.number;
        lastPoolDrawDatetime = pool.drawDateTime;
        lastPoolPrize = pool.totalPrize;
        lastPoolAddress = pool.poolAddress;

        if (lastPoolPrize > biggestPrize) {
            biggestAddress = lastPoolAddress;
            biggestDate = lastPoolDrawDatetime;
            biggestPrize = lastPoolPrize;
        }
    }   

    // MODIFIERS
    modifier isOwner() {
        require(msg.sender == owner, "Unauthorized: owner expected");
        _;
    }

    modifier isOwnerCertified(address addr) {
        require(owner == addr, "Unauthorized: manager contract expected");
        _;
    }

    modifier isEnabled() {
        assert(enabled);
        _;
    }

    modifier isDisabled() {
        assert(!enabled);
        _;
    }

    modifier isLastPool() {
        assert(msg.sender == lastPoolAddress);
        _;
    }
}
