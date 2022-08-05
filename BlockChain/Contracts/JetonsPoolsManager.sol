// SPDX-License-Identifier: NO-LICENSE

pragma solidity ^0.8.15;

import "./Common/common.sol";
import "./JetonsDefaultPool.sol";

contract JetonsPoolsManager {
    address public managerAddress;
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
        managerAddress = msg.sender;
        jackpotPoolAddress = jackpotPoolAddr;
        consolationPoolAddress = consolationPoolAddr;
        lpAddress = lpAddr;

        enabled = true;
    }

    // Change JackpotPool contract address
    function changeJackpotAddress(address newAddress) public isDisabled onlyManager {
        jackpotPoolAddress = newAddress;
    }

    // Change ConsolationPool contract address
    function changeConsolationAddress(address newAddress) public isDisabled onlyManager {
        consolationPoolAddress = newAddress;
    }

    // Change Liquidity Pool address
    function changeLpAddress(address newAddress) public isDisabled onlyManager {
        lpAddress = newAddress;
    }

    // Enable/Disable manager
    function toggleEnabled() public onlyManager {
        enabled = !enabled;
    }

    // Get last cached information about the last pool
    function getLastPoolInfo() public view returns (uint256, uint256, uint256, address)
    {
        return (lastPoolNumber, lastPoolPrize, lastPoolDrawDatetime, lastPoolAddress);
    }  

    // Update last pool info
    function updateLastPoolInfo(address poolAddr, uint256 poolNumber, uint256 poolPrize, uint256 drawDate) public isLastPool {
        setLastPoolInfo(poolAddr, poolNumber, poolPrize, drawDate);

        finishedPoolsCount += 1;
    }

    function creaNewDefaultPool(uint[14] memory cfg) public onlyManager {

        // Add the pool number
        cfg[13] = pools.length + 1;

        JetonsDefaultPool defaultPool = new JetonsDefaultPool(managerAddress, jackpotPoolAddress, consolationPoolAddress, lpAddress, cfg);

        Pool memory pool;
        pool.number = pools.length + 1;
        pool.poolAddress = address(defaultPool);

        setLastPoolInfo(pool.poolAddress, pool.number, 0, 0);

        pools.push(pool);
    }

    function getPoolsList() public view returns (Pool[] memory) {
        return pools;
    }

    // INTERNAL
    function setLastPoolInfo(address poolAddr, uint256 poolNumber, uint256 poolPrize, uint256 drawDate) internal {
        lastPoolNumber = poolNumber;
        lastPoolDrawDatetime = drawDate;
        lastPoolPrize = poolPrize;
        lastPoolAddress = poolAddr;

        if (lastPoolPrize > biggestPrize) {
            biggestAddress = lastPoolAddress;
            biggestDate = lastPoolDrawDatetime;
            biggestPrize = lastPoolPrize;
        }
    }
    
    // MODIFIERS
    modifier onlyManager() {
        assert(msg.sender == managerAddress);
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
