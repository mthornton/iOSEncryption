//
//  EncryptedFileDataAdapter.swift
//  CryptoTest
//
//  Created by Michael Thornton on 10/7/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation



enum EncryptedFileDataAdapterError: Swift.Error {
    case encryptedFileDataAdapterSaveError
    case encryptedFileDataAdapterLoadError

}



class EncryptedFileDataAdapter {
    
    
    private var fileName: String
    

    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    

    private func getKey() -> Data? {
        
        let bytes: [UInt8] = [3, 49, 53, 113, 33, 88, 80, 35, 76, 68, 93, 15, 97, 98, 86, 92, 32, 81, 89, 3, 72, 52, 118, 72, 89, 83, 36, 34, 48, 87, 13, 21, 11, 35, 40, 80]
        let saltBytes: [UInt8] = [54, 31, 2, 40, 1]
        
        let obfuscator = Obfuscator()
        
        do {
            let key = try Data.derivateKey(passphrase: obfuscator.reveal(key: bytes), salt: obfuscator.reveal(key: saltBytes))
            return key
        }
        catch {
            return nil
        }
    }
    
    
    
    /**
     Saves the supplied object to a file in the documents directory.  The file is encrypted.  The filename is
     specified in the class constructor.
     */
    public func saveCodableObject<T : Codable>(_ object: T) throws {
        
        let jsonEncoder = JSONEncoder()

        do {
            //encode the object into json
            let jsonData = try jsonEncoder.encode(object)
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let key = self.getKey() {
                
                let fileURL = dir.appendingPathComponent(fileName)
                
                do {
                    let iv = Data([3,5,7,1,3,8,0,3,5,2,5,6,1,2,2,0])
                    let data = try jsonData.encrypt(key: key, iv: iv)
                
                    try data.write(to: fileURL)
                }
                catch {
                    throw EncryptedFileDataAdapterError.encryptedFileDataAdapterSaveError
                }
            }
            
        }
        catch {
            throw EncryptedFileDataAdapterError.encryptedFileDataAdapterSaveError
        }
    }
    
    
    
    public func loadCodableObject<T : Codable>(_ object: T.Type, fromDirectory directory: FileManager.SearchPathDirectory ) -> Any? {
        
        let jsonDecoder = JSONDecoder()
        
        do {
            
            guard let dir = FileManager.default.urls(for: directory, in: .userDomainMask).first, let key = self.getKey() else {                
                return nil
            }
                
            let fileURL = dir.appendingPathComponent(fileName)
            
            print("reading from \(fileURL)")
            
            let data = try Data(contentsOf: fileURL)
            
            do {
                let jsonData = try data.decrypt(key: key)

                return try jsonDecoder.decode(object.self, from: jsonData)
            }
            catch {
                return nil
            }
                            
        }
        catch {
            return nil
        }
    }
    
    
    
    public func loadCodableObjectFromBundel<T: Codable>(_ object: T.Type) -> Any? {
        
        
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: ""), let key = self.getKey() else {
            
            return nil
        }
            
        let jsonDecoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: fileURL)

            do {
                let jsonData = try data.decrypt(key: key)

                print("\(String(data: jsonData, encoding: .utf8) ?? "problem decrypting data")")
                return try jsonDecoder.decode(object.self, from: jsonData)
            }
            catch {
                return nil
            }
        }
        catch {
            return nil
        }

    }
    
    
} // end class
