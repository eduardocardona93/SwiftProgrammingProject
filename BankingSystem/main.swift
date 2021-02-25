//
//  main.swift
//  BankingSystem
//
//  Created by Eduardo Cardona on 2/22/21.
//



import Foundation

var clients = [Client]() // clients array
var accounts = [Account]() // accounts array
let txtFilehandlingObj = txtFilehandling() // file handling class call
let accFileName = "accounts" // file name for the accounts saving
let cliFileName = "clients" // file name for the clients saving

/************************************************** JSON FILES FUNCTIONS**********************************************/
// file save for clients
func saveToFileClients(){
    // clears the file
    txtFilehandlingObj.saveClients(fileName:cliFileName, clients:[])
    //saves the file
    txtFilehandlingObj.saveClients(fileName:cliFileName, clients:clients)
}
// file save for accounts
func saveToFileAccounts(){
    // clears the file
    txtFilehandlingObj.saveAccounts(fileName:accFileName, accounts:[])
    //saves the file
    txtFilehandlingObj.saveAccounts(fileName:accFileName, accounts:accounts)
}

// loading all information from file
func loadFromFile(){
    // formats the existing lines and append them to the file
    for line in txtFilehandlingObj.readingFromLocalFile(fileName:cliFileName) {
        //split each line into words which are fields
        let fields = line.components(separatedBy: ",")
        //create an object of Client assuming the separated words are the inputs and appends it to the clients array
        clients.append(Client( firstName:fields[0], lastName:fields[1], id:Int(fields[2])!, address:fields[3], phoneNo:fields[1] ))
    }
    // 
    for line in txtFilehandlingObj.readingFromLocalFile(fileName:accFileName) {
        //split each line into words which are fields
        let fields = line.components(separatedBy: ",")
        //create an object of Account assuming the separated words are the inputs and appends it to the account array
        // as the first word is the type of the account, this will split the decision of appending a savings or checking account
        if fields[0] == "Checking" {
            // appends a Checking account
            accounts.append( Checking( no: Int(fields[1])!, clientId: Int(fields[1])!, balance:Double(fields[2])!, overdraftFee: Double(fields[3])!) )
        }else if fields[0] == "Savings"{
            // appends a Savings account
            accounts.append( Savings( no: Int(fields[1])!, clientId: Int(fields[1])!, balance:Double(fields[2])!, freeTransactions: Int(fields[3])!, transactionsCost: Double(fields[4])!)) 
        }
    }
}


/************************************************** ACCOUNT FUNCTIONS**********************************************/
//searchs for an account by its 'no' and returns the Account object
func getAccountByNo(no:Int) -> Account? {
    // iterates all the accounts by object
    for account in accounts{
        if account.accNo == no { // when matching the account number  
            return account // return the Account object
        }
    }
    return nil // if not found return nil
}

//searchs for an account by its 'no' and returns the 'index' in the accounts array
func getAccountIndex(no:Int) ->Int {
    // iterates all the accounts by index
    for i in 0..<accounts.count{
        if accounts[i].accNo == no { // when matching the account number
            return i // return the array index
        }
    }
    return -1 // if not found return -1
}

// creates as many accounts (checking/savings) and appends them into the accounts array
func createAccount(clientId: Int) {
        if getClientById(id:clientId) != nil{ // validates the existance of the client
            repeat {
                print("Enter account no:")
                let no = Int(readLine()!)!
                if getAccountIndex(no:no) < 0{
                    print("Enter account type:")
                    print("1. Checking")
                    print("2. Savings")
                    let type = Int(readLine()!)!
                    if type == 1{
                        print("Enter overdraft fee (default: $300.00) :")
                        let overdraftFee = Double(readLine()!)!
                        accounts.append( Checking( no: no, clientId: clientId, balance:0.0, overdraftFee: overdraftFee) )
                        print("Checking account created succesfully")
                    }else if type == 2{
                        print("Enter free transactions limit (default: 5) :")
                        let freeTransactions = Int(readLine()!)!
                        print("Enter transactions cost (default: $5.00) :")
                        let transactionsCost = Double(readLine()!)!
                        accounts.append( Savings( no: no, clientId: clientId, balance:0.0, freeTransactions: freeTransactions, transactionsCost: transactionsCost) )
                        print("Savings account created succesfully")
                    }
                }else{
                    print("The account with the number '\(no)' already exists ")
                }
                print("\n\nDo you want to create another account for this client?y/n")
            }while(readLine()! == "y")
            saveToFileAccounts()
        }else{
            print("Client not found")
        }
}

func editAccount(no: Int){
    if let editAccount = getAccountByNo(no: no)  {
        if editAccount is Savings{
            let savAccount = (editAccount as! Savings)
            print("Enter free transactions limit (current value: \(savAccount.savFreeTransactions)) :")
            savAccount.savFreeTransactions = Int(readLine()!)!
            print("Enter transactions cost (current value: $\(String(format: "%.2f", savAccount.savTransactionsCost )) :")
            savAccount.savTransactionsCost = Double(readLine()!)!
        }else if editAccount is Checking {
            let chkAccount = (editAccount as! Checking)
            print("Enter overdraft fee (current value: $\(String(format: "%.2f", chkAccount.chkOverdraftFee ) ) :")
            chkAccount.chkOverdraftFee = Double(readLine()!)!
        }
        print("Account edited Succesfully\n")
        saveToFileAccounts()
    }else {
        print("Account number not found\n")
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
                print("Do you want to deposit this account total balance ( $\(String(format: "%.2f", balance )) to another account? y/n")
                if(readLine()! == "y"){
                    print("Select the Account")
                    for (index,acc) in clientAccounts.enumerated(){
                        print("\((index + 1 )).  \(acc.accNo)")
                    }
                    
                    let selectedAccount = Int(readLine()!)!
                    clientAccounts[selectedAccount-1].DepositMoney(moneyTotal:balance)
                    print("Deposit succesfully done!")
                }
            }
            saveToFileAccounts()
            print("Account Deleted succesfully!")
            
        } else {
            print("Account not Deleted")
            
        }
    }else {
        print("Account number not found")
    }
}

