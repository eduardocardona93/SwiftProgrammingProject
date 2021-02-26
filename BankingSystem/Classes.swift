//
//  Classes.swift
//  BankingSystem
//
//  Created by user192101 on 2/23/21.
//

import Foundation


// Client class 
class Client {
    var cliFirstName: String // client First Name
    var cliLastName: String // client Last Name
    var cliId: Int // client Id
    var cliAddress: String // client Address
    var cliPhoneNo: String // client Phone No
    var cliPin: String // client Pin
    
    // Client class constructor
    init( firstName: String, lastName: String, id: Int, address: String, phoneNo: String ) {
        self.cliFirstName = firstName
        self.cliLastName = lastName
        self.cliId = id
        self.cliAddress = address
        self.cliPhoneNo = phoneNo
        self.cliPin = "1234"
    }

    init( firstName: String, lastName: String, id: Int, address: String, phoneNo: String, pin: String ) {
        self.cliFirstName = firstName
        self.cliLastName = lastName
        self.cliId = id
        self.cliAddress = address
        self.cliPhoneNo = phoneNo
        self.cliPin = pin
    }
    // function to return the full name (first + last name)
    func fullName() -> String {
        return self.cliFirstName + " " + self.cliLastName
    }

    // function to print the client attributes  (except the pin)
    func printClientDetails(){
        print("First Name : \(self.cliFirstName), Last Name : \(self.cliLastName), Id : \(self.cliId), Address : \(self.cliAddress), Phone No : \(self.cliPhoneNo)")

    }

    // function to return a formatted client info to save in external txt file 
    func txtFileFormat() -> String {
        return "\(self.cliFirstName),\(self.cliLastName),\(self.cliId),\(self.cliAddress),\(self.cliPhoneNo),\(self.cliPin)\n"
    }
}

//Account class
class Account {
    var accNo: Int // account number
    var accClientId: Int // account client identification
    var accBalance: Double // account balance
    // Account class constructor
    init(no: Int, clientId: Int, balance: Double ){
        self.accNo = no
        self.accClientId = clientId
        self.accBalance = balance
    }
    // function to transfer an amount of money from the account to a destination account 
    // returns a boolean value to indicate whether the process had success or not 
    func transferToAccount(moneyTotal:Double, destination:Account) -> Bool {
        if(self.accBalance >= moneyTotal){ // if there is enough money to do the transfer
            self.accBalance -= moneyTotal // deduct from accout
            destination.accBalance += moneyTotal // add to destination
            self.printBalance() // print accout balance 
            destination.printBalance() // print destination balance
            return true
        }else{
            print("There is not enough funds for this operation")
            return false
        }
    }
    // function to print the account attributes
    func printAccDetails(){
        print("Account No: \(self.accNo), Account Client Id: \(self.accClientId), Account balance: $\(String(format: "%.2f", self.accBalance ))")
    }
    // function to draw money from the account
    // returns a boolean value to indicate whether the process had success or not 
    func DrawMoney(moneyTotal:Double) -> Bool { return false }
    // function to deposit money into the account
    func DepositMoney(moneyTotal:Double){}

    // function to print the account balance
    func printBalance(){}

    // function to return a formatted account info to save in external txt file 
    func txtFileFormat() -> String {
        return ""
    }
}

class Savings: Account {
    var savFreeTransactions: Int // savings account number of free transactions
    var savTransactionsCost: Double // savings account transactions cost
    // Savings class constructor    
    init(no: Int, clientId: Int, balance:Double, freeTransactions: Int, transactionsCost: Double ){
        self.savFreeTransactions = freeTransactions
        self.savTransactionsCost = transactionsCost
        super.init( no:no, clientId:clientId, balance:balance) // Account class constructor call
    }
    // function to draw money from the account
    // returns a boolean value to indicate whether the process had success or not 
    override func DrawMoney(moneyTotal:Double) -> Bool {
        var totalDeduct = moneyTotal
        if  (self.savFreeTransactions > 0 ) { // if the user has free transactions left
            self.savFreeTransactions -= 1 // reduce the free transactions number
            print("Free transactions left: \(self.savFreeTransactions)")
        }else{ // if the user run out of free transactions
            print("Service Cost: $\(String(format: "%.2f", self.savTransactionsCost ))") // shows the cost
            totalDeduct += self.savTransactionsCost   // add the transactions cost to the total deduction
        }
        if(self.accBalance - totalDeduct >= 0 ) { // if the balance is enough to draw the total deduction
            self.accBalance -= totalDeduct  // deduct the money
            print("Savings account deduction successfully made")
            
            self.printBalance() // prints the balance
            return true
        }else{ // not enough money
            print("There is not enough funds for this operation")
            return false
        }
    }
    // function to deposit money into the account
    override func DepositMoney(moneyTotal:Double) {
        self.accBalance += moneyTotal // add the money to the balance
        print("Savings account deposit successfully made")
        self.printBalance() // prints the balance
    }
    // function to print the account balance
    override func printBalance(){
        print("Savings account (\(self.accNo)) balance: $\(String(format: "%.2f", self.accBalance ))")
    }
    // function to return a formatted savings account info to save in external txt file 
    override func txtFileFormat() -> String {
        return "Savings,\(self.accNo),\(self.accClientId),\(self.accBalance),\(self.savFreeTransactions),\(self.savTransactionsCost)\n"
    }
}

class Checking: Account {
    var chkOverdraftFee: Double
    // Checking class constructor 
    init(no: Int, clientId: Int, balance:Double, overdraftFee: Double){
        self.chkOverdraftFee = overdraftFee
        super.init( no:no, clientId:clientId, balance:balance) // Account class constructor call
    }
    // function to draw money from the account
    // returns a boolean value to indicate whether the process had success or not 
    override func DrawMoney(moneyTotal:Double) -> Bool {
        print(self.accBalance)
        print(moneyTotal)
        if(self.accBalance <= moneyTotal) { // if the balance is enough to draw the money
            self.accBalance -= moneyTotal // deduct the money
            print("Checking account deduction successfully made")
            self.printBalance() // prints the balance
            return true
        }else if (self.accBalance + self.chkOverdraftFee) <= moneyTotal { // if the balance plus the overdraft value is enough to draw the money
            let overdraft = self.accBalance + self.chkOverdraftFee - moneyTotal // update the overdraft available value
            self.accBalance -= moneyTotal // deduct the money
            print("Checking account deduction successfully made")
            print("OverDraft money left: $\(String(format: "%.2f", overdraft ))")
            self.printBalance() // prints the balance
            return true
        }else{ // not enough money
            print("There is not enough funds for this operation")
            return false
        }
        
    }
    // function to deposit money into the account
    override func DepositMoney(moneyTotal:Double) {
        self.accBalance += moneyTotal // add the money to the balance
        print("Checking account deposit successfully made")
        self.printBalance()
    }
    // function to print the account balance
    override func printBalance(){
        print("Checking account (\(self.accNo)) balance: $\(String(format: "%.2f", self.accBalance ))")
    }
    // function to return a formatted checking account info to save in external txt file 
    override func txtFileFormat() -> String {
        return "Checking,\(self.accNo),\(self.accClientId),\(self.accBalance),\(self.chkOverdraftFee)\n"
    }
}
