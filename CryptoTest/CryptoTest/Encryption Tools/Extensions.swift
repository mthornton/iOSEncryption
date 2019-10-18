//
//  Extensions.swift
//  CryptoTest
//
//  Created by Michael Thornton on 10/4/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation
import CommonCrypto



enum Error: Swift.Error {
    case encryptionError(status: CCCryptorStatus)
    case decryptionError(status: CCCryptorStatus)
    case keyDerivationError(status: CCCryptorStatus)
}



extension Data {
    
    /**
     Creates a key based on the supplied passphrase and salt
     
     - parameter passphrase: phrase to use in generating the key
     - parameter salt: salt to use in generating the key
     
     - returns: key to use in encrypting data
     */
    static func derivateKey(passphrase: String, salt: String) throws -> Data {
        let rounds = UInt32(45_000)
        var outputBytes = Array<UInt8>(repeating: 0,
                                       count: kCCKeySizeAES256)
        let status = CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passphrase,
            passphrase.utf8.count,
            salt,
            salt.utf8.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            rounds,
            &outputBytes,
            kCCKeySizeAES256)
        
        guard status == kCCSuccess else {
            throw Error.keyDerivationError(status: status)
        }
        return Data(outputBytes)
    }
 
    

    /**
     Encrypts itself using the supplied key and initilization vector
     */
    func encrypt(key: Data, iv: Data) throws -> Data {

        // Output buffer (with padding)
        let outputLength = self.count + kCCBlockSizeAES128
        var outputBuffer = Array<UInt8>(repeating: 0,
                                        count: outputLength)
        var numBytesEncrypted = 0
        let status = CCCrypt(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             Array(key),
                             kCCKeySizeAES256,
                             Array(iv),
                             Array(self),
                             self.count,
                             &outputBuffer,
                             outputLength,
                             &numBytesEncrypted)
        guard status == kCCSuccess else {
            throw Error.encryptionError(status: status)
        }
        let outputBytes = iv + outputBuffer.prefix(numBytesEncrypted)
        
        return Data(outputBytes)
    }
    
    

    /**
     Decrypts itself with the supplied key.
     */
    func decrypt(key: Data) throws -> Data {
        // Split IV and cipher text
        let iv = self.prefix(kCCBlockSizeAES128)
        let cipherTextBytes = self
                               .suffix(from: kCCBlockSizeAES128)
        let cipherTextLength = cipherTextBytes.count
        // Output buffer
        var outputBuffer = Array<UInt8>(repeating: 0,
                                        count: cipherTextLength)
        var numBytesDecrypted = 0
        let status = CCCrypt(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             Array(key),
                             kCCKeySizeAES256,
                             Array(iv),
                             Array(cipherTextBytes),
                             cipherTextLength,
                             &outputBuffer,
                             cipherTextLength,
                             &numBytesDecrypted)
        guard status == kCCSuccess else {
            throw Error.decryptionError(status: status)
        }
        // Discard padding
        let outputBytes = outputBuffer.prefix(numBytesDecrypted)
        return Data(outputBytes)
    }
    
} // end class
