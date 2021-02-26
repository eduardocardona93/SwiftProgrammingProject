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
                // validates the existance of the account number
                if getAccountIndex(no:no) < 0{ // if not found then create account
                    print("""
                    Enter account type:

                    1. Checking
                    2. Savings
                    """)


                    let type = Int(readLine()!)!
                    if type == 1{ // if checking ask for overdraft value
                        print("Enter overdraft fee (default: $300.00) :")
                        let overdraftFee = Double(readLine()!)!
                        accounts.append( Checking( no: no, clientId: clientId, balance:0.0, overdraftFee: overdraftFee) )
                        print("Checking account created succesfully")
                    }else if type == 2{ // if savings ask for free transactions limit and transactions cost value
                        print("Enter free transactions limit (default: 5) :")
                        let freeTransactions = Int(readLine()!)!
                        print("Enter transactions cost (default: $5.00) :")
                        let transactionsCost = Double(readLine()!)!
                        accounts.append( Savings( no: no, clientId: clientId, balance:0.0, freeTransactions: freeTransactions, transactionsCost: transactionsCost) )
                        print("Savings account created succesfully")
                    }else{ // wrong option selected
                        print("Wrong input")
                    }
                }else{ // if account already exists
                    print("The account with the number '\(no)' already exists ")
                }
                // keep adding acounts mesage
                print("\n\nDo you want to create another account for this client?y/n")
            }while(readLine()! == "y")
            saveToFileAccounts() // saves all the accounts to the txt file
        }else{ // if client does not exists
            print("Client not found")
        }
}
// edits an account (checking/savings) by its number (no)
func editAccount(no: Int){
    if let editAccount = getAccountByNo(no: no)  { // if  account found then edit account
        // validate the type of account
        if editAccount is Savings{ // if savings ask for free transactions limit and transactions cost value
            let savAccount = (editAccount as! Savings) // casts the Account object as Savings
            print("Enter free transactions limit (current value: \(savAccount.savFreeTransactions)) :")
            savAccount.savFreeTransactions = Int(readLine()!)!
            print("Enter transactions cost (current value: $\(String(format: "%.2f", savAccount.savTransactionsCost )) :")
            savAccount.savTransactionsCost = Double(readLine()!)!
            print("Account edited Succesfully\n")
            saveToFileAccounts() // saves all the accounts to the txt file
        }else if editAccount is Checking { // if checking ask for overdraft value
            let chkAccount = (editAccount as! Checking) // casts the Account object as Checking
            print("Enter overdraft fee (current value: $\(String(format: "%.2f", chkAccount.chkOverdraftFee ) ) :")
            chkAccount.chkOverdraftFee = Double(readLine()!)!
            print("Account edited Succesfully\n")
            saveToFileAccounts() // saves all the accounts to the txt file
        }

    }else { // if  account found then print message
        print("Account number not found\n")
    }
}
// deletes an account (checking/savings) by its number (no)
// in case there is at least 1 account left for the same client, asks for making a deposit to one of the accounts left
func deleteAccount(no: Int) {
    if let delAccount = getAccountByNo(no: no)  { // if account found then validate decision and get the object
        print("Do you really want to delete the account no. \(no)? y/n")
        if readLine()! == "y" { // reads the validation answer
            // gets the account balance
            let balance = delAccount.accBalance
            // gets the index of the account to be deleted in the accounts array
            let index = getAccountIndex(no: no)
            // deletes the account from the accounts array
            accounts.remove(at: index)
            // gets all the client accounts left
            let clientAccounts = getClientAccounts(cliId: delAccount.accClientId)
            // validates if there is at least 1 account left for this client
            // also, validates if the deleted has money left
            if(clientAccounts.count > 0 && balance > 0) {
                
                print("\nThe Client has \(clientAccounts.count) account(s) left")
                print("Do you want to deposit this account total balance ( $\(String(format: "%.2f", balance )) to another account? y/n")
                // validates if wants to make a deposit to one of the remaining accounts
                if(readLine()! == "y"){
                    print("Select the Account")
                    // iterates all client's account with an index to select the one who gets the deposit
                    for (index,acc) in clientAccounts.enumerated(){
                        print("\((index + 1 )).  \(acc.accNo)")
                    }
                    let selectedAccount = Int(readLine()!)!
                    clientAccounts[selectedAccount-1].DepositMoney(moneyTotal:balance) // deposits the money
                    print("Deposit succesfully done!")
                }
            }
            saveToFileAccounts() // saves all the accounts to the txt file
            print("Account Deleted succesfully!")
        } else {
            print("Account not Deleted")
        }
    }else { // if  account found then print message
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
//gets the all the accounts belonging to a client
func getClientAccounts(cliId:Int) -> [Account] {
    var cliAccs = [Account]() // empty result Accounts array
    for account in accounts { // iterates all the accounts
        if account.accClientId == cliId { // if the account client id match with the 'cliId'
            cliAccs.append(account) // append it to the result array
        }
    }
    return cliAccs // return the result array
}
// creates as many clients as the user wants
func createClient(){
    repeat{
        print("\nEnter client id:")
        let id = Int(readLine()!)!
        // validates if there is a client with the same 'id'
        if(getClientIndex(id:id) < 0){ // not duplicate client found, create the client
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
        }else{// duplicate client found
            print("There is already a client with this id number\n")
        }
        // keep adding clients mesage
        print("Do you want to create another Client? y/n")
    }while readLine()! != "y"
    saveToFileClients() // saves all the clients to the txt file
}
// edits a client's info
func editClient(id: Int){
    let clientIndex = getClientIndex(id:id) // gets the client index
    // validates if there is a client with the same 'id'
    if clientIndex > -1 { // client found, edit information
        let client = clients[clientIndex] // get the client object from the clients array
        print("Enter client first name:")
        client.cliFirstName = readLine()!
        print("Enter client last name:")
        client.cliLastName = readLine()!
        print("Enter client address:")
        client.cliAddress = readLine()!
        print("Enter client phone no:")
        client.cliPhoneNo = readLine()!
        print("Client info succesfully edited\n")
        saveToFileClients() // saves all the clients to the txt file
    }else{ // client does not exists
        print("Client id '\(id)' not found\n")
    }
    
}
// changes a client's pin
func changeClientPin(id:Int){
    let clientIndex = getClientIndex(id:id)// gets the client index
    // validates if there is a client with the same 'id'
    if clientIndex > -1 {// client found, edit information
        let client = clients[clientIndex] // get the client object from the clients array
        print("Enter your 4 number pin:")
        let pin1 = readLine()!
        print("Re-Enter your 4 number pin:")
        let pin2 = readLine()!
        if(pin1 == pin2){ // if pins match then edit the value in the object
            client.cliPin = pin1
            print("Pin changed successfully\n")
            saveToFileClients() // saves all the clients to the txt file
        }else{
            print("The entered pins does not match\n")
        }
    }else{ // client does not exists
        print("Client id '\(id)' not found\n")
    }
}

//deletes a client and all the accounts belonging to the client
func deleteClient(id: Int) { // if client found then validate decision and get the object
    if let delClient = getClientById(id: id)  {
        let clientAccounts = getClientAccounts(cliId: id) // get client's accounts
        print("Do you really want to delete the client '\( delClient.fullName() )' and the \(clientAccounts) account(s) belonging to this client? y/n")
        if readLine()! == "y" {
            // client's accounts itteration
            for acc in clientAccounts {
                let accIndex = getAccountIndex(no: acc.accNo) // gets the client's account index in the clients array
                accounts.remove(at: accIndex) // delete client's account from clients array
            }
            let cliIndex = getClientIndex(id:id) // gets the client index in the clients array
            clients.remove(at: cliIndex) // delete client from clients array
            saveToFileClients() // saves all the clients to the txt file
            saveToFileAccounts() // saves all the accounts to the txt file
            print("Client and accounts succesfully deleted\n")
        }
    }else{ // client does not exists
        print("Client id '\(id)' not found\n")
    }
    
}


/************************************************** MENUS FUNCTIONS **********************************************/
// admin's menu for clients management
func adminClientsManagementMenu(){
    while true { // infinite loop to do as many operations as the user wants
        print("""

            Select an option for clients management

            1. View all clients
            2. Create clients
            3. Edit an existing client
            4. Change client's pin
            5. Delete a client

            0. Return
        """)
        // menu case
        switch Int(readLine()!)! {
            case 1: // View all clients
                for client in clients{ // iterates all the clients array
                    client.printClientDetails() // print the client detail
                }
            case 2: // Create clients
                createClient()
            case 3: // Edit an existing client
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                editClient(id: clientId)
            case 4: // Change client's pin
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                changeClientPin(id: clientId)
            case 5: // Delete a client
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                deleteClient(id:clientId)
            case 0: // return to admin's main menu
                break
            default: // wrong choice
                print("Wrong choice")
        }
    }
}
// admin's menu for accounts management
func adminAccountsManagementMenu(){
    while true { // infinite loop to do as many operations as the user wants
        print("""

            Select an option for accounts management

            1. View all accounts
            2. Create new accounts
            3. Edit an existing account
            4. Delete an account

            0. Return
        """)
        // menu case
        switch Int(readLine()!)! {
            case 1: //  View all accounts
                for acc in accounts{  // iterates all the clients array
                    acc.printAccDetails() // print the client detail
                }
            case 2:// Create new accounts
                print("\nAdd new accounts\n")
                print("Enter cliend id:")
                let clientId = Int(readLine()!)!
                createAccount(clientId:clientId)

            case 3: // Edit an existing account
                print("Enter account no:")
                let accNo = Int(readLine()!)!
                editAccount(no:accNo)
            case 4: // Delete an account
                print("Enter account no:")
                let accNo = Int(readLine()!)!
                deleteAccount(no:accNo)
            case 0: // return to admin's main menu
                break
            default: // wrong choice
                print("Wrong choice")
        }
    }
}
// admin's main menu
func adminMenu (){
    repeat { // infinite loop to do as many operations as the user wants
        print("""

            What do you want to do?

            1. Manage Clients
            2. Manage Accounts
        """)
        // menu case
        switch Int(readLine()!)! {
            case 1: // Manage Clients
                adminClientsManagementMenu()
            case 2: //  Manage Accounts
                adminAccountsManagementMenu()
            default: // wrong choice
                print("Wrong choice")
        }
        print("\n\nDo you want to do another process?y/n")
    }while(readLine()! == "y")
}

func clientMenu (clientObj: Client, accountObj: Account){
    repeat {
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
        // menu case
        switch Int(readLine()!)! {
            case 1: // Display Your current balance
                accountObj.printBalance()
            case 2: // Deposit money
                print("Enter the amount you want to deposit")
                let amountInput = Double(readLine()!)!
                accountObj.DepositMoney(moneyTotal:amountInput) // deposits the money
                saveToFileAccounts() // saves all the accounts to the txt file

            case 3: // Draw money
                print("Enter the amount you want to draw")
                let amountInput = Double(readLine()!)!
                if(accountObj.DrawMoney(moneyTotal:amountInput)){ // if the draw was successful
                    saveToFileAccounts() // saves all the accounts to the txt file
                }
            case 4: // Transfer money to other accounts within the bank
                let clientAccs = getClientAccounts(cliId:clientObj.cliId) // gets the client accounts
                print("\nSelect the index of the destination account:")
                for (i,acc) in clientAccs.enumerated(){ // iterates the client accounts
                    print( "\((i+1)). \(acc.accNo) (\( type(of: acc) ))") // print them with an index
                }
                let destIndex = Int(readLine()!)!
                // validates the index account
                if(destIndex > 0 && destIndex < clientAccs.count) {
                    let accountDestination = clientAccs[destIndex - 1] // get the account object
                    print("Enter the amount you want to transfer")
                    let amountInput = Double(readLine()!)!
                    if(accountObj.transferToAccount(moneyTotal:amountInput, destination:accountDestination)){ // if the transfer was successful
                        saveToFileAccounts() // saves all the accounts to the txt file
                    }
                }else{
                    print("Wrong input")
                }


            case 5: // Pay utility bills
                // require utility name
                print("\nEnter the type of the bill (Ex. Wifi, Hydro, etc)")
                let billType = readLine()!
                // require utility amount
                print("Enter the amount of your bill")
                let amountInput = Double(readLine()!)!
                if accountObj.DrawMoney(moneyTotal:amountInput) { // if the pay process was successful
                    saveToFileAccounts() // saves all the accounts to the txt file
                    print("Your \(billType) bill has been paid")
                }else{
                    print("Sorry, it was not possible to pay your \(billType) bill")
                }
            case 6: // Edit your account Info
                editClient(id:clientObj.cliId)
            case 7: // Change your pin
                changeClientPin(id: clientObj.cliId)
            default: // wrong choice
                print("Wrong choice")
        }
        print("\n\nDo you want to do another process?y/n")
    }while(readLine()! == "y")


}


/************************************************** PROGRAM LAUNCH  **********************************************/
// loads the clients and accounts from the files if exists
loadFromFile()

// Initial menu
while true {
    // Decides de type of user
    print("""

        Who are you?

        1. Admin
        2. Client

        Enter '0' for exit
    """)
    // menu case
    switch Int(readLine()!)! {
        case 1: // Admin
            print("Type your password")
            let pass = readLine()!
            if(pass == "Lambton2021") { // requests the password to the admin
                adminMenu() // calls the admin menu
            } else {
                print("Wrong Password")
            }
        case 2: // Client
            print("Enter cliend id:")
            let clientId = Int(readLine()!)!
            if let client = getClientById(id:clientId) { // if client found
                var i = 3 // attempts allowed
                // gives 3 attempts to the client to enter the pin
                repeat { // do-while loop for entering the client pin
                    print("Type your pin")
                    let pin = readLine()!
                    // validates the pin
                    if(client.cliPin == pin) {  // successful pin typed
                        let clientAccs = getClientAccounts(cliId:clientId) // gets the client accounts
                        print("Select the index of the account you want to operate: \n")
                        for (i,acc) in clientAccs.enumerated(){ // iterates the client accounts
                            print( "\((i+1)). \(acc.accNo) (\( type(of: acc) ))") // print them with an index
                        }
                        let accInput = Int(readLine()!)!
                        // validates the index account
                        if(accInput > 0 && accInput < clientAccs.count){
                            let account = clientAccs[accInput - 1] // get the account object
                            clientMenu(clientObj:client, accountObj:account) // call the client menu
                        }else{
                            print("Wrong input")
                        }
                        break // do not repeat again the pin request
                    }else{ // unsuccessful attempt
                        i -= 1 // reduce attempts allowed
                        print("Wrong pin, you have \( (i) ) attempts")
                    }
                } while i > 0
                if( i == 0){ // not more attempts allowed
                    print("Sorry, your attempts run out")
                }
            } else { // if client not found
                print("Client id not found")
            }
        case 0: // Exit
            print("Good bye!! Have a nice day")
            break
        default: // Wrong option
            print("Wrong Option")
    }
    
}
