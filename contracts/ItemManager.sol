pragma solidity 0.8.12;

import "./Item.sol";
import "./Ownable.sol";


contract ItemManager is Ownable {


    mapping(uint => S_Item) public items; 
    uint itemIndex;

    function createItem(string memory _itemIndex, uint _itemPrice) public onlyOwner{
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _itemIndex;
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;
        itemIndex++;

        //emit ItemCreated(itemIndex - 1, _identifier);
        emit SupplyChainStep(itemIndex, items[itemIndex]._state, address(item));
    }

    function triggerPayment(uint _itemIndex) public payable onlyOwner{
        require(msg.value == items[_itemIndex]._itemPrice, "Only full payments are accepted");
        require(SupplyChainState.Created == items[_itemIndex]._state, "Item is further in the chain");
       
        
        items[_itemIndex]._state = SupplyChainState.Paid;
        //emit ItemPaid(_itemIndex, msg.value);
        emit SupplyChainStep(_itemIndex, items[_itemIndex]._state, address(items[_itemIndex]._item));
    }

    function triggerDelivery(uint _itemIndex) public payable onlyOwner{
        require(msg.value == items[_itemIndex]._itemPrice, "Only full payments are accepted");
        require(SupplyChainState.Paid == items[_itemIndex]._state, "Item should be created & paid");
        items[_itemIndex]._state = SupplyChainState.Delivered;

        //event ItemDeliveryTriggered(uint _itemIndex);
        emit SupplyChainStep(_itemIndex, items[_itemIndex]._state, address(items[_itemIndex]._item));
    }



    // ========== EVENTS ==========
    event ItemCreated(uint index, string _identifier);

    event ItemPaid(uint itemIndex, uint valuePaid);

    event ItemDeliveryTriggered(uint itemIndex);

    event SupplyChainStep(uint _itemIndex, SupplyChainState _step, address _itemAddress);

    // ========== STRUCTS ==========

    struct S_Item { 
        Item _item;
        string _identifier; 
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }

    // ========== ENUMS ==========

    enum SupplyChainState {Created, Paid, Delivered }

}