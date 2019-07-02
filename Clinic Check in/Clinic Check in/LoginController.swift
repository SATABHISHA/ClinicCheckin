//
//  LoginController.swift
//  Clinic Check in
//
//  Created by MK on 19/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog

class LoginController: UIViewController {
    
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.addViewShadow()
//        self.addCardView()
        
    }

    @IBAction func test(_ sender: Any) {
        print("tapped")
    }
    @IBAction func VeryfyNumber(_ sender: UIButton) {
        print("What a beauty")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillTransition( to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator ) {
//        DispatchQueue.main.async() {
//            print( "h:\(self.view.bounds.size.height)" )
//            print( "w:\(self.view.frame.size.width)" )
//        }
//    }
    
    // ====== Show a message for not touch on screen for a few seconds -> START =========== \\
    
    // the timeout in seconds, after which should perform custom actions
    // such as disconnecting the user
    private var timeoutInSeconds: TimeInterval {
        // 2 minutes
        return 2 * 60
    }
    
    private var idleTimer: Timer?
    
    // resent the timer because there was user interaction
    private func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(LoginController.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        NotificationCenter.default.post(name: .appTimeout, object: nil)
    }
    
    // ====== Show a message for not touch on screen for a few seconds -> END =========== \\
    
    func getOtpByNumber(){
        Alamofire.request(mainUrl + "login" + "+917685076979").responseJSON{ (responseData) -> Void in
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                print("Goal description: \(swiftyJsonVar)")
                
            }
            
        }
    }
    func addViewShadow() {
        let viewHeight = self.view.frame.height - 72;
        let viewShadow = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.bounds.size.height - viewHeight))
//        viewShadow.center = self.view.center
        print("HEIGHT CHECK SHADOW", self.view.bounds.size.height - viewHeight , viewHeight)
        viewShadow.backgroundColor = UIColor.white
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 1
        viewShadow.layer.zPosition = -1
        viewShadow.layer.shadowOffset = CGSize.zero
        viewShadow.layer.shadowRadius = 5
//        self.view.sendSubview(toBack: viewShadow)
        self.view.addSubview(viewShadow)
        
//        viewShadow.translatesAutoresizingMaskIntoConstraints = false
//        let horizontalConstraint = NSLayoutConstraint(item: viewShadow, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
//        let verticalConstraint = NSLayoutConstraint(item: viewShadow, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
//        let widthConstraint = NSLayoutConstraint(item: viewShadow, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
//        let heightConstraint = NSLayoutConstraint(item: viewShadow, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
//        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    func addCardView() {
//        let cardWidth = self.view.frame.width - 20;
        let viewShadow = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 20, height: 150))
        viewShadow.center = CGPoint(x: self.view.frame.width / 2, y: 200)// or use -> self.view.center
        viewShadow.backgroundColor = UIColor.white
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 0.5
        viewShadow.layer.zPosition = -1
        viewShadow.layer.shadowOffset = CGSize(width: -1, height: 1)
        viewShadow.layer.shadowRadius = 5
        //        self.view.sendSubview(toBack: viewShadow)
        self.view.addSubview(viewShadow)
        let lable = UILabel(frame: CGRect(x: 0, y: 200, width: self.view.frame.width - 30, height: viewShadow.frame.height))
        lable.center = CGPoint(x: self.view.frame.width / 2, y:200)// or use -> self.view.center
        lable.textAlignment = .left
//        lable.backgroundColor = UIColor.yellow
        
        lable.text = "1. If you are having problems call 650-690-2362 to speak to a doctors assistant.\n2. After 60 seconds of inactivity the session will reset.\n\nPlease enter your cell phone number to log in";
//        lable.font = UIFont(name: "Halvetica", size: 17)
        lable.lineBreakMode = .byWordWrapping
        lable.numberOfLines = 6
        self.view.addSubview(lable)
    }

}
// =================================== Extension ========================= \\
import Foundation

extension Notification.Name {
    
    static let appTimeout = Notification.Name("appTimeout")
    
}

