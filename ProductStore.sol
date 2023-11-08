// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

import "./ProductIdentification.sol";
import "./ProductDeposit.sol";

contract ProductStore {
    address public owner;
    address public identificationOwner;
    address public depositOwner;

    struct Product{
        string name;
        uint256 quantity;
        uint256 pricePerUnit;
    }

    mapping(uint256 => Product) public products;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor (address _identificationOwner, address _depositOwner){
        owner = msg.sender;
        identificationOwner = _identificationOwner;
        depositOwner = _depositOwner;
    }

    function setAddrIdentificationOwner(address _identificationOwner) external onlyOwner{
        identificationOwner = _identificationOwner;
    }

    function setAddrDepositOwner(address _depositOwner) external onlyOwner{
        depositOwner = _depositOwner;
    }

    function addProduct(uint256 _productId, uint256 _quantity, uint256 _pricePerUnit) external{
        ProductIdentification identificationContract = ProductIdentification(identificationOwner);
        require(identificationContract.getProductInfo(_productId).manufacturer != address(0), "Product not registered");
        
        ProductDeposit depositContract = ProductDeposit(depositOwner);
        depositContract.producerWithdrawal(_productId, _quantity);
        products[_productId] = Product(identificationContract.getProductInfo(_productId).name, products[_productId].quantity + _quantity, _pricePerUnit);
    }

    function setPriceProduct(uint256 _productId, uint256 _pricePerUnit) external onlyOwner{
        require(bytes(products[_productId].name).length != 0, "Product is not added");
        products[_productId].pricePerUnit = _pricePerUnit;
    }

     function isProductAuthentic(uint256 _productId) external view returns (Product memory) {
        require(bytes(products[_productId].name).length != 0, "Product doesn't exist");
        require(products[_productId].quantity > 0, "Product is not available");
        return products[_productId];
    }

    function purchaseProduct(uint _productId, uint _quantity) external payable {
        ProductIdentification identificationContract = ProductIdentification(identificationOwner);
        require(bytes(products[_productId].name).length != 0, "Product doesn't exist");
        require(_quantity <= products[_productId].quantity, "Quantity product demand is too high");
        require(msg.value >= products[_productId].pricePerUnit * _quantity, "Insufficient payment");
        
        (bool sentToProducer,) = payable(identificationContract.getProductInfo(_productId).manufacturer).call{value : products[_productId].pricePerUnit * _quantity / 2}("");
        require(sentToProducer, "Couldn't send the change back to the producer");
        (bool sentToOwner,) = payable(owner).call{value : products[_productId].pricePerUnit * _quantity / 2}("");
        require(sentToOwner, "Couldn't send the change back to the owner");
       
        products[_productId].quantity -= _quantity;
        if (msg.value == products[_productId].pricePerUnit * _quantity) {
            return ;
        }
        (bool sentToClient,) = payable(msg.sender).call{value : msg.value - products[_productId].pricePerUnit * _quantity}("");
        require(sentToClient, "Couldn't send the change back to the client");
    }
}