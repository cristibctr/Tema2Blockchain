// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

contract ProductIdentification {
    address public owner;
    uint256 public registrationFee;
    mapping(address => bool) public registeredProducers;
    mapping(uint256 => Product) public registeredProducts;
    uint256 public productCount;

    struct Product {
        address manufacturer;
        string name;
        uint256 volume;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyRegisteredProducer() {
        require(registeredProducers[msg.sender], "Only registered producers can call this function");
        _;
    }

    constructor(uint256 _registrationFee) {
        owner = msg.sender;
        registrationFee = _registrationFee;
    }

    function setRegistrationFee(uint256 _fee) external onlyOwner {
        registrationFee = _fee;
    }

    function registerProducer() external payable {
        require(msg.value == registrationFee, "Incorrect registration fee");
        registeredProducers[msg.sender] = true;
        if (msg.value > registrationFee) {
            payable(msg.sender).transfer(msg.value - registrationFee);
        }
    }

    function registerProduct(string calldata _name, uint256 _volume) external onlyRegisteredProducer {
        productCount++;
        registeredProducts[productCount] = Product(msg.sender, _name, _volume);
    }

    function isProducerRegistered(address _producer) external view returns (bool) {
        return registeredProducers[_producer];
    }

    function getProductInfo(uint256 _productId) external view returns (Product memory) {
        return registeredProducts[_productId];
    }
}

