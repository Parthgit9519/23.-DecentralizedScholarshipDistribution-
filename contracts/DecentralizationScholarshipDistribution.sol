// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ScholarshipDistribution {
    address public admin;
    uint256 public totalFund;

    struct Student {
        string name;
        address wallet;
        uint256 amount;
        bool received;
    }

    mapping(address => Student) public students;
    address[] public studentList;

    event FundAdded(address indexed donor, uint256 amount);
    event ScholarshipRegistered(address indexed student, string name);
    event ScholarshipDistributed(address indexed student, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    // ✅ Function 1: Add funds to the pool
    function addFunds() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        totalFund += msg.value;
        emit FundAdded(msg.sender, msg.value);
    }

    // ✅ Function 2: Register student
    function registerStudent(string memory _name, address _wallet, uint256 _amount) external {
        require(msg.sender == admin, "Only admin can register students");
        require(students[_wallet].wallet == address(0), "Student already registered");
        require(_amount <= totalFund, "Insufficient funds for allocation");

        students[_wallet] = Student({
            name: _name,
            wallet: _wallet,
            amount: _amount,
            received: false
        });

        studentList.push(_wallet);
        emit ScholarshipRegistered(_wallet, _name);
    }

    // ✅ Function 3: Distribute scholarship
    function distributeScholarship(address _wallet) external {
        require(msg.sender == admin, "Only admin can distribute");
        Student storage s = students[_wallet];
        require(!s.received, "Already received");
        require(s.amount <= totalFund, "Insufficient balance");

        s.received = true;
        totalFund -= s.amount;
        payable(s.wallet).transfer(s.amount);

        emit ScholarshipDistributed(_wallet, s.amount);
    }

    // 🔍 View: Check total students registered
    function getAllStudents() external view returns (address[] memory) {
        return studentList;
    }
}
