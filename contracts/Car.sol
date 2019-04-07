// We will be using Solidity version 0.5.4
pragma solidity ^0.5.0;

// Importing OpenZeppelin's SafeMath Implementation
//import 'https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol';
//import "installed_contracts/zeppelin/contracts/math/Math.sol";

contract Cars {
    //using SafeMath for uint256;

    // data structure that stores a car
    struct Car {
        address ownerAddress;  //owned by owner, assuming owner also driver. 
        string vinNum;
        bytes32 status;
        
        //given by oracle later. 
        uint    manufacturedYear;
        uint    startMilage;
        uint    currentMilage;
        
        uint createdAt;
        uint updatedAt;
        //TODO: add IPFS car profile hash later. 
    }

    // it maps the car's wallet address with the car ID
    mapping (address => uint) public carsIds;

    // Array of Car that holds the list of cars and their details
    Car[] public cars;

    // event fired when an car is registered
    event newCarRegistered(uint id);

    // event fired when the car updates his status or name
    event carUpdateEvent(uint id);


    // Modifier: check if the caller of the smart contract is registered
    modifier checkSenderIsRegistered {
    	require(isRegistered());
    	_;
    }


    /**
     * Constructor function
     */
    constructor() public {
        // NOTE: the first car MUST be emtpy
        addCar(0x0000000000000000000000000000000000000000, "", "");

        // Some dummy data
        addCar(0x3333333333333333333333333333333333333333, "V1234556", "Status1");
        addCar(0x1111111111111111111111111111111111111111, "V1234557", "Status1");
        addCar(0x2222222222222222222222222222222222222222, "V1234558", "Status1");
    }


    /**
     * Function to register a new car.
     *
     * @param vinNum 		The displaying name
     * @param status        The status of the car
     */
    function registerCar(string memory vinNum, bytes32 status) public
    returns(uint)
    {
    	return addCar(msg.sender, vinNum, status);
    }


    /**
     * Add a new car. This function must be private because an car
     * cannot insert another car on behalf of someone else.
     *
     * @param wAddr 		Address wallet of the car
     * @param vinNum		Displaying name of the car
     * @param status    	Status of the car
     */
    function addCar(address wAddr, string memory vinNum, bytes32 status) private
    returns(uint)
    {
        // checking if the car is already registered
        uint carId = carsIds[wAddr];
        require (carId == 0);

        // associating the car wallet address with the new ID
        carsIds[wAddr] = cars.length;
        uint newCarId = cars.length++;

        // storing the new car details
        cars[newCarId] = Car({
        	ownerAddress: wAddr,
            vinNum: vinNum,
        	status: status,
            manufacturedYear: 0,
            startMilage: 0,
            currentMilage: 0,
        	createdAt: now,
        	updatedAt: now
        });

        // emitting the event that a new car has been registered
        emit newCarRegistered(newCarId);

        return newCarId;
    }

    /**
     * Update the car profile of the caller of this method.
     * Note: the car can modify only his own profile.
     * Need less than 4 params, otherwise, get warning. 
     * @param manufacturedYear 	The car's manufacturedYear
     * @param startMilage 	    The car's startMilage
     * @param currentMilage 	The car's currentMilage
     */
    function updateCar(uint manufacturedYear, uint startMilage, uint currentMilage) checkSenderIsRegistered public 
    returns(uint)
    {
    	// An car can modify only his own profile.
    	uint carId = carsIds[msg.sender];

    	Car storage car = cars[carId];
        /* TODO: need validation
            string memory carVinNum = car.vinNum;
            require(carVinNum == vinNum);
        */

    	car.manufacturedYear = manufacturedYear;
    	car.startMilage = startMilage;
        car.currentMilage = currentMilage;

    	car.updatedAt = now;

    	emit carUpdateEvent(carId);

    	return carId;
    }


    /**
     * Get the car's profile information.
     *
     * @param id 	The ID of the car stored on the blockchain.
     */
    function getCarById(uint id) public view
    returns(
    	uint,
    	string memory,
    	bytes32,
    	address,
    	uint,
    	uint
    ) {
    	// checking if the ID is valid
    	require( (id > 0) || (id <= cars.length) );

    	Car memory i = cars[id];

    	return (
    		id,
    		i.vinNum,
    		i.status,
    		i.ownerAddress,
    		i.createdAt,
    		i.updatedAt
    	);
    }


    /**
     * Return the profile information of the caller.
     */
    function getOwnProfile() checkSenderIsRegistered public view
    returns(
    	uint,
    	string memory,
    	bytes32,
    	address,
    	uint,
    	uint
    ) {
    	uint id = carsIds[msg.sender];

    	return getCarById(id);
    }


    /**
     * Check if the car that is calling the smart contract is registered.
     */
    function isRegistered() public view returns (bool)
    {
    	return (carsIds[msg.sender] != 0);
    }


    /**
     * Return the number of total registered cars.
     */
    function totalCars() public view returns (uint)
    {
        return cars.length;
    }

}