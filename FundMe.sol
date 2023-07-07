// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
// import "./PriceConverter.sol";
error NotOwner();


contract FundMe{
    // using PriceConvertor for uint256;
    uint256 public constant minETH=5400000000000000;
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;
    mapping(address => bool) public owners;

    address public immutable deployer;

    constructor(){
        deployer=msg.sender;
        owners[deployer]=true;
        //construct get calls imediately while deployign itself so whoever is deploying will be set as owner 
    }

    //function to take funding
    function fund() public payable {
        
         require(msg.value>=minETH,"Didn't send Enough");
         if(addressToAmountFunded[msg.sender]==0){
             //if not present then add in the array
             funders.push(msg.sender);
            addressToAmountFunded[msg.sender]=msg.value;
         }
         else{
             //if already present just add amount in his contribution
             addressToAmountFunded[msg.sender]+=msg.value;
         }
    }
    //function to withdraw the funded amout
    function withdraw() public onlyOwners{
        //reseting the mapping
        for(uint256 i=0;i<funders.length;i++){
            addressToAmountFunded[funders[i]]=0;
        }
        //resetting the array
        funders=new address[](0); // (0) means it will have 0 elements intially

        (bool call,)=payable(msg.sender).call{value: address(this).balance}("");
        require(call,"Call Failed");
    }
    //function to tranfer owner ship
    function tranferOwnership(address a) public  onlyDeployer{
        owners[a]=true;
    }


    modifier onlyOwners{
        if(owners[msg.sender]!=true) {revert NotOwner();}
        _;
    }
    modifier onlyDeployer{
        if(msg.sender!=deployer) {revert NotOwner();}
        _;
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}
