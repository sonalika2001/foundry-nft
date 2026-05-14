// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721{
    // errors
    // error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood{
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

// passing base64 encoded string as the image uri, which will be passed as a param inside the json that is returned by the tokenURI function
    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721("Mood NFT", "MN"){
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri ;
    }

    function mintNft() public {
        // _safeMint(to, tokenId);
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        //only want nft owner to be able to flip mood
        _checkAuthorized(ownerOf(tokenId), msg.sender, tokenId);
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY){
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }
     
    //need to append to the start of the base64 encoded string so that it can be decoded by the browser
    function _baseURI() internal pure override returns(string memory){
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory){
        string memory imageURI;
        if (s_tokenIdToMood[tokenId]==Mood.HAPPY){
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }
//using openzeppelins' base64 lib to encode json metadata, concat with the baseuri
 return string(abi.encodePacked(_baseURI(),Base64.encode(bytes(
  abi.encodePacked(
    '{"name: "',
    name(),
    '", description: "An NFT that reflects your mood!", "attributes": [{"trait_type": "Mood", "value": 100}], "image": ',
    imageURI,
    '"}'
  )
))));

    }

}