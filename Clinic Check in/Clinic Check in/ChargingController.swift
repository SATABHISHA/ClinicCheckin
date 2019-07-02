//
//  ChargingController.swift
//  Clinic Check in
//
//  Created by MK on 19/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

class ChargingController: UIViewController {
    @IBOutlet weak var viewTap: UIView!
    
    public var sharedpreferences = UserDefaults.standard
    
    var tapGesture = UITapGestureRecognizer()  //---for tapping on the screen
    override func viewDidLoad() {
        super.viewDidLoad()
//        removeSassion()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Do any additional setup after loading the view.
        //-------code to tap on the screen starts--------
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        viewTap.addGestureRecognizer(tapGesture)
        viewTap.isUserInteractionEnabled = true
        //-------code to tap on the screen ends--------
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //-------func to tap on the screen starts--------
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "login", sender: self) //-----code to go from one controller to another controller
    }
    //-------func to tap on the screen ends--------
    func removeSassion() {
        self.sharedpreferences.set(false, forKey: "isLogin")
        self.sharedpreferences.removeObject(forKey: "userID")
        self.sharedpreferences.removeObject(forKey: "uuid")
        self.sharedpreferences.removeObject(forKey: "emailAddress")
        self.sharedpreferences.removeObject(forKey: "fullName")
        
    }

}
