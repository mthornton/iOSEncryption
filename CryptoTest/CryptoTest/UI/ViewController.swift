//
//  ViewController.swift
//  CryptoTest
//
//  Created by Michael Thornton on 10/4/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import UIKit






class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        /**
        NOTE
         This is not code that would normaly be in the app.  I placed it here just to show what I am using for the encryption passphrase and salt.  I don't want to keep those values
         in the app as plane text, so they get obfuscated.  The code below shows how to get the obfuscated byte array.  This code would be DELETED in the actaul app.
         */
        let o = Obfuscator()
        
        let passphrase = o.bytesByObfuscatingString(string: "BAE5D45D-08A2-46E2-B8D2-56CCD2CFDAB5")
        print("\(passphrase)")
        
        let salt = o.bytesByObfuscatingString(string: "world")
        print("\(salt)")
        
    }

    
    
    @IBAction func loadDictionaryButton_touched(_ sender: Any) {
         
        //exmample of ConfigurationController usage
        if let x = ConfigurationController.shared.valueForKey("facebook") {
            print("\(x)")
        }
    }
    
    
} // end class



