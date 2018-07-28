//
//  InfoViewController.swift
//  CryptoBlock
//
//  Created by Filip Ma on 12.7.18.
//  Copyright © 2018 Filip Masar. All rights reserved.
//

import UIKit
import Parse

class InfoViewController: UIViewController {
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var change24Label: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var reqButton: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // ALERT
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func reqButtonClicked(_ sender: Any) {
        
        let q = PFQuery(className: "Requests")
        q.whereKey("name", equalTo: activeCrypto[1])
        q.getFirstObjectInBackground { (object, error) in
            if error != nil {
                
                let obj = PFObject(className: "Requests")
                obj["name"] = activeCrypto[1]
                obj.saveInBackground { (success, error) in
                    if error != nil {
                        self.showAlert(title: "Error", message: "Something went wrong! Please try again later.")
                    } else {
                        self.showAlert(title: "Requested", message: "More information will be available in few days")
                    }
                    return
                }
            }
            
            self.showAlert(title: "Requested", message: "More information will be available in few days")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        let q = PFQuery(className:"CryptoCurrencies")
        q.whereKey("name", equalTo: activeCrypto[1])
        q.getFirstObjectInBackground { (obj, error) in
            
            if error != nil {
                return
            }
            
            if let page = obj!["page"] as? String {
                if let url = URL(string: page) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = activeCrypto[1]
        navItem.rightBarButtonItem?.isEnabled = false
        navItem.rightBarButtonItem?.tintColor = UIColor.clear
        
        reqButton.isEnabled = false
        reqButton.isHidden = true
        
        loadImg()
        updateData()
        loadDescription()
    }
    
    // Information from Parse
    private func loadDescription() {
        let q = PFQuery(className:"CryptoCurrencies")
        q.whereKey("name", equalTo: activeCrypto[1])
        q.getFirstObjectInBackground { (obj, error) in
            
            if error != nil {
                self.reqButton.isHidden = false
                self.reqButton.isEnabled = true
                return
            }
            
            self.navItem.rightBarButtonItem?.isEnabled = true
            self.navItem.rightBarButtonItem?.tintColor = UIColor.red
            
            if let des = obj!["description"] as? String {
                self.infoTextView.text = des
            }
        }
    }
    
    private func loadImg() {
        var icon = UIImage()
        let url = URL(string: "https://s2.coinmarketcap.com/static/img/coins/64x64/" + activeCrypto[0] + ".png")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let urlData = data {
                if let img = UIImage(data: urlData) {
                    icon = img
                }
            }
            DispatchQueue.main.async {
                self.iconImg.image = icon
            }
        }
        task.resume()
    }
    
    private func updateData() {
        
        var p = 0.0, c = 0.0, m = 0.0
        let url = URL(string: "https://api.coinmarketcap.com/v2/ticker/" + activeCrypto[0] + "/")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let urlContent = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let ccData = jsonResult["data"] as? NSDictionary {
                        if let q = ccData["quotes"] as? NSDictionary {
                            if let usd = q["USD"] as? NSDictionary {
                                if let price = usd["price"] as? Double {
                                    p = price
                                }
                                if let change = usd["percent_change_24h"] as? Double {
                                    c = change
                                }
                                if let market = usd["market_cap"] as? Double {
                                    m = market
                                }
                            }
                        }
                        DispatchQueue.main.async(execute: {
                            self.priceLabel.text = "$ " + String(p)
                            self.change24Label.text = String(c) + " %"
                            self.marketCapLabel.text = "$ " + String(m)
                            if c >= 0 {
                                self.change24Label.textColor = UIColor.green
                            } else {
                                self.change24Label.textColor = UIColor.red
                            }
                        })
                        
                    }
                } catch {
                    print("JSON processing failed")
                }
            }
        }
        task.resume()
    }
    
    
}
