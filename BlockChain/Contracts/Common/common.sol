// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

enum State {
    Invalid,
    Initialized,
    WaitingClaims,
    Finished,
    Cancelled
} 

struct Pool {
    uint256 number;
    address poolAddress;
    State state;
    uint256 totalPrize; // wei    
    uint256 drawDateTime;
}

struct PoolShareConfig {
    uint mainPrizeShare;
    uint secondPrizeShare;
    uint thirdPrizeShare;
    uint consolationPoolShare;
    uint jackpotPoolShare;
    uint maintenanceFee;
    uint returnToPool;
}

struct PoolPrizeWinnersConfig {
    uint mainPrizeWinners;
    uint secondPrizeWinners;
    uint thirdPrizeWinners;
}

struct PoolGeneralConfig {
    uint timeToDraw;
    uint entryValue;
    uint entriesPerAccount;   
}
