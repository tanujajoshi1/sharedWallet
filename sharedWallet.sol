 pragma solidity ^0.6.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

/********************************************************************************************/
/*******************************************************************************************/

contract Allowance is Ownable{
    
    using SafeMath for uint256;
    mapping(address=>uint256)public allowance;
    
    event allowanceChanged(address indexed towhom, address indexed fromwhom, uint256 old_amount, uint256 new_amount);
    //who is allowed to withdraw from allowance and how much amount
    function setAllowance(uint256 _amount, address payable _who)public onlyOwner{
        emit allowanceChanged(_who,msg.sender,allowance[_who],_amount);
        allowance[_who]=allowance[_who].add(_amount);
    }
    
    function reduceAllowance(address _who, uint256 _amount)internal{
        emit allowanceChanged(_who, msg.sender,allowance[_who],allowance[_who].add(_amount));
        allowance[_who]=allowance[_who].sub(_amount);
    }
    
    function isOwner()internal view returns(bool){
        return owner()==msg.sender;
    }
    
    //renounceOwnershipt--->Nobody is owner of the smart contract anymore. But here we don't need such a function
    function renounceOwnership()public onlyOwner override{
        revert("this smart contract doesn't allow renounce ownershipt");
    }
    
    //modifier function
    modifier ownerOrAllowed(uint256 _amount){
        require(isOwner()||allowance[msg.sender]>=_amount,"You are not allowed");
        _;
    }
    
}
/********************************************************************************************/
/*******************************************************************************************/

contract sharedWallet is Allowance{
    
    event moneySent(address indexed _to,uint256 _amount);
    event moneyReceived(address indexed _from, uint256 _amount);
    
    //reduce the allowance by _amount number
    function withdrawMoney(uint256 _amount, address payable  _to)public ownerOrAllowed(_amount){
        if(!isOwner()){
            reduceAllowance(msg.sender,_amount);
        }
        emit moneySent(_to, _amount);
       _to.transfer(_amount);
       
    }
    //fallback will add money to smart contract
    fallback() external payable{
      emit moneyReceived(msg.sender,msg.value);  
    }
    
}