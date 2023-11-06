// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

import "./ProductIdentification.sol";

contract ProductDeposit {
    address public owner;
    uint256 public storageFeePerVolumeUnit;
    uint256 public maxStorageVolume;
    uint256 public totalAvailableVolume;

    struct Producer {
        uint256 totalDepositedVolume;
        bool isAuthorized;
    }

    struct Store {
        bool isAuthorized;
    }

    mapping(address => Producer) public producers;
    mapping(address => Store) public stores;

    constructor(uint256 _storageFeePerVolumeUnit, uint256 _maxStorageVolume) {
        owner = msg.sender;
        storageFeePerVolumeUnit = _storageFeePerVolumeUnit;
        maxStorageVolume = _maxStorageVolume;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyProducer() {
        require(producers[msg.sender].isAuthorized, "Only authorized producers can call this function");
        _;
    }

    modifier onlyStore() {
        require(stores[msg.sender].isAuthorized, "Only authorized stores can call this function");
        _;
    }

    function setStorageFeePerVolumeUnit(uint256 _fee) external onlyOwner {
        storageFeePerVolumeUnit = _fee;
    }

    function setMaxStorageVolume(uint256 _volume) external onlyOwner {
        maxStorageVolume = _volume;
    }

    function registerProducer() external payable {
        require(msg.value >= storageFeePerVolumeUnit, "Incorrect storage fee");
        require(producers[msg.sender].totalDepositedVolume == 0, "Producer is already registered");
        uint256 volumeDeposited = msg.value / storageFeePerVolumeUnit;
        require(producers[msg.sender].totalDepositedVolume + volumeDeposited <= maxStorageVolume, "Exceeds maximum storage volume");
        producers[msg.sender].totalDepositedVolume += volumeDeposited;
        totalAvailableVolume += volumeDeposited;
        producers[msg.sender].isAuthorized = true;
    }

    function registerStore() external onlyOwner {
        stores[msg.sender].isAuthorized = true;
    }

    // Producătorii pot înregistra retragerea cantităților de produse din depozitele lor
    function registerWithdrawal(uint256 _volume) external onlyProducer {
        require(producers[msg.sender].totalDepositedVolume >= _volume, "Not enough volume to withdraw");
        producers[msg.sender].totalDepositedVolume -= _volume;
        totalAvailableVolume -= _volume;
    }

    // Magazinele autorizate pot înregistra retragerea cantităților de produse din depozitele lor
    function registerStoreWithdrawal(uint256 _volume) external onlyStore {
        require(totalAvailableVolume >= _volume, "Not enough volume available for withdrawal");
        totalAvailableVolume -= _volume;
    }
}
