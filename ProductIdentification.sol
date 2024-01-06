// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;
import './SampleToken.sol';

contract ProductIdentification {
    address public owner;
    uint256 public registrationFee;

    mapping(address => bool) public registeredProducers;
    mapping(uint256 => Product) public registeredProducts;
    mapping(string => uint256) public brandProducts;

    uint256 public productCount;
    SampleToken public sampleToken;

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

    constructor(uint256 _registrationFee, SampleToken _sampleToken) {
        owner = msg.sender;
        registrationFee = _registrationFee;
        sampleToken = _sampleToken;
    }

    function setRegistrationFee(uint256 _fee) external onlyOwner {
        registrationFee = _fee;
    }

    function registerProducer() external {
        sampleToken.transferFrom(msg.sender, address(this), registrationFee);
        sampleToken.transfer(owner, registrationFee);
        registeredProducers[msg.sender] = true;
    }

    function registerProduct(string calldata _name, uint256 _volume) external onlyRegisteredProducer {
        productCount++;
        registeredProducts[productCount] = Product(msg.sender, _name, _volume);
        brandProducts[_name] = productCount;
    }

    function isProducerRegistered(address _producer) external view returns (bool) {
        return registeredProducers[_producer];
    }

    function getProductInfo(uint256 _productId) external view returns (Product memory) {
        require(registeredProducts[_productId].manufacturer != address(0), "Product not registered");
        return registeredProducts[_productId];
    }

    function getBrandInfo(string calldata _name) external view returns (uint256){
        return brandProducts[_name];
    }
}