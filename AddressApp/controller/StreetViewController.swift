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

class StreetViewController: UIViewController {
    
    @IBOutlet weak var streetsTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var region: Settlement?
    var district: Settlement?
    var village: Settlement?
    var delegate: AddressDelegate? = nil
    
    var streets: [Street] = [Street]()
    var filteredStreets: [Street] = [Street]()
    
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
        
        guard let region = self.region else { return }
        guard let district = self.district else { return }
        
        findKazpostObjectByKatoSettlementName(region.nameRusWithoutAffix) { (kazpostObject) in
            
            guard let kazpostObject = kazpostObject else { return }
            self.findKazpostObjects(by: kazpostObject.id, completionHandler: { (kazpostObjects) in
                var foundDistrict: KazpostObject?
                
                foundDistrict = kazpostObjects.filter{ $0.nameRus == district.nameRusWithoutAffix }.first
                
                if let foundDistrict = foundDistrict {
                    self.findKazpostObjects(by: foundDistrict.id, completionHandler: { (kazpostObjects) in
                        for obj in kazpostObjects {
                            if obj.actual != nil {
                                let street = Street(addressRus: obj.nameRus, addressKaz: obj.nameKaz, fullAddress: nil)
                                self.streets.append(street)
                            }
                        }
                        self.streetsTableView.reloadData()
                    })
                } else {
                    print("I didn't found DISTRICT")
                }
            })
        }
        
    }
    
    func findKazpostObjects(by parentId: String, completionHandler: @escaping(_ kazpostResponse: [KazpostObject]) -> Void) {
        guard let url = URL(string: "\(K.KazpostApi.objectsBaseURL)\(parentId)") else { return }
        var objects: [KazpostObject] = [KazpostObject]()
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                print(error.localizedDescription)
                self.sdLoader.stopAnimation()
                return
            }
            
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                let decoder = JSONDecoder()
                do {
                    let kazpostObjectApiResponse =
                        try decoder.decode(KazpostObjectApiResponse.self, from: data)
                    objects = kazpostObjectApiResponse.data
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            completionHandler(objects)
        }
    }
    
    func findKazpostObjectByKatoSettlementName(_ katoSettlementName: String, completionHandler: @escaping (_ kazpostObject: KazpostObject? ) -> Void) {
        print("findKazpostObjectByKatoSettlementName: \(katoSettlementName)")
        var kazpostObject: KazpostObject?
        guard let url = URL(string: "\(K.KazpostApi.objectsBaseURL)A1") else { return }
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                print(">>> findKazpostObjectByKatoSettlementName: \(error.localizedDescription)")
                self.sdLoader.stopAnimation()
                return
            }
            
            if let data = response.data, let json = String(data: data, encoding: .utf8) {
                print(">>> findKazpostObjectByKatoSettlementName:\n\(json)")
                let decoder = JSONDecoder()
                do {
                    let kazpostObjectApiResponse =
                        try decoder.decode(KazpostObjectApiResponse.self, from: data)
                    for obj in kazpostObjectApiResponse.data {
                        if obj.nameRus.contains(katoSettlementName) {
                            kazpostObject = obj
                            break
                        }
                    }
                    completionHandler(kazpostObject)
                } catch let error {
                    print(">>> findKazpostObjectByKatoSettlementName: \(error)")
                }
            }
        }
        
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
                    self.sdLoader.stopAnimation()
                    completionHandler(kazpost)
                } catch let err {
                    self.sdLoader.stopAnimation()
                    print("Kazpost err: \(err.localizedDescription)")
                }
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        //let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredStreets = streets.filter({( street : Street) -> Bool in
            if !searchBarIsEmpty() {
                return street.addressRus.lowercased().contains(searchText.lowercased())
            }
            return false
        })
        streetsTableView.reloadData()
    }
    
}

extension StreetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreetCell")!
        var street: Street
        if isFiltering() {
            street = filteredStreets[indexPath.row]
        } else {
            street = streets[indexPath.row]
        }
        
        cell.textLabel?.text = street.addressRus
        cell.detailTextLabel?.text = street.addressKaz
        
        return cell
    }
}

extension StreetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var street: Street
        if isFiltering() {
            street = filteredStreets[indexPath.row]
        } else {
            street = streets[indexPath.row]
        }
        guard let delegate = delegate else { return }
        delegate.didSelect(street: street.addressRus)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredStreets.count
        }
        return streets.count
    }
}

extension StreetViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension StreetViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}



