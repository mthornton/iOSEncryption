//
//  EncryptedFileDataAdapter.swift
//  CryptoTest
//
//  Created by Michael Thornton on 10/7/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//
//  From : gist.github.com/DejanEnspyra/80e259e3c9adf5e46632631b49cd1007


import Foundation

class Obfuscator {
        
    private var salt: String
    
    
    
    init() {
        self.salt = "\(String(describing: AppDelegate.self))\(String(describing: NSObject.self))"
    }
    
    
    
    init(with salt: String) {
        self.salt = salt
    }
    
    
    
    /**
     This method obfuscates the string passed in using the salt
     that was used when the Obfuscator was initialized.
     
     - parameter string: the string to obfuscate
     
     - returns: the obfuscated string in a byte array
     */
    func bytesByObfuscatingString(string: String) -> [UInt8] {
        let text = [UInt8](string.utf8)
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count
        
        var encrypted = [UInt8]()
        
        for t in text.enumerated() {
            encrypted.append(t.element ^ cipher[t.offset % length])
        }
        
        return encrypted
    }
    
    
    
    /**
     This method reveals the original string from the obfuscated
     byte array passed in. The salt must be the same as the one
     used to encrypt it in the first place.
     
     - parameter key: the byte array to reveal
     
     - returns: the original string
     */
    func reveal(key: [UInt8]) -> String {
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count
        
        var decrypted = [UInt8]()
        
        for k in key.enumerated() {
            decrypted.append(k.element ^ cipher[k.offset % length])
        }
        
        return String(bytes: decrypted, encoding: .utf8)!
    }
    
} // end class
