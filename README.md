# LoansForEveryone
LoansForEveryone is a smart contract written in Solidity to manage user loans on the ethereum blockchain 

## Features:
 Ask for a Loan, Grant a Loan with interests, Loan management with penalty on late payments.


### LoanManager.sol

- **Purpose:** The `LoanManager` contract serves as the core component of the lending platform. It tracks loans and handles their lifecycle.
- **Structs and Enums:**
  - `Loan`: The contract defines a `Loan` struct that stores essential loan details, including borrower, lender, amount, interest rate, time frame, and loan status (using an enum).
- **Functions:**
  - `createLoan`: Allows users to create a loan request, specifying the borrower, amount, interest rate, and time frame.
  - `repayLoan`: Enables borrowers to repay loans, calculating interest and penalties automatically.
  - `defaultLoan`: Allows lenders to report loan defaults, triggering penalty calculations.
  - `cancelLoan`: Permits borrowers to cancel loan requests.
- **Library Integration:** The contract integrates the `LoanLibrary.sol` library to calculate interest and penalties.

### LoanLibrary.sol

- **Purpose:** The `LoanLibrary` library provides functions for calculating interest and penalties.
- **Functions:**
  - `calculateInterest`: Computes the interest amount based on the principal, interest rate, and time.
  - `calculatePenalty`: Calculates penalties for late loan repayments.

## Technical Choices

### Solidity

Solidity was chosen as the smart contract programming language due to its compatibility with the Ethereum blockchain and a wide developer community. It enables secure and transparent contract execution.

### Use of Enum for Loan Status

To represent loan statuses (e.g., active, paid, defaulted, canceled), we use an enum (`LoanStatus`) for clarity and to minimize error-prone integer values.

### Interest and Penalty Calculation

We employ the `LoanLibrary` for accurate interest and penalty calculations. By using a library, we maintain clean and reusable code, reducing the risk of calculation errors.

### Sepolia

This smart contract has been deployed on the Sepolia Testnetwork at the following address: [Sepolia Testnetwork](https://sepolia.etherscan.io/address/0xf8588DC0c87c5B605C2333eeD1FA385f43424b8D)

## Author:

This web app was created by [Emanuele Pardini](http://emanuelepardini.altervista.org/).
Enjoy!
