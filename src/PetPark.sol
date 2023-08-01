//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    // petPark.add(AnimalType.Fish, 5);

    address public owner;
    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    function isValidAnimalType(AnimalType animalType) public pure returns(bool) {
        return (uint(animalType) >= uint(AnimalType.Fish) && uint(animalType) <= uint(AnimalType.Parrot));
    }

    enum Gender {
        Male,
        Female
    }

    struct FactsAboutIdentity {
        Gender gender;
        uint age;
    }

    mapping (AnimalType => uint) public animalCounts;
    mapping(address => FactsAboutIdentity) knownIdentities;
    mapping(address => uint) borrowCount;
    mapping(address => AnimalType) userBorrowedAnimals;

    function add(AnimalType animalType, uint count) public onlyOwner {
        require(isValidAnimalType(animalType), "Invalid animal");
        uint existingCount = animalCounts[animalType];
       animalCounts[animalType] = count + existingCount;
        emit Added(animalType, count);
    }

    function borrow(uint age, Gender gender, AnimalType animalType) public {
        require(age != 0, "Zero age");
        require(isValidAnimalType(animalType), "Invalid animal type");
        FactsAboutIdentity memory facts = FactsAboutIdentity(gender, age);
        if (knownIdentities[msg.sender].age != 0) {
            require(knownIdentities[msg.sender].age == facts.age, "Invalid Age");
            require(knownIdentities[msg.sender].gender == facts.gender, "Invalid Gender");
        } else {
            knownIdentities[msg.sender] = facts;
        }
        require(userBorrowedAnimals[msg.sender] == AnimalType.None, "Already adopted a pet");
        if (gender == Gender.Male) {
            require(animalType == AnimalType.Dog || animalType == AnimalType.Fish, "Invalid animal for men");
        } else {
            if (age < 40) {
                require(animalType != AnimalType.Cat, "Invalid animal for women under 40");
                }
        }
        require(animalCounts[animalType] > 0, "Selected animal not available");
        animalCounts[animalType] = animalCounts[animalType] - 1;
        userBorrowedAnimals[msg.sender] = animalType;
        borrowCount[msg.sender] = borrowCount[msg.sender] + 1;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        require(borrowCount[msg.sender] > 0, "No borrowed pets");
        AnimalType animalType = userBorrowedAnimals[msg.sender];
        userBorrowedAnimals[msg.sender] = AnimalType.None;
        animalCounts[animalType] = animalCounts[animalType] + 1;
        emit Returned(animalType);
    }
}