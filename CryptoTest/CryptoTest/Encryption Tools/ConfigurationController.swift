//
//  ConfigurationController.swift
//  CryptoTest
//
//  Created by Michael Thornton on 10/7/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation


class ConfigurationController {
    

    static let shared = ConfigurationController(file: "configInfo.data")

    private var configValues: [String: String]
    
    
    
    private init (file: String) {
        
        let adapter = EncryptedFileDataAdapter(fileName: file)
        
        if let dict = adapter.loadCodableObjectFromBundel([String: String].self) as? [String: String] {
            self.configValues = dict
        }
        else {
            //could not find file, initilize with empty dictionary
            self.configValues = [String: String]()
        }
    }
    
    

    func valueForKey(_ key: String) -> String? {
        
        return self.configValues[key]
    }
    
} // end class
