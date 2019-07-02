//
//  sessionEndController.swift
//  Clinic Check in
//
//  Created by MK on 30/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

class sessionEndController: UIViewController {

    @IBOutlet weak var sessionEndPopup: UIView!
    @IBOutlet weak var remainingTimeLable: UILabel!
    @IBOutlet weak var displayRemainingTime: UILabel!
    @IBOutlet weak var viewSessionEndBtn: UIButton!
    
    var originalCenter: CGPoint!
    override func viewDidLoad() {
        super.viewDidLoad()
        originalCenter = sessionEndPopup.center;
        
        self.view.backgroundColor=UIColor.black.withAlphaComponent(0.7)
        
        sessionEndPopup.layer.cornerRadius=0
        sessionEndPopup.layer.shadowColor = UIColor.black.cgColor
//        sessionEndPopup.transform = CGAffineTransform.init(scaleX: 0.3, y: 1.0)
        sessionEndPopup.layer.shadowOpacity = 1
        //        Header.layer.zPosition = -1
        sessionEndPopup.layer.shadowOffset = CGSize.zero
        sessionEndPopup.layer.shadowRadius = 10
        sessionEndPopup.layer.borderWidth = 1
        sessionEndPopup.layer.borderColor = UIColor.gray.cgColor
        
        viewSessionEndBtn.layer.borderWidth = 1
        viewSessionEndBtn.layer.borderColor = UIColor.gray.cgColor
        
        displayRemainingTime.textColor = UIColor.gray
        self.rotedAnimation();
        // Do any additional setup after loading the view.
        self.startTimer();
    }
    func rotedAnimation() {
//        sessionEndPopup.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
//        sessionEndPopup.center.y = sessionEndPopup.center.y - (sessionEndPopup.frame.height / 2)
        sessionEndPopup.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.1)
//        sessionEndPopup.transform = CGAffineTransform.init(rotationAngle: 1.8);
        UIView.animate(withDuration: 0.6, delay: 0, options: .allowUserInteraction, animations: {
            self.sessionEndPopup.transform = .identity
        }) { (success) in
            self.sessionEndPopup.center = self.originalCenter
            self.sessionEndPopup.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sessionEndBtn(_ sender: Any) {
        sessionEndPopup.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        //        sessionEndPopup.transform = CGAffineTransform.init(rotationAngle: 1.8);
        UIView.animate(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            self.sessionEndPopup.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.1)
        }) { (success) in
            self.view.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
//            self.performSegue(withIdentifier: "notChargingHome", sender: self) //-----code to go from one controller to another controller
            self.performSegue(withIdentifier: "rootPage", sender: self)
        }
        
    }
    
    // =================== TimeInterval start ======================= \\
    var countdownTimer: Timer!
    var totalTime = 19
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc private func updateTime() -> String {
        displayRemainingTime.textAlignment = .center;
        let remaningTime = timeFormatted(totalTime);
        displayRemainingTime.text = "\(remaningTime)"
        displayRemainingTime.textColor = UIColor.gray
        let remaningTimeOfInt = Int(remaningTime);
        if remaningTimeOfInt! < 11 {
            displayRemainingTime.textColor = UIColor.red
        }
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
            self.sessionEndBtn(self)
        }
        //  print(remaningTime)
        UserSingletonModel.sharedInstance.remainingtime=remaningTime
        return remaningTime
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        //        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d", seconds)
    }
    
    
    // =================== TimeInterval Stop ======================= \\
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
