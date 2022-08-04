// SPDX-License-Identifier: NO-LICENSE

pragma solidity ^0.8.15;

enum State {
    Opened,
    WaitingClaims,
    Finished,
    Cancelled
} // Pool state

struct Pool {
    uint256 number;
    address poolAddress;
    State state;
    uint256 totalPrize; // wei    uint256 drawDateTime;
}
