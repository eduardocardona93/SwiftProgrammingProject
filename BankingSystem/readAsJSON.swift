//
//  readAsJSON.swift
//  readFullFiles
//
//  Created by Eduardo Cardona on 2/21/21.
//

import Foundation

class JSONFilehandling{
    init(){}
    // converting Client object to string
    func getClientJsonString(obj: [Client]) -> String{
        do{
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(obj)
            if let json = String(data: jsonData, encoding: String.Encoding.utf8){
                return json
            }
        }catch{

        }
        return ""
    }

    func getAccountJsonString(obj: [Account]) -> String {
        do{
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(obj)
            if let json = String(data: jsonData, encoding: String.Encoding.utf8){
                return json
            }
        }catch{

        }
        return ""
    }
    
    func saveJsonFile(fileName:String, data: String){
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let pathWithFilename = documentDirectory.appendingPathComponent(fileName + ".json")
            do {
                try data.write(to: pathWithFilename, atomically: true, encoding: .utf8)
            } catch {
                print("Error Saving the file")
            }
        }
        
    }
    
    func readAccountFile(fileName:String) -> [Account] {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let url = documentDirectory.appendingPathComponent(fileName + ".json")
            let data = NSData(contentsOf: url)
            do {
                // converting data to object(i.e Account in our case)
                if let payload = data as Data?{
                    let account = try JSONDecoder().decode([Account].self, from: payload)
                    return account
                }
            } catch {
                
              }
            
        }
        return []
    }

    func readClientFile(fileName:String) -> [Client] {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let url = documentDirectory.appendingPathComponent(fileName + ".json")
            let data = NSData(contentsOf: url)
            do {
                // converting data to object(i.e Client in our case)
                if let payload = data as Data?{
                    let client = try JSONDecoder().decode([Client].self, from: payload)
                    return client
                }
            } catch {  }
            
        }
        return []
    }
}
