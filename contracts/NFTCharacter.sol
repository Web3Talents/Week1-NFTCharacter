// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
Here we have imported 2 contracts. To build NFTs, we use the erc721 token standard
        **Make sure you learn what functions are in every ERC contract**
If we are to set a price for our NFT minting, we will need a token to act as our currency, hence the IERC20 contract        
*/

contract NFTCharacter is ERC721 {
    //Define Error Messages
    error InvalidInput();
    error Unauthorized();
    error InsufficientFunds();
    error ApproveOrIncreaseAllowance();
    error TxFailed();
    //since we want to set a price for the minting, we need an admin address who will run functions such as setPrice
    address private admin;
    address private feeCollector;
    IERC20 private buyCurrency;

    uint private buyPrice;
    uint private tknIdCounter;

//we will store the attributes in a struct
    struct CharAttributes {
        uint8 level;
        uint8 xp;
        uint128 power;
        uint maxXp;
    }
    //mapping for tokenID to the Attributes
    mapping (uint => CharAttributes) public attributes;
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        
        //set msg.sender(the deployer of the contract) to be the admin
        admin = msg.sender;
    }
    //create a modifier to restrict functions that only the admin can run.
    modifier onlyAdmin {
    if(msg.sender!= admin) revert Unauthorized();
    _;        
    }
    //Let's have the admin set the currency used to mint an nft, the fee collecting address and the price of minting
    function setCurrency(address _currencyAddress) external onlyAdmin{
       //input validation 
       if(_currencyAddress==address(0)) revert InvalidInput();
        buyCurrency = IERC20(_currencyAddress);
    }
    function setPrice(uint _amount) external onlyAdmin{
        if(_amount==0) revert InvalidInput();
        buyPrice = _amount;
    }
    function setFeeCollector(address _address) external onlyAdmin{
        if(_address== address(0)) revert InvalidInput();
        feeCollector = _address;
    }

    function mintCharacter() external{
        //check if the user has approved, and has enough tokens to mint
        if(buyCurrency.balanceOf(msg.sender)<buyPrice) revert InsufficientFunds();
        if(buyCurrency.allowance(msg.sender, address(this))<buyPrice) revert ApproveOrIncreaseAllowance();
        // if the amount is successfully transferred to fee collector, mint to caller address
       (bool Success) =  buyCurrency.transferFrom(msg.sender, feeCollector, buyPrice);
        if(Success){
            uint tokenID = ++tknIdCounter;
            _mint(msg.sender, tokenID);
            CharAttributes storage character = attributes[tokenID];
            character.level = 1;
            character.xp = 0;
            character.maxXp = 100;
            character.power = 100;
        }else{
            revert TxFailed();
        }


    }

}
