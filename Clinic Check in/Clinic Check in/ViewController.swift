//
//  ViewController.swift
//  Clinic Check in
//
//  Created by MK on 13/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var viewTap: UIView!  //----view created on the controller to tap on the screen
    var tapGesture = UITapGestureRecognizer()  //---for tapping on the screen
    public var sharedpreferences = UserDefaults.standard
    
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    var batteryState: UIDeviceBatteryState {
        return UIDevice.current.batteryState
    }
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeSassion()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: .UIDeviceBatteryLevelDidChange, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
//        //-------code to tap on the screen starts--------
//        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.myviewTapped(_:)))
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
//        viewTap.addGestureRecognizer(tapGesture)
//        viewTap.isUserInteractionEnabled = true
//         //-------code to tap on the screen ends--------
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.performSegue(withIdentifier: "loginview", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func batteryStateDidChange(_ notification: Notification) {
        switch batteryState {
        case .unplugged, .unknown:
            print("not charging")
            
        case .charging, .full:
            print("charging or full")
            self.performSegue(withIdentifier: "charging", sender: self)
        }
    }
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print(batteryLevel)
    }
//    Touch to any where then change the page
   //-------func to tap on the screen starts--------
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        
        /*if self.viewTap.backgroundColor == UIColor.yellow {
         self.viewTap.backgroundColor = UIColor.green
         }else{
         self.viewTap.backgroundColor = UIColor.yellow
         }*/
        print("tapped")
        self.performSegue(withIdentifier: "loginview", sender: self) //-----code to go from one controller to another controller
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

