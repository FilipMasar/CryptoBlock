//
//  BlockchainViewController.swift
//  CryptoBlock
//
//  Created by Filip Ma on 19.7.18.
//  Copyright © 2018 Filip Masar. All rights reserved.
//

import UIKit

class BlockchainViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func homeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://en.wikipedia.org/wiki/Blockchain")
        let req = URLRequest(url: url!)
        webView.loadRequest(req)
    }

}