/************************************************** CLIENT FUNCTIONS**********************************************/
//searchs for a client by its 'id' and returns the Client object
func getClientById(id:Int) -> Client? {
    // iterates all the clients by object
    for client in clients {
        if client.cliId == id { // when matching the client id
            return client // return the Client object
        }
    }
    return nil // if not found return nil
}
//searchs for a client by its 'id' and returns the 'index' in the clients array
func getClientIndex(id:Int) -> Int {
    // iterates all the clients by index
    for i in 0..<clients.count{ // when matching the client id
        if clients[i].cliId == id { // return the array index
            return i
        }
    }
    return -1 // if not found return -1
}
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
            print("Client created succesfully!!\n")
        }else{
            print("There is already a client with this id number\n")
        }
        print("Do you want to create another Client? y/n")
    }while readLine()! != "y"
    saveToFileClients()
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
        print("Client info succesfully edited\n")
        saveToFileClients()
    }else{
        print("Client id \(id) not found\n")
    }
    
}

func changeClientPin(id:Int){
    let clientIndex = getClientIndex(id:id)
    if clientIndex > -1 {
        let client = clients[clientIndex]
        print("Enter your 4 number pin:")
        let pin1 = readLine()!
        print("Re-Enter your 4 number pin:")
        let pin2 = readLine()!
        if(pin1 == pin2){
            client.cliPin = pin1
            print("Pin changed successfully\n")
            saveToFileClients()
        }else{
            print("The entered pins does not match\n")
        }
    }else{
        print("Client id \(id) not found\n")
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
            saveToFileClients()
            saveToFileAccounts()
            print("Client and accounts succesfully deleted\n")

        }
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
            4. Change client's pin
            5. Delete a client

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
                changeClientPin(id: clientId)
            case 5:
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
            3. Edit an existing account
            3. Delete an account

            0. Return
        """)

        switch Int(readLine()!)! {
            case 1:
                for acc in accounts{
                    acc.printAccDetails()
                }
            case 2:
                print("\nAdd a new accounts\n")
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                createAccount(clientId:clientId)

            case 3:
                print("Enter account no:")
                let accNo = Int(readLine()!)!
                editAccount(no:accNo)
            case 4:
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

func clientMenu (clientObj: Client, accountObj: Account){
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
            7. Change your pin

        """)
        switch Int(readLine()!)! {
            // TODO
            case 1:
                accountObj.printBalance()
            case 2:
                print("Enter the amount you want to deposit")
                let amountInput = Double(readLine()!)! 
                accountObj.DepositMoney(moneyTotal:amountInput)
                saveToFileAccounts()

            case 3:
                print("Enter the amount you want to draw")
                let amountInput = Double(readLine()!)! 
                if(accountObj.DrawMoney(moneyTotal:amountInput)){
                    saveToFileAccounts()
                }
            case 4:
                let clientAccs = getClientAccounts(cliId:clientObj.cliId)
                print("\nSelect your destination account")
                for (i,acc) in clientAccs.enumerated(){
                    print( "\((i+1)). \(acc.accNo) (\( type(of: acc) ))")
                }
                let destIndex = Int(readLine()!)! 
                let accountDestination = clientAccs[destIndex - 1]
                
                print("Enter the amount you want to transfer")
                let amountInput = Double(readLine()!)! 
                if(accountObj.transferToAccount(moneyTotal:amountInput, destination:accountDestination)){
                    saveToFileAccounts()
                }

            case 5:

                print("\nEnter the type of the bill (Ex. Wifi, Hydro, etc)")
                let billType = readLine()!
                
                print("Enter the amount of your bill")
                let amountInput = Double(readLine()!)! 

                if accountObj.DrawMoney(moneyTotal:amountInput) {
                    saveToFileAccounts()
                    print("Your \(billType) bill has been paid")
                }else{
                    print("Sorry, it was not possible to pay your \(billType) bill")
                }
            case 6:
                editClient(id:clientObj.cliId)
            case 7:
                changeClientPin(id: clientObj.cliId)
            default:
                print("Wrong choice")
        }

        print("\n\nDo you want to do another process?y/n")
    }while(readLine()! == "y")


}


/************************************************** PROGRAM LAUNCH  **********************************************/
// loads the clients and accounts from the files if exists
loadFromFile()
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
            if(pass == "Lambton2021") {
                adminMenu()
            } else {
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
                        let clientAccs = getClientAccounts(cliId:clientId)
                        print("\nSelect your account")
                        for (i,acc) in clientAccs.enumerated(){
                            print( "\((i+1)). \(acc.accNo) (\( type(of: acc) ))")
                        }
                        let accInput = Int(readLine()!)! 
                        if(accInput > 0 && accInput < clientAccs.count){
                            let account = clientAccs[accInput - 1]
                            clientMenu(clientObj:client, accountObj:account)
                        }else{
                            print("Wrong input")
                        }
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
