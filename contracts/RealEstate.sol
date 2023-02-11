//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";



contract RealEstate is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenid;

    constructor() ERC721("Real estate","RESL"){}
    function mint(string memory tokenuri) public  returns (uint256) {
        _tokenid.increment();
        uint256 newitemid = _tokenid.current();
        _mint(msg.sender,newitemid);
        _setTokenURI(newitemid,tokenuri);
        return newitemid;




        
    }
    function totalSupply() public view returns(uint256){
        return _tokenid.current();    }

}
