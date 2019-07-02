//
//  HomeController.swift
//  Clinic Check in
//
//  Created by MK on 07/05/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Toast_Swift

class HomeController: UIViewController {

    public var sharedpreferences = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome !!!")
        let returnValue: Any = UserDefaults.standard.object(forKey: "userID") as Any
        print(returnValue)
        // toast with a specific duration and position
        self.view.makeToast("Awesome!! You are checked in. Please review the information on the following screens. Better information leads to better health", duration: 5.0, position: .bottom)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func tapNextPage() {
        print("Go next page")
    }

}
