// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    
    string public name = "Sample Token";
    string public symbol = "TOK";

    uint256 public totalSupply;
    
    event Transfer(address indexed _from,
                   address indexed _to,
                   uint256 _value);

    event Approval(address indexed _owner,
                   address indexed _spender,
                   uint256 _value);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply) {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        emit Transfer(msg.sender, _to, _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        emit Approval(msg.sender, _spender, _value);
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        emit Transfer(_from, _to, _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        return true;
    }
}