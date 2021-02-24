//
//  main.swift
//  BankingSystem
//
//  Created by Eduardo Cardona on 2/22/21.
//



import Foundation

var clients = [Client]()
var accounts = [Account]()
let JSONFilehandlingObj = JSONFilehandling()	
let accFileName = "accounts"
let cliFileName = "clients"

/************************************************** JSON FILES FUNCTIONS**********************************************/
// json save
func saveToFile(){
    
    let dataStrAcc = JSONFilehandlingObj.getClientJsonString(obj: clients)
    let dataStrCli = JSONFilehandlingObj.getAccountJsonString(obj: accounts)
    JSONFilehandlingObj.saveJsonFile(fileName:accFileName, data:dataStrAcc)
    JSONFilehandlingObj.saveJsonFile(fileName:cliFileName, data:dataStrCli)
}

/************************************************** ACCOUNT FUNCTIONS**********************************************/
func getAccountByNo(no:Int) -> Account? {
    for account in accounts{
        if account.accNo == no {
            return account
        }
    }
    return nil
}
//function search for an account by its no and return its index
func getAccountIndex(no:Int) ->Int {
    for i in 0..<accounts.count{
        if accounts[i].accNo == no {
            return i
        }
    }
    return -1
}


func createAccount(){
    print("\nAdd a new account\n")
    print("Enter cliend id:")
    let clientId = Int(readLine()!)!
    if getClientById(id:clientId) != nil{
        print("Enter account no:")
        let no = Int(readLine()!)!
        print("Enter account type:")
        let type = readLine()!
        accounts.append( Account( no: no, clientId: clientId, type: type, balance: 0.0) )
    }
    
}
func getClientAccounts(cliId:Int) -> [Account] {
    var cliAccs = [Account]()
    for account in accounts {
        if account.accClientId == cliId {
            cliAccs.append(account)
        }
    }
    return cliAccs
}

func deleteAccount(no: Int) {
    if let delAccount = getAccountByNo(no: no)  {
        print("Do you really want to delete the account no. \(no)? y/n")
        
        if readLine()! == "y" {
            let balance = delAccount.accBalance
            let clientAccounts = getClientAccounts(cliId: delAccount.accClientId)
            let index = getAccountIndex(no: no)
            accounts.remove(at: index)
            
            if(clientAccounts.count > 1 && balance > 0) {
                
                print("The Client has more accounts")
                print("Do you want to deposit this account total amount ( \(String(format: "%.2f", balance )) to another account? y/n")
                if(readLine()! == "y"){
                    print("Select the Account")
                    for (index,acc) in clientAccounts.enumerated(){
                        print("\((index + 1 )).  \(acc.accNo)")
                    }
                    
                    let selectedAccount = Int(readLine()!)!
                    clientAccounts[selectedAccount-1].DepositMoney(moneyTotal:balance)
                }
            }
            
            
            
            print("Account Deleted succesfully!")
            
        } else {
            print("Account not Deleted")
            
        }
    }else {
        print("Account number not found")
    }
}

func transferMoney(accFromNo: Int, accToNo: Int, amount: Double ){
    if let fromAccount = getAccountByNo(no: accFromNo)  {
        if let toAccount = getAccountByNo(no: accToNo)  {
            if fromAccount.accBalance >= amount {
                fromAccount.DrawMoney(moneyTotal:amount)
                toAccount.DepositMoney(moneyTotal:amount)
                print("Money transfer from \(accFromNo) to \(accToNo) successful")
            }else {
                print("There is not enough funds in account no. \(accFromNo) to do this transfer")
            }
        }else{
            print("Destination Account not found")
        }
    }else{
        print("Origin Account not found")
    }
}

func payBill(accNo: Int, amount: Double ){
    if let account = getAccountByNo(no: accNo)  {
        if account.accBalance >= amount {
            account.DrawMoney(moneyTotal:amount)
            print("Bill paid succesfully")
        }else {
            print("There is not enough funds in account no. \(accNo) to do this transaction")
        }
    }else{
        print("Account '\(accNo)' not found")
    }
}

/************************************************** CLIENT FUNCTIONS**********************************************/
func createClient(){
    repeat{
        print("\nEnter client id:")
        let id = Int(readLine()!)!
        if(getClientIndex(id:id) < 0){
            print("Enter client first name:")
            let firstName = readLine()!
            print("Enter client last name:")
            let lastName = readLine()!
            print("Enter client address:")
            let address = readLine()!
            print("Enter client phone no:")
            let phoneNo = readLine()!
            clients.append(Client( firstName:firstName, lastName:lastName, id:id, address:address, phoneNo:phoneNo ))
        }else{
            print("There is already a client with this id number")
        }
        print("Do you want to create another Client? y/n")
    }while readLine()! != "y"
    
}

func editClient(id: Int){
    let clientIndex = getClientIndex(id:id)
    if clientIndex > -1 {
        let client = clients[clientIndex]
        print("Enter client first name:")
        client.cliFirstName = readLine()!
        print("Enter client last name:")
        client.cliLastName = readLine()!
        print("Enter client address:")
        client.cliAddress = readLine()!
        print("Enter client phone no:")
        client.cliPhoneNo = readLine()!
        print("Client info succesfully edited")       
    }else{
        print("Client id \(id) not found")
    }
    
}
func deleteClient(id: Int) {
    if let delClient = getClientById(id: id)  {
        let clientAccounts = getClientAccounts(cliId: id)
        print("Do you really want to delete the client '\( delClient.fullName() )'' and the \(clientAccounts) account(s) belonging to this client? y/n")
        if readLine()! == "y" {
            for acc in accounts {
                let accIndex = getAccountIndex(no: acc.accNo)
                accounts.remove(at: accIndex)
            }
            let cliIndex = getClientIndex(id:id)
            clients.remove(at: cliIndex)
        }
    }
    
}

func getClientById(id:Int) -> Client? {
    for client in clients{
        if client.cliId == id {
            return client
        }
    }
    return nil
}

//function search for a client by its id and return its index
func getClientIndex(id:Int) -> Int {
    for i in 0..<clients.count{
        if clients[i].cliId == id {
            return i
        }
    }
    return -1
}


repeat {
    // menu
    print("\nWhat do you want to do?")
    print("1.Manage Clients")
    print("2.Manage Accounts")
    
    // switch Int(readLine()!)! {
    // case 1:
    //     // storiesFrom18s()
    // case 2:
    //     print("\nEnter the story number")
    //     // storybyNo(no:Int(readLine()!)!)
    // case 3:
    //     print("\nEnter the cinema name")
    //     // moviesbyCinemas(name:readLine()!)
    // default:
    //     print("Wrong choice")
    // }
    
    print("\n\nDo you want to do another process?y/n")
}while(readLine()! == "y")

