// We will be using Solidity version 0.5.4
pragma solidity ^0.4.25;

// Importing OpenZeppelin's SafeMath Implementation
//import 'https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol';
//import "installed_contracts/zeppelin/contracts/math/Math.sol";
//Issuer 0x671441d4369edD97720C31C19f057AB54770c7CE
//Driver 0x2437744d2eEf0E938d5Ddb5dea8af0Da8844cE2c

contract PayPerUses {
    //using SafeMath for uint256;

    struct PayPerUse {
        address userCarAddress;       //address to get user car profile 
        address issuerAddress;        //simply to be 1 issuer right now. 
        uint    offerRate; 

        uint    acceptRate;  
        uint    rewardBalance;        //reward balance
        uint    offeredAt;
        uint    acceptedAt; 
        uint    rewardIssuedAt;
        uint    updatedAt;

        string  status;  //rate offered, accepted, reward issued;
    }

   // Structure
   mapping (address => uint) public optionIds;  //user --> option
   PayPerUse[] public options;

    // important events
    event optionOffered(uint id);
    event optionAccepted(uint id);
    event rewardIssued(uint id);


    // Modifier: check if the caller of the smart contract is registered
    modifier checkSenderIsRegistered {
    	require(isRegistered());
    	_;
    }
   
    //******************************************************************************
   /**
     * Constructor function
     */
    constructor() public {
    }

     /**
     * Check if the car that is calling the smart contract is registered.
     */
    function isRegistered() public view returns (bool)
    {
    	return (optionIds[msg.sender] != 0);
    }

    /**
     * As issuer, call this function to setup offer (sender=issuer)
     *
     * @param userCarAddress     user card address	
     * @param offerRate         offer rate
     */
    function offerOption(address userCarAddress, uint offerRate) public
    returns(uint)
    {
        //TODO: make sure caller is registered issuer. 
    	return addOption(userCarAddress, msg.sender, offerRate);
    }


    /**
     * Add a new car. This function must be private because an car
     * cannot insert another car on behalf of someone else.
     *
     * @param userCarAddress   user car address		
     * @param issuerAddress     issuer address	
     * @param offerRate         offer rate  
     */
    function addOption(address userCarAddress, address issuerAddress, uint offerRate) private
    returns(uint)
    {
        // checking if option is already there. 
        uint optionId = optionIds[userCarAddress];
        require (optionId == 0);

        // associating the car wallet address with the new ID
        optionIds[userCarAddress] = options.length;
        uint newOptionId = options.length++;

        // storing the new car details
        options[newOptionId] = PayPerUse({
        	userCarAddress: userCarAddress,
            issuerAddress: issuerAddress,
            offerRate: offerRate,
            acceptRate: 0,
            rewardBalance: 0,
        	offeredAt: now,
            acceptedAt: 0,
            rewardIssuedAt: 0,
        	updatedAt: now,
            status: "rate offered"
        });


        // emitting the event that a new car has been registered
        emit optionOffered(newOptionId);

        return newOptionId;
    }

  /**
     * Driver (Sender) accept option. 
     *
     * @param issuerAddress     issuer address	
     */
    function acceptOption(address issuerAddress) public
    returns(uint)
    {
         uint optionId = optionIds[msg.sender];
         PayPerUse storage perPerUse = options[optionId];
         
         perPerUse.acceptRate = perPerUse.offerRate;
         perPerUse.acceptedAt = now;
    	 perPerUse.updatedAt = now;
         perPerUse.status = "accept offered";

    	emit optionAccepted(optionId);

    	return optionId;
    }

    /**
     * Issuer (Sender) issue rewards. 
     *
     * @param userCarAddress    user address
     * @param newBalance        balance
     */
    function issueRewards(address userCarAddress, uint newBalance) public
    returns(uint)
    {
        uint optionId = optionIds[userCarAddress];
        PayPerUse storage perPerUse = options[optionId];
         
        perPerUse.rewardBalance = newBalance;
        perPerUse.rewardIssuedAt = now;
    	perPerUse.updatedAt = now;
        perPerUse.status = "reward issued";

    	emit rewardIssued(optionId);

    	return optionId;
    }

    /**
     * Return the number of total registered cars.
     */
    function totalOptions() public view returns (uint)
    {
        return options.length;
    }

     /**
     * Return the profile information of the caller.
     */
    function getOption(address userCarAddress) public view
    returns(
        address,
    	address,
    	uint,
    	uint,
    	uint,
        uint,
    	uint,
    	uint,
        uint
    ) {
    	uint optionId = optionIds[userCarAddress];
        PayPerUse storage perPerUse = options[optionId];
         
    	return (
    	    perPerUse.userCarAddress,
            
    		perPerUse.issuerAddress,
    		perPerUse.offerRate,
    		perPerUse.acceptRate,
    		perPerUse.rewardBalance,
    		perPerUse.offeredAt,
            perPerUse.acceptedAt,
            perPerUse.rewardIssuedAt,
            perPerUse.updatedAt
    	);
    }

}