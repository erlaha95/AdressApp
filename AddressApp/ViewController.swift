//
//  ViewController.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 6/20/18.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var settlements: [Settlement] = [Settlement]()
    
    let cityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tap)
        addPickerView()
        settlements = getSettlements()
        print(settlements.count)
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
    }
    
    func getSettlements(with parentId: Int) -> [Settlement] {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        var settlements = [Settlement]()
        if let url = URL(string: "http://localhost:8080/api/kato/\(parentId)") {
            Alamofire.request(url).responseJSON { response in
                if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        settlements = try decoder.decode([Settlement].self, from: data)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            }
        } else {
            print("url exception")
        }
        return settlements
    }
    
    func getSettlements() -> [Settlement] {
        var settlements = [Settlement]()
        if let url = URL(string: "http://localhost:8080/api/kato") {
            Alamofire.request(url).responseJSON { response in
                if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        settlements = try decoder.decode([Settlement].self, from: data)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            }
        } else {
            print("url exception")
        }
        return settlements
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "First row"
        } else {
            return "second row"
        }
    }
}











