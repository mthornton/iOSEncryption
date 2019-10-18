//
//  main.swift
//  encrypt
//
//  Created by Michael Thornton on 10/4/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation

print("Encrypt")

if CommandLine.arguments.count == 5 {
    
    let url = URL(fileURLWithPath: CommandLine.arguments[1])

    do {
        let rawData = try Data(contentsOf: url)
        
        let key = try Data.derivateKey(passphrase: CommandLine.arguments[3], salt: CommandLine.arguments[4])
        let iv = Data([3,5,7,1,3,8,0,3,5,2,5,6,1,2,2,0])
        
        let encryptedData = try rawData.encrypt(key: key, iv: iv)
        
        let newURL = URL(fileURLWithPath: CommandLine.arguments[2])
        
        try encryptedData.write(to: newURL)
    }
    catch let err {
        print("ERROR : \(err.localizedDescription)")
    }
    
}
else {
    
    print("usage: encrypt <filename> <newfilename> <passphrase> <salt>")
}
