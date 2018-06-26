//
//  StreetViewController.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 25.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import UIKit
import Alamofire
import SDLoader

class StreetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var streetsTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var parentAddress: String = ""
    var streets: [Street] = [Street]()
    let sdLoader = SDLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        streetsTableView.delegate = self
        streetsTableView.dataSource = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search streets"
        navigationItem.searchController = searchController
        
    }
    
    func getStreetsFromKazpost(address: String, completionHandler: @escaping(_ response: Kazpost?) -> Void) {
        
        let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
        let urlStr = "\(K.KazpostApi.baseURL)\(addressEncoded)"
        guard let url = URL(string: urlStr) else {
            return
        }
        print(url.absoluteString)
        sdLoader.startAnimating(atView: self.view)
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                print(error.localizedDescription)
                self.sdLoader.stopAnimation()
                return
            }
            
            if let data = response.data, let json = String(data: data, encoding: .utf8) {
                print("JSON: \(json)")
                let decoder = JSONDecoder()
                do {
                    var kazpost = Kazpost()
                    kazpost = try decoder.decode(Kazpost.self, from: data)
                    completionHandler(kazpost)
                    self.sdLoader.stopAnimation()
                } catch let err {
                    self.sdLoader.stopAnimation()
                    print("Kazpost err: \(err.localizedDescription)")
                }
            }
        }
    }
    
    func getStreetName(from street: Street) -> String{
        
        //street.fullAddress.
        

        return ""
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreetCell")!
        
        cell.textLabel?.text = getStreetName(from: streets[indexPath.row])
        cell.detailTextLabel?.text = streets[indexPath.row].addressRus
        
        return cell
    }
    
}

extension StreetViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getStreetsFromKazpost(address: "\(self.parentAddress) \(searchController.searchBar.text!)") { (kazpost) in
            guard let kazpost = kazpost else {
                return
            }
            print("streets count: \(kazpost.data.count)")
            self.streets = kazpost.data
            self.streetsTableView.reloadData()
        }
    }
    
    
}
