// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    address public manager;

    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address from;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
        manager = msg.sender;

        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public restricted wait30 {
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    modifier restricted() {
        require(msg.sender != manager,"You should not me the manager");
        _;
    }

    modifier wait30() {
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Must wait 30 seconds before waving again."
        );
        _;
    }
}
