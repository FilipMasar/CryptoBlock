//
//  ListViewController.swift
//  CryptoBlock
//
//  Created by Filip Ma on 11.7.18.
//  Copyright © 2018 Filip Masar. All rights reserved.
//

import UIKit

var myCryptos : [String] = ["1", "2"]
var activeCrypto : [String] = []

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data = [String: [String: Any]]()
    var images = [String: UIImage]()
    var pocet = 0
    
    private let refreshControl = UIRefreshControl()
    
    // SPINNER
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func homeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        
        // load permanent data
        if let temp = UserDefaults.standard.object(forKey: "myCryptoList") as? [String] {
            myCryptos = temp
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...")
        
    }
    
    // DID APPEAR
    override func viewDidAppear(_ animated: Bool) {
        updateData()
    }
    
    // DATA from web
    @objc private func updateData() {
        data = [:]
        images = [:]
        pocet = 0
        
        // START spinner
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(spinner)
        spinner.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        for crypto in myCryptos {
            // get NAME and PRICE
            let url = URL(string: "https://api.coinmarketcap.com/v2/ticker/" + crypto + "/")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                if let urlContent = data {
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let ccData = jsonRes["data"] as? NSDictionary {
                            if let name = ccData["name"] as? String {
                                if let q = ccData["quotes"] as? NSDictionary {
                                    if let usd = q["USD"] as? NSDictionary {
                                        if let price = usd["price"] as? Double {
                                            self.data[crypto] = ["name":name,"price":price]
                                            self.pocet += 2
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
                        }
                    } catch {
                        print("JSON processing failed")
                    }
                }
            }
            task.resume()
            
            // get IMG
            let url2 = URL(string: "https://s2.coinmarketcap.com/static/img/coins/32x32/" + crypto + ".png")!
            let task2 = URLSession.shared.dataTask(with: url2) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                if let urlData = data {
                    if let img = UIImage(data: urlData) {
                        self.images[crypto] = img
                        self.pocet += 1
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            task2.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCryptos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CryptoTableViewCell
        cell.nameLabel.text = ""
        cell.priceLabel.text = ""
        let ccId = myCryptos[indexPath.row]
        if pocet >= 3*myCryptos.count {
            
            // STOP spinner & refreshControl
            spinner.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.refreshControl.endRefreshing()
            
            if let ccName = data[ccId]!["name"] as? String {
                cell.nameLabel.text = ccName
            }
            if let ccPrice = data[ccId]!["price"] as? Double {
                cell.priceLabel.text = "$ " + String(ccPrice)
            }
            if let ccImg = images[ccId] {
                cell.iconImg.image = ccImg
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myCryptos.remove(at: indexPath.row)
            UserDefaults.standard.set(myCryptos, forKey: "myCryptoList")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        activeCrypto = []
        
        let ccId = myCryptos[indexPath.row]
        if let ccName = data[ccId]!["name"] as? String {
            activeCrypto.append(ccId)
            activeCrypto.append(ccName)
            performSegue(withIdentifier: "toInfo", sender: cell)
        }
    }
    
}
