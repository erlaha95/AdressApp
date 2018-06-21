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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        if let url = URL(string: "http://localhost:8080/api/kato") {
            
            Alamofire.request(url).responseJSON { response in
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        let settlements: [Settlement] = try decoder.decode([Settlement].self, from: data)
                        for s in settlements {
                            print(s.nameRus)
                        }
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            }
        } else {
            print("url exception")
        }
    }
}

