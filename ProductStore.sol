// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

import "./ProductIdentification.sol";
import "./ProductDeposit.sol";

contract ProductStore {
    address public owner;
    address public identificationOwner;
    address public depositOwner;
    uint256 public productCount;

    struct Product{
        uint256 id;
        address productOwner;
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

    //Adaugam un produs in magazin cu un volum disponibil din depozit
    function addProduct(uint256 _productId, uint256 _id, uint256 _quantity, uint256 _pricePerUnit) external{
        ProductIdentification identificationContract = ProductIdentification(identificationOwner);
        require(identificationContract.getProductInfo(_productId).manufacturer != address(0), "Product not registered");
        
        // ProductDeposit depositContract = ProductDeposit(productDepositContract);
        // require(depositContract.getAvailableQuantity(_productId) >= _quantity, "Not enough quantity in deposit");
        
        productCount += 1;
        products[productCount] = Product(_id, identificationContract.getProductInfo(_productId).manufacturer, 
                                            identificationContract.getProductInfo(_productId).name, _quantity, _pricePerUnit);
    }

    // Setam un nou pret pentru un produs
    function setPriceProduct(uint256 _productCount, uint256 _pricePerUnit) external{
        require(_productCount <= productCount, "Product is not valid");
        products[_productCount].pricePerUnit = _pricePerUnit;
    }

    // Setam o noua cantitate a produsului care va fi actualizata si in depozit, daca e posibil
    function setNewQuantity(uint256 _productCount, uint256 _quantity) external{
        
        //Trebuie de modificat pentru a se face update si la depozit
        //De asemenea de verificat daca noua cantitate necesara poate fi obtinuta din ce se afla in depozit

        products[_productCount].quantity = _quantity;
    }

    // Produsul este autentic si disponibil
     function isProductAuthentic(uint256 _productId) external view returns (Product memory) {
        require(_productId <= productCount, "Product is not valid");
        require(products[_productId].quantity > 0, "Product is not disponible");
        return products[_productId];
    }

    // Functie pure (cea mai eficienta) pentru operatii matematice ce nu influenteaza variabilele din store
    //Calculeaza pretul total de platit de user
    function totalPrice(uint256 _price, uint256 _quantity) private pure returns (uint256){
        return (_price * _quantity);
    }

    // Achizitionam un produs
    function purchaseProduct(uint _productId, uint _quantity) external payable {
        //Verificam daca produsul exista, cantitatea ceruta nu e prea mare si plata este insuficienta
        require(_productId <= productCount, "Product is not valid");
        require(_quantity <= products[_productId].quantity, "Quantity product demand is too high");
        require(msg.value >= totalPrice(products[_productId].pricePerUnit, _quantity), "Insufficient payment");
        
        // Transferăm jumătate din preț producătorului si jumatate celui ce detine magazinul
        uint256 price = totalPrice(products[_productId].pricePerUnit, _quantity);
        payable(products[_productId].productOwner).transfer(price / 2);
        payable(owner).transfer(price / 2);
        
        // Scădem cantitatea din stoc
        products[_productId].quantity -= _quantity;
        
        // Returnăm restul plătit
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }
}