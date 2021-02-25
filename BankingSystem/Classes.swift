//
//  Classes.swift
//  BankingSystem
//
//  Created by user192101 on 2/23/21.
//

import Foundation



let currentDateTime = Date()

class Client {
    var cliFirstName: String
    var cliLastName: String
    var cliId: Int
    var cliAddress: String
    var cliPhoneNo: String
    var cliPin: String
    
    init( firstName: String, lastName: String, id: Int, address: String, phoneNo: String ){
        self.cliFirstName = firstName
        self.cliLastName = lastName
        self.cliId = id
        self.cliAddress = address
        self.cliPhoneNo = phoneNo
        self.cliPin = "1234"
    }
    func fullName() -> String {
        return self.cliFirstName + " " + self.cliLastName
    }
    func changePin(newPin:String){
        if(newPin.count  == 4){
            self.cliPin = newPin
        }else{
            print("Incorrect Pin")
        }
    }

    func printClientDetails(){
        print("First Name : \(self.cliFirstName), Last Name : \(self.cliLastName), Id : \(self.cliId), Address : \(self.cliAddress), Phone No : \(self.cliPhoneNo), Pin : \(self.cliPin)")

    }
    
}

class Account {
    var accNo: Int
    var accClientId: Int
    var accBalance: Double

    init(no: Int, clientId: Int){
        self.accNo = no
        self.accClientId = clientId
        self.accBalance = 0.0
    }
    func DrawMoney(moneyTotal:Double) {}
    
    func DepositMoney(moneyTotal:Double){}
    
    func TransferToAccount(moneyTotal:Double, destination:Account){
        if(self.accBalance >= moneyTotal){
            self.accBalance -= moneyTotal
            destination.accBalance += moneyTotal
            destination.printBalance()
            self.printBalance()
        }else{
            print("There is not enough funds for this operation")
        }
    }
    func printBalance(){}

    func printAccDetails(){
        print("Account No: \(self.accNo), Account Client Id: \(self.accClientId), Account balance: $\(String(format: "%.2f", self.accBalance ))")
    }
}

class Savings: Account {
    var savFreeTransactions: Int
    var savTransactionsCost: Double
        
    init(no: Int, clientId: Int, freeTransactions: Int, transactionsCost: Double ){
        self.savFreeTransactions = freeTransactions
        self.savTransactionsCost = transactionsCost
        super.init( no:no, clientId:clientId)
    }

    override func DrawMoney(moneyTotal:Double) {
        if  (self.savFreeTransactions >= 1) {
            self.savFreeTransactions -= 1
            self.accBalance -= moneyTotal
            print("Savings account deduction successfully made")

        }else{
            let totalDeduct = self.savTransactionsCost + moneyTotal
            if(self.accBalance - totalDeduct >= 0 ) {
                self.accBalance -= totalDeduct
                print("Savings account deduction successfully made")
                print("Service Cost: $\(String(format: "%.2f", self.savTransactionsCost ))")
            }else{
                print("There is not enough funds for this operation")
            }
        }
        self.printBalance()
    }

    override func DepositMoney(moneyTotal:Double) {
        self.accBalance += moneyTotal
        print("Savings account deposit successfully made")
        self.printBalance()
    }

    override func printBalance(){
        print("Savings account (\(self.accNo)) balance: $\(String(format: "%.2f", self.accBalance ))")
    }

}

class Checking: Account {
    var chkOverdraftFee: Double
    init(no: Int, clientId: Int, overdraftFee: Double){
        self.chkOverdraftFee = overdraftFee
        super.init( no:no, clientId:clientId)
    }
    override func DrawMoney(moneyTotal:Double) {
        if(self.accBalance <= moneyTotal) {
            self.accBalance -= moneyTotal
            print("Checking account deduction successfully made")
        }else if (self.accBalance + self.chkOverdraftFee) <= moneyTotal {
            let overdraft = self.accBalance + self.chkOverdraftFee - moneyTotal
            self.accBalance -= moneyTotal
            print("Checking account deduction successfully made")
            print("OverDraft money left: $\(String(format: "%.2f", overdraft ))")
        }else{
            print("There is not enough funds for this operation")
        }
        self.printBalance()
    }

    override func DepositMoney(moneyTotal:Double) {
        self.accBalance += moneyTotal
        print("Checking account deposit successfully made")
        self.printBalance()
    }

    override func printBalance(){
        print("Checking account (\(self.accNo)) balance: $\(String(format: "%.2f", self.accBalance ))")
    }
}
