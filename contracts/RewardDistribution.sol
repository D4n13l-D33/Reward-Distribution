// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";


contract RewardDistribution is VRFConsumerBaseV2{
    address owner;
    //subscription ID gotten from chainlink platform
    uint64 s_subscriptionId;
    //create an instance of the VRF Coordinator interface to use in our contract
    VRFCoordinatorV2Interface COORDINATOR;
    //vrfCoordinator for Sepolia
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    //key has for sepolia
    bytes32 s_keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    //maximum gas limit to use when generating random numbers
    uint32 callbackGasLimit = 40000;
    //number of confirmations before random numbers are generated
    uint16 requestConfirmations = 3;
    //number of randoms numbers returned by chainlink vrf
    uint32 numWords;

    address NFTaddress;
    address tokenAddress;

    uint public totalReward;

    uint deadline;

    uint maxNoOfEntries;

    struct participants{
        address partAdd;
        uint numOFEntries;
        uint reward;
    }

    //keeps track of participants registered on the platform
    mapping (address => participants) public registeredParticipants;

    mapping (address => bool) public alreadyRegistered;

    //records entries by users 
    address [] entries;

    //records winners gotten from random numbers generated by chainlink vrf
    address [] winners;

    constructor(
        address _NFTAddress, 
        address _TokenAddress,
        uint _TotalRewards,
        uint _maxNoOfEntries,
        uint64 subscriptionId,
        uint32 _numberOFWinners

        ) VRFConsumerBaseV2(vrfCoordinator) {
        owner = msg.sender;
        NFTaddress = _NFTAddress;
        tokenAddress = _TokenAddress;
        totalReward = _TotalRewards;
        maxNoOfEntries = _maxNoOfEntries;
        deadline = 3 minutes;

        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        numWords = _numberOFWinners;
    }

    /* This function registers users
        by assigning true to the mapping that tracks if users are registered or not
        and assigns who is calling the function to partAdd
        
    */
    function register()  external{
        require(msg.sender != address(0));
        require(alreadyRegistered[msg.sender] == false);

        alreadyRegistered[msg.sender] == true;

        registeredParticipants[msg.sender].partAdd = msg.sender;

        

    }

    /* 
    This function checks if a user is registered

    check the number of times the user as sumbitted and entry and the number of entries is limited to maxNoOfEntries

    the function allows users to send a particular NFT to the contract then it records their entry by incrementing num of Entries by 1

    the pushes the address of the caller to entries this way users can submit entry more than once and their entries could occupy different positions in the array
    */
    function joinEvent(uint tokenID) external payable{
        require(alreadyRegistered[msg.sender] == true, "Not Registered");
        require(registeredParticipants[msg.sender].numOFEntries <= maxNoOfEntries, "You have Maxed the number of Entries");

        ERC721(NFTaddress).transferFrom(msg.sender, address(this), tokenID);

        registeredParticipants[msg.sender].numOFEntries = registeredParticipants[msg.sender].numOFEntries + 1;

        entries.push(msg.sender);

        }
    //the function calls the requestRandomWords function in the VRF contract it processes and returns an array of randomwords from the oracle
    function getWinners() external{
        onlyOwner();

        COORDINATOR.requestRandomWords(s_keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
        }
    /*
    this function is used to receive the randomWords from the chainlink oracle and converts the array of random string of numbers to an array of numbers within 0 to the entries.length
    
    this random numbers within 0 to entries.length are matched to the items on array entries and the resulting address is pushed to array winners
    */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        onlyOwner();

        uint32 index;
        uint entLength = entries.length;
        // transform the result to a number between 1 and Entries.length inclusively
        for(uint16 i; i <= numWords; i++){

        uint256 realValue = (randomWords[index] % entLength) + 1;

        winners.push(entries[realValue]);

        index ++;

        }

       
    }
    /*
    this function calculates the rewards of each users by using percentage of the number of winners to the total reward
    then the reward in an ERC20 token to each winners in the array of winners, this allows for a users entries to both be chosen or both not chosen if unlucky
    */
    function distributeReward()external {
        onlyOwner();

        uint index;

        for(uint16 i; i<= winners.length; i++){
            uint reward = totalReward * numWords/100;
            participants storage winner = registeredParticipants[winners[index]];

            winner.reward = reward;

            IERC20(tokenAddress).transfer(winner.partAdd, winner.reward);

            index++;
        }
    }
    
    function onlyOwner() private view {
        require(msg.sender == owner);
    }
}