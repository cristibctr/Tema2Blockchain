// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

import "./ProductIdentification.sol";

contract ProductDeposit {
    address public owner;
    uint256 public storageFeePerVolumeUnit;
    uint256 public maxStorageVolume;

    struct Store {
        string location;
        bool isAuthorized;
    }

    mapping(address => Store) public authorizedStore;
    mapping(uint256 => uint256) public depositProduct;

    constructor(uint256 _storageFeePerVolumeUnit, uint256 _maxStorageVolume) {
        owner = msg.sender;
        storageFeePerVolumeUnit = _storageFeePerVolumeUnit;
        maxStorageVolume = _maxStorageVolume;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyProducer(uint256 _productId, address _identificationOwner) {
        ProductIdentification identificationContract = ProductIdentification(_identificationOwner);
        require(identificationContract.getProductInfo(_productId).manufacturer == msg.sender, "Only authorized producers can call this function");
        _;
    }

    modifier onlyStore(uint256 _productId, address _identificationOwner) {
        ProductIdentification identificationContract = ProductIdentification(_identificationOwner);
        require(authorizedStore[identificationContract.getProductInfo(_productId).manufacturer] == msg.sender, "Only authorized stores can call this function");
        _;
    }


    function setStorageFeePerVolumeUnit(uint256 _storageFeePerVolumeUnit) external onlyOwner {
        storageFeePerVolumeUnit = _storageFeePerVolumeUnit;
    }

    function setMaxStorageVolume(uint256 _maxStorageVolume) external onlyOwner {
        require(maxStorageVolume <= _maxStorageVolume, "Maximum storage volume can't be smaller than the already deposited volume");
        maxStorageVolume = _maxStorageVolume;
    }

    function registerProductStorage(uint256 _productId, address _identificationOwner, uint256 _quantity) external onlyProducer(_productId, _identificationOwner) payable {
        require(msg.value >= storageFeePerVolumeUnit * _quantity, "Incorrect storage fee");
        ProductIdentification identificationContract = ProductIdentification(_identificationOwner);
        require(identificationContract.getProductInfo(_productId).volume >= _quantity, "Incorect product quantity");
        require(maxStorageVolume >= _quantity, "Exceeds maximum storage volume");

        depositProduct[_productId] += _quantity;
        maxStorageVolume -= _quantity;
        (bool sentToOwner,) = payable(owner).call{value: storageFeePerVolumeUnit * _quantity}("");
        require(sentToOwner, "Couldn't send the change back to the owner");

        if (msg.value == storageFeePerVolumeUnit * _quantity) {
            return;
        }
        (bool sentToProducer,) = payable(msg.sender).call{value: msg.value - (storageFeePerVolumeUnit * _quantity)}("");
        require(sentToProducer, "Couldn't send the change back to the producer");
    }

    // Autorizeaza / scoatere autorizare magazin
    function registerStore(string calldata _location, bool _isAuthorized) external onlyProducer {
        authorizedStore[msg.sender] = Store(_location, _isAuthorized);
    }

    // Producătorii pot înregistra retragerea cantităților de produse din depozitele lor
    function producerWithdrawal(uint256 _productId, uint256 _volume) external onlyProducer {
        require(depositProduct[_productId] >= _volume, "Not enough volume available for withdrawal");
        depositProduct[_productId] -= _volume;
        maxStorageVolume += _volume;
    }

    // Magazinele autorizate pot înregistra retragerea cantităților de produse din depozitele lor
    function storeWithdrawal(uint256 _productId, string _location, uint256 _volume) external onlyStore {
        require(authorizedStore[msg.sender].location == _location, "Unexpected store location");
        require(authorizedStore[msg.sender].isAuthorized == true, "Store is not authorized to withdraw");
        require(depositProduct[_productId] >= _volume, "Not enough volume available for withdrawal");
        depositProduct[_productId] -= _volume;
        maxStorageVolume += _volume;
    }

    // Obtine cantitatea unui produs din depozit
    function getAvailableQuantity(uint256 _productId) external view returns (uint256) {
        return depositProduct[_productId];
    }
}
