//
//  Classes.swift
//  BankingSystem
//
//  Created by user192101 on 2/23/21.
//

import Foundation





class Client: Codable {
    var cliFirstName: String
    var cliLastName: String
    var cliId: Int
    var cliAddress: String
    var cliPhoneNo: String
    init( firstName: String, lastName: String, id: Int, address: String, phoneNo: String ){
        self.cliFirstName = firstName
        self.cliLastName = lastName
        self.cliId = id
        self.cliAddress = address
        self.cliPhoneNo = phoneNo
    }
    func fullName() -> String {
        return self.cliFirstName + " " + self.cliLastName
    }
    
}

class Account: Codable{
    var accNo: Int
    var accClientId: Int
    var accType: String
    var accBalance: Double
    
    init( no: Int, clientId: Int, type: String, balance: Double){
        self.accNo = no
        self.accClientId = clientId
        self.accType = type
        self.accBalance = balance
    }
    
    func DrawMoney(moneyTotal:Double) {
        self.accBalance -= moneyTotal
    }
    
    func DepositMoney(moneyTotal:Double){
        self.accBalance += moneyTotal
    }
    
    
}
