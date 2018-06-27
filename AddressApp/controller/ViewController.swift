//
//  ViewController.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 6/20/18.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import UIKit
import Alamofire
import SDLoader

class ViewController: UIViewController, AddressDelegate {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    
    @IBOutlet weak var streetTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var kazpostStreetView: UIView!
    
    
    var regions: [Settlement] = [Settlement]()
    var districts: [Settlement] = [Settlement]()
    var selectedRegion: Settlement?
    var selectedDistrict: Settlement?
    
    let cityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    let districtPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    let sdLoader: SDLoader = {
        let loader = SDLoader()
        return loader
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streetTextField.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tap)
        addPickerView()
        getSettlements()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(showSearchController))
        kazpostStreetView.addGestureRecognizer(tap1)
    }
    
    @objc func showSearchController() {
        performSegue(withIdentifier: "StreetVCSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapViewControllerSegue" {
            if let vc = segue.destination as? MapViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "StreetVCSegue" {
            if let vc = segue.destination as? StreetViewController {
                vc.region = selectedRegion
                vc.district = selectedDistrict
                vc.delegate = self
            }
        }
    }
    
    func didSelect(street: String) {
        streetTextField.text = street
    }
    
    @IBAction func showMapView(_ sender: Any) {
        performSegue(withIdentifier: "MapViewControllerSegue", sender: nil)
    }
    
    @objc func dismissPicker() {
        if cityTextField.isFirstResponder {
            cityTextField.resignFirstResponder()
        } else if districtTextField.isFirstResponder {
            districtTextField.resignFirstResponder()
        }
    }
    
    func addPickerView() {
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        cityTextField.inputView = cityPickerView
        
        districtPickerView.dataSource = self
        districtPickerView.delegate = self
        districtTextField.inputView = districtPickerView
    }
    
    func getStreetsFromKazpost(address: String, completionHandler: @escaping(_ response: Kazpost?) -> Void) {
        
        let addressEncoded = address.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
        let urlStr = "\(K.KazpostApi.baseURL)\(addressEncoded)"
        guard let url = URL(string: urlStr) else {
            return
        }
        sdLoader.startAnimating(atView: self.view)
        Alamofire.request(url).responseJSON { response in
            if let error = response.error {
                print(error.localizedDescription)
                self.sdLoader.stopAnimation()
                return
            }
            
            if let data = response.data, let _ = String(data: data, encoding: .utf8) {
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
    
    func getSettlements(with parentId: Int) {
        print("parentId: \(parentId)")
        var settlements = [Settlement]()
        let source = "{\"size\":100,\"query\":{\"filtered\":{\"query\":{\"bool\":{\"must\":[{\"match\":{\"Parent\":\(parentId)}}]}}}}}".addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)
        
        if let url = URL(string: "http://data.egov.kz/api/v2/kato?source=" + source!) {
            print(url.absoluteString)
            sdLoader.startAnimating(atView: self.view)
            Alamofire.request(url).responseJSON { response in
                if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        settlements = try decoder.decode([Settlement].self, from: data)
                        self.districts = settlements
                        self.sdLoader.stopAnimation()
                    } catch let err {
                        self.sdLoader.stopAnimation()
                        print("find childs err: \(err.localizedDescription)")
                    }
                }
            }
        } else {
            print("url exception")
        }
    }
    
    func getSettlements() {
        var settlements = [Settlement]()
        let source = "{\"size\":1000,\"query\":{\"filtered\":{\"query\":{\"bool\":{\"must\":[{\"range\":{\"AreaType\":{\"gte\":0,\"lte\":1}}},{\"match\":{\"Level\":2}}]}}}},\"sort\":[{\"NameKaz\":\"asc\"}]}".addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)
        
        if let url = URL(string: "http://data.egov.kz/api/v2/kato?source=" + source!) {
            sdLoader.startAnimating(atView: self.view)
            Alamofire.request(url).responseJSON { response in
                if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        settlements = try decoder.decode([Settlement].self, from: data)
                        self.regions = settlements
                        self.sdLoader.stopAnimation()
                    } catch let err {
                        self.sdLoader.stopAnimation()
                        print(err.localizedDescription)
                    }
                }
            }
        } else {
            print("url exception")
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPickerView {
            return regions.count
        }
        return districts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPickerView {
            return regions[row].nameRus
        }
        return districts[row].nameRus
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == cityPickerView {
            cityTextField.text = regions[row].nameRus
            getSettlements(with: regions[row].id)
            selectedRegion = regions[row]
        } else if pickerView == districtPickerView {
            districtTextField.text = districts[row].nameRus
            selectedDistrict = districts[row]
        }
    }
}











