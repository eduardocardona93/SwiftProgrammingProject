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


func createAccount() {
    print("\nAdd a new account\n")
        print("Enter cliend id:")
        let clientId = Int(readLine()!)!
        if getClientById(id:clientId) != nil{
            repeat {
                print("Enter account no:")
                let no = Int(readLine()!)!
                print("Enter account type:")
                print("1. Checking")
                print("2. Savings")
                let type = Int(readLine()!)!
                if type == 1{
                    accounts.append( Checking( no: no, clientId: clientId, overdraftFee: 300.0) )
                }else if type == 2{
                    accounts.append( Savings( no: no, clientId: clientId, freeTransactions: 25, transactionsCost: 5.0) )
                }
                print("\n\nDo you want to create another account for this client?y/n")
            }while(readLine()! == "y")
        }
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
    for client in clients {
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

func getClientAccounts(cliId:Int) -> [Account] {
    var cliAccs = [Account]()
    for account in accounts {
        if account.accClientId == cliId {
            cliAccs.append(account)
        }
    }
    return cliAccs
}

func getClientSavingsAccounts(cliId:Int) -> [Savings]{
    var cliAccs = [Savings]()
    for account in getClientAccounts(cliId:cliId){
        if account is Savings {
            cliAccs.append((account as! Savings))
        }
    }
    return cliAccs
}

func getClientCheckingAccounts(cliId:Int) -> [Checking]{
    var cliAccs = [Checking]()
    for account in getClientAccounts(cliId:cliId){
        if account is Checking {
            cliAccs.append((account as! Checking))
        }
    }
    return cliAccs
}

/************************************************** MENUS FUNCTIONS**********************************************/

func adminClientsManagementMenu(){
    while true {
        print("""
            Select an option for clients management

            1. View all clients
            2. Create clients
            3. Edit an existing client
            4. Delete a client

            0. Return

        """)
       switch Int(readLine()!)! {
            case 1:
                for client in clients{
                    client.printClientDetails()
                }
            case 2:
                createClient()
            case 3:
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                editClient(id: clientId)
            case 4:
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                deleteClient(id:clientId)
            case 0:
                break
            default:
                print("Wrong choice")
        }
    }
}   
func adminAccountsManagementMenu(){
    while true {
        print("""
            Select an option for accounts management

            1. View all accounts
            2. Create a new account
            3. Delete an account

            0. Return
        """)

        switch Int(readLine()!)! {
            case 1:
                for acc in accounts{
                    acc.printAccDetails()
                }
            case 2:
                createAccount()
            case 3:
                print("Enter account no:")
                let accNo = Int(readLine()!)!
                deleteAccount(no:accNo)
            case 0:
                break
            default:
                print("Wrong choice")
        }
    }
}

func adminMenu (){
    repeat {
        // menu admin
        print("""
            What do you want to do?

            1.Manage Clients
            2.Manage Accounts

        """)
        
        switch Int(readLine()!)! {
            case 1:
                adminClientsManagementMenu()
            case 2:
                adminAccountsManagementMenu()
            case 0:
                break
            default:
                print("Wrong choice")
        }
        print("\n\nDo you want to do another process?y/n")
    }while(readLine()! == "y")
}

func clientMenu (clientObj: Client){
    repeat {
        // menu admin
        print("""
            What do you want to do?
            1. Display Your current balance 
            2. Deposit money  
            3. Draw money 
            4. Transfer money to other accounts within the bank 
            5. Pay utility bills  
            6. Edit your account Info

        """)
        switch Int(readLine()!)! {
            //TODO
            case 1:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                for acc in clientAccs{
                    acc.printBalance()
                }
            case 2:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                print("\nSelect your account")
                for (i,acc) in clientAccs.enumerated(){
                    print( "\((i+1)). \(acc.accNo)")
                }
                let accInput = Int(readLine()!)! 
                if(accInput > 0 && accInput < clientAccs.count){
                    let account = clientAccs[accInput]
                }else{
                    print("Wrong input")
                }
            case 3:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                for acc in clientAccs{
                    acc.printBalance()
                }
                print("\nEnter the cinema name")
            case 4:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                for acc in clientAccs{
                    if(acc is Checking){

                    }
                }
                print("\nEnter the cinema name")
            case 5:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                for acc in clientAccs{

                }
            case 6:
                editClient(id:clientObj.cliId)
            default:
                print("Wrong choice")
        }

        print("\n\nDo you want to do another process?y/n")
    }while(readLine()! == "y")


}


while true {
    // menu main
    print("\nWho are you?")
    print("1. Admin")
    print("2. Client")
    
    print("Enter '0' for exit")
    let mainChoice = Int(readLine()!)!
    
    switch mainChoice {
        case 1:
            print("Type your password")
            let pass = readLine()!
            if(pass == "Lambton2021"){
                adminMenu()
            }else{
                print("Wrong Password")
            }
        case 2:
            print("Enter cliend id:")
            let clientId = Int(readLine()!)!
            var i = 3
            if let client = getClientById(id:clientId) {
                repeat {
                    print("Type your pin")
                    let pin = readLine()!
                    if(client.cliPin == pin){
                        clientMenu(clientObj:client)
                    }else{
                        i -= 1
                        print("Wrong pin, you have \( (3-i) ) tries")
                    }
                } while i > 0
                if( i == 0){
                    print("Sorry, your tries run out")
                }
            } else {
                print("Client id not found")
            }   
        case 0: 
            print("Good bye!! Have a nice day")             
            break
        default: 
            print("Wrong Option")
        
    }
    
}

    
    

