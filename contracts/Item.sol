pragma solidity 0.8.12;

import "./ItemManager.sol";
import "./Ownable.sol";

// responsible for taking payments and handling payments back 
contract Item is Ownable {

    uint public priceInWei;
    uint public pricePaid;
    uint public index;
    ItemManager parentContract;
    
    constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(pricePaid == 0, "Item is paid already");
        require(priceInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;           
        //address(parentContract).transfer(msg.value); - high level call, consumes more gas

        // low level call, consumes less gas, but more risky.
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)",index));
        require(success, "The transaction wasn't successfull, canceling");
    }

    fallback () external {}
}