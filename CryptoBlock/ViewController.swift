//
//  ViewController.swift
//  CryptoBlock
//
//  Created by Filip Ma on 11.7.18.
//  Copyright © 2018 Filip Masar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    // Back Button
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // ALERT
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // ADD Button clicked
    @IBAction func addButton(_ sender: Any) {
        
        let req = textField.text?.lowercased().replacingOccurrences(of: " ", with: "-")
        var find = false
        var id = ""
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(spinner)
        spinner.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let url = URL(string: "https://api.coinmarketcap.com/v2/listings/")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                spinner.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlert(title: "Adding Failed", message: "Please try again later!")
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let ccData = jsonResult["data"] as? NSArray {
                            for item in ccData {
                                if let cc = item as? NSDictionary {
                                    if let websiteSlug = cc["website_slug"] as? String {
                                        if websiteSlug == req {
                                            if let ccId = cc["id"] as? Int {
                                                find = true;
                                                id = String(ccId)
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async(execute: {
                            spinner.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            if find {
                                myCryptos.append(id)
                                UserDefaults.standard.set(myCryptos, forKey: "myCryptoList")
                                self.showAlert(title: "Success", message: "Successfully added new item")
                            } else {
                                self.showAlert(title: "Adding Failed", message: "Could not find this coin/token. Please try again!")
                            }
                        })
                        
                    } catch {
                        print("JSON processing failed")
                        spinner.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.showAlert(title: "Failed", message: "Something went wrong. Please try again later!")
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // close keyboard funcs
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
