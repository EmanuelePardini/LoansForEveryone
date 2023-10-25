// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanManager {
    //Loan status enum
    enum LoanStatus {
    Active,
    Paid,
    Defaulted,
    Cancelled,
    Requested
    }

    //Loan Structure
    struct Loan {
        address borrower;
        address lender;
        uint256 amount;
        uint256 interestRate;
        uint256 startTime;
        uint256 deadline;
        uint256 penaltyRate;
        uint256 paidAmount;
        LoanStatus status;
    }

    //State variables
    mapping(uint256 => Loan) public loans;
    uint256 public loanCounter;

    //Loan Events
    event LoanCreated(uint256 loanId, address borrower, address lender, uint256 amount, uint256 interestRate, uint256 deadline);
    event LoanPaid(uint256 loanId, uint256 paidAmount);
    event LoanDefaulted(uint256 loanId, uint256 penaltyAmount);
    event LoanCancelled(uint256 loanId);
    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint256 interestRate, uint256 deadline);


    //Constructor
    constructor() {
        loanCounter = 0;
    }

    //Request Loan
    function requestLoan(uint256 _amount, uint256 _interestRate, uint256 _timeInDays) external {
    require(_amount > 0, "Loan amount must be greater than 0.");
    require(_interestRate > 0, "Interest rate must be greater than 0.");
    
    uint256 deadline = block.timestamp + _timeInDays * 1 days;

    loans[loanCounter] = Loan({
        borrower: msg.sender,
        lender: address(0), 
        amount: _amount,
        interestRate: _interestRate,
        startTime: block.timestamp,
        deadline: deadline,
        penaltyRate: _interestRate,
        paidAmount: 0,
        status: LoanStatus.Requested
    });

    emit LoanRequested(loanCounter, msg.sender, _amount, _interestRate, deadline);
    loanCounter++;
}

//Create Loan
function createLoan(uint256 loanId) external {
    require(loanId <= loanCounter, "Invalid loan ID.");
    Loan storage loan = loans[loanId];

    require(loan.status == LoanStatus.Requested, "Loan is not requested.");
    require(loan.lender == address(0), "Loan already has a lender.");
    require(msg.sender != loan.borrower, "Borrower and lender cannot be the same.");

    loan.lender = msg.sender;
    loan.status = LoanStatus.Active; 

    emit LoanCreated(loanId, loan.borrower, msg.sender, loan.amount, loan.interestRate, loan.deadline);
}


    //Repay Loan
    function repayLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Active || loan.status == LoanStatus.Defaulted, "Loan is not active or defaulted.");
        require(msg.sender == loan.borrower, "Only the borrower can repay the loan.");
        require(msg.value >= loan.amount, "Insufficient repayment amount.");

        uint256 interest = LoanLibrary.calculateInterest(loan.amount, loan.interestRate, block.timestamp - loan.startTime);
        uint256 penalty = LoanLibrary.calculatePenalty(loan.amount, loan.deadline, block.timestamp);
        uint256 totalRepayment = loan.amount + interest + penalty;

        loan.paidAmount = totalRepayment;
        loan.status = LoanStatus.Paid;

        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }

        emit LoanPaid(_loanId, totalRepayment);

        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }
    }

    //Default Loan
    function defaultLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Active, "Loan is not active.");
        require(msg.sender == loan.lender, "Only the lender can report default.");

        loan.status = LoanStatus.Defaulted;
        uint256 penalty = LoanLibrary.calculatePenalty(loan.amount, loan.deadline, block.timestamp);
        payable(loan.lender).transfer(penalty);

        emit LoanDefaulted(_loanId, penalty);
    }

    //Cancel Loan
    function cancelLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Active || loan.status == LoanStatus.Requested, "Loan is not active or requested.");
        require(msg.sender == loan.borrower, "Only the borrower can cancel the loan.");

        loan.status = LoanStatus.Cancelled;
        emit LoanCancelled(_loanId);
    }
}




library LoanLibrary {
    function calculateInterest(uint256 principal, uint256 rate, uint256 time) internal pure returns (uint256) {
        
        return (principal * rate * time) / (365 * 10**18);
    }

    function calculatePenalty(uint256 principal, uint256 deadline, uint256 paymentDate) internal pure returns (uint256) {
        if (paymentDate <= deadline) {
            return 0;
        }
        uint256 daysLate = (paymentDate - deadline) / 86400;
        return (principal * daysLate) / (365 * 10**18);
    }
}