//
//  txtFilehandling.swift
//  BankingSystem
//
//  Created by user192101 on 2/25/21.
//

import Foundation


class txtFilehandling{ 
    
    init(){}
    //function to read data from a file
    func readingFromLocalFile(fileName:String) -> [String.SubSequence]{
        do {
            // Get the saved data all the contnt of the text file as data
            if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("txt")
                let savedData = try Data(contentsOf: fileURL)
                // checking if we can convert the data into a string
                if String(data: savedData, encoding: .utf8) != nil {
                    //get the context of the file as string
                    let data = String(decoding: savedData, as: UTF8.self)
                    //get lines by line of the text file
                    return data.split(whereSeparator: \.isNewline)
                }
            }
            return []
        } catch {
            // Catch any errors
            return []
        }
    }


    //function to save clients data to a file
    func saveClients(fileName:String, clients:[Client]) { 
        if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // calling the filling function
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("txt")
            //merging all clients lines form the array in one string
            var myString:String = ""
            for client in clients {
                myString += client.txtFileFormat()
            }
            //convert from string to data
            let data = myString.data(using: .utf8)
            do {
                //write the data into the file
                try data?.write(to: fileURL)
            } catch {
                // Catch any errors
                print(error.localizedDescription)
            }
        }else{
           print("DirectoryURL not available")
        }
    }

    //function to save accounts data to a file
    func saveAccounts(fileName:String, accounts:[Account]) { 
        if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // calling the filling function
            let fileURL = URL(fileURLWithPath: fileName, relativeTo: directoryURL).appendingPathExtension("txt")
            //merging all acounts lines form the array in one string
            var myString:String = ""
            for account in accounts{
                myString += account.txtFileFormat()
            }
            //convert from string to data
            let data = myString.data(using: .utf8)
            do {
                //write the data into the file
                try data?.write(to: fileURL)
                // print("File saved: \(fileURL.absoluteURL)")
            } catch {
                // Catch any errors
                print(error.localizedDescription)
            }
        }else{
           print("DirectoryURL not available")
        }
    }


}

