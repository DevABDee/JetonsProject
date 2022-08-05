// SPDX-License-Identifier: NO-LICENSE

pragma solidity ^0.8.15;

import "./Common/common.sol";

contract JetonsDefaultPool {
    address public immutable factoryAddress;
    address public immutable managerAddress;
    address public immutable jackpotPoolAddress;
    address public immutable consolationPoolAddress;
    address public immutable lpAddress;

    PoolShareConfig public shareConfig;
    PoolPrizeWinnersConfig public winnersConfig;
    PoolGeneralConfig public generalConfig;

    Pool public pool;

    struct Winner {
        uint8 index;
        uint amount;
    }

    mapping(address=>uint8) public entryList; // List of all entries
    mapping(address=>Winner) public winnersMapping; // List of winner + value to be claimmed
    Winner[] public claimList; // List of claims to be done

    constructor(address _managerAddress, address _jackpotPoolAddr, address _consolationPoolAddr, address _lpAddress, uint[14] memory cfg) {

        // Init params
        factoryAddress = msg.sender;
        managerAddress = _managerAddress;
        jackpotPoolAddress = _jackpotPoolAddr;
        consolationPoolAddress = _consolationPoolAddr;
        lpAddress = _lpAddress;

        shareConfig.mainPrizeShare = cfg[0];
        shareConfig.secondPrizeShare = cfg[1];
        shareConfig.thirdPrizeShare = cfg[2];
        shareConfig.maintenanceFee = cfg[3];
        shareConfig.returnToPool = cfg[4];
        shareConfig.consolationPoolShare = cfg[5];
        shareConfig.jackpotPoolShare = cfg[6];

        winnersConfig.mainPrizeWinners = cfg[7];
        winnersConfig.secondPrizeWinners = cfg[8];
        winnersConfig.thirdPrizeWinners = cfg[9];

        generalConfig.timeToDraw = cfg[10];
        generalConfig.entryValue = cfg[11];
        generalConfig.entriesPerAccount = cfg[12];

        pool.number = cfg[13];

        pool.state = State.Invalid;

        require(validatePoolShareConfig());
        require(validatePoolWinnersConfig());
        require(validatePoolGeneralConfig());

        pool.poolAddress = address(this);
        pool.state = State.Initialized;
    }

    function draw() onlyManager isInitialized public {
        // Draw prizes
    }

    function cancel() onlyManager isInitialized public {
        // Cancel the pool and return values
    }

    function getTokensBalance() onlyManager public view returns (uint) {
        // Return the amount of token on contract's wallet
        return address(this).balance;
    }

    function addTokensToPool() onlyManager isInitialized public payable {
        // Draw prizes
    }

    function participate() isInitialized public payable {
        // Register to draw
        require(msg.value >= generalConfig.entryValue, "Amount is not enough.");

        uint8 entryCount = entryList[msg.sender];

        require(entryCount < generalConfig.entriesPerAccount, "Max number of entries reached.");

        entryList[msg.sender] += 1;
    }

    function claim() isWinner isWaitingClaims public {
        // Send winner tokens
    }

    // INTERNAL
    function validatePoolShareConfig() internal view returns (bool) {
        uint shareSum = (shareConfig.mainPrizeShare + shareConfig.secondPrizeShare + shareConfig.thirdPrizeShare
                                + shareConfig.maintenanceFee + shareConfig.returnToPool + shareConfig.consolationPoolShare
                                + shareConfig.jackpotPoolShare);

        require(shareSum == 100, "Pool prize share must be equals to 100%");

        return true;
    }

    function validatePoolWinnersConfig() internal view returns (bool) {
        require(winnersConfig.mainPrizeWinners > 0, "Theres is no winner for main prize");

        return true;
    }

    function validatePoolGeneralConfig() internal view returns (bool) {
        require(generalConfig.entriesPerAccount > 0, "Entries per account should be at least 1");
        require(generalConfig.entryValue > 0, "Entry value should be > 0");
        require(generalConfig.timeToDraw > block.timestamp + (1 * 23 * 60), "Time to draw need to be at least 24h ahead");

        return true;
    }

    // MODIFIERS
    modifier onlyFactory() {
        assert(msg.sender == factoryAddress);
        _;
    }

    modifier onlyManager() {
        assert(msg.sender == managerAddress);
        _;
    }

    modifier isWinner() {
        assert(winnersMapping[msg.sender].amount > 0);
        _;
    }
    
    modifier isWaitingClaims() {
        assert(pool.state == State.WaitingClaims);
        _;
    }

    modifier isInitialized() {
        assert(pool.state == State.Initialized);
        _;
    }
}