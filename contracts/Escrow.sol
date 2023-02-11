//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
    address public lender;
    address payable public seller;
    address public inspector;
    address public nftaddress;
    mapping(uint256 => uint256) public escrow_amount;
    mapping(uint256 => uint256) public purchase_price;
    mapping(uint256 => address) public  buyer;
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => bool) public inspectorstatus;
    mapping(uint256 => mapping(address => bool)) public approval;
   constructor(

        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftaddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }
    modifier onlySeller() {
        require(msg.sender == seller, "only seller can call this function");
        _;

    }
    modifier onlyBuyer(uint256 _nftid){
        require(msg.sender == buyer[_nftid],"only buyer can call this function");
        _;
    }
    modifier onlyInspector(){
        require(msg.sender == inspector,"only buyer can call this function");
        _;
    }

    function list(uint256 _tokenid, address _buyer, uint escrowamount, uint256 purchaseprice) public payable onlySeller {
        isListed[_tokenid] = true;
        IERC721(nftaddress).transferFrom(seller,address(this), _tokenid);
        buyer[_tokenid] = _buyer;
        escrow_amount[_tokenid]= escrowamount;
        purchase_price[_tokenid]= purchaseprice;
        
    }
    function depositearnest(uint256 _nftid) public payable onlyBuyer(_nftid) 
    {
        require(msg.value >= escrow_amount[_nftid]);


    }
    function approve(uint256 _nftid) public{
        approval[_nftid][msg.sender] = true ;
    }
    receive() external payable{}
    function getBalance() public view returns(uint256){
        return address(this).balance ;
    }
    function updateinspectionstatus(uint256 _nftid, bool _passed) public onlyInspector {
        inspectorstatus[_nftid] = _passed;



    }
     function finalizeSale(uint256 _nftID) public {
        require(inspectorstatus[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchase_price[_nftID]);

        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);

        IERC721(nftaddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }
    function Cancelsale(uint256 _nftid) public {
        if(inspectorstatus[_nftid]== false){
            (bool success,)= payable(buyer[_nftid]).call{value : address(this).balance}("");
            require(success);
    }
        

        else {
            (bool success,)= payable(seller).call{value : address(this).balance}("");
            require(success);
            
        }
    }
    
}


