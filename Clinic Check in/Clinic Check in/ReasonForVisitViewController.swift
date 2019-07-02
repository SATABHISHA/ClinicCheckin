//
//  ReasonForVisitViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 08/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import MRCountryPicker
import Toaster

class ReasonForVisitViewController: UIViewController, UITextViewDelegate {

     @IBOutlet weak var NaveHeaderView: UINavigationItem!
    
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    
    public var deviceID = UIDevice.current.identifierForVendor!.uuidString
    public var sharedpreferences = UserDefaults.standard
    public var isLogin: Bool!
    public var userID: Int!
    public var uuid: String!
    public var fullName: String!
    
    @IBOutlet weak var visitTextArea: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        InitializationNavItem()
        addGestureSwipe()
        self.shadow(element: submitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        
        isLogin = self.sharedpreferences.bool(forKey: "isLogin")
        userID = self.sharedpreferences.integer(forKey: "userID")
        uuid = self.sharedpreferences.string(forKey: "uuid")
        fullName = self.sharedpreferences.string(forKey: "fullName")
        UserSingletonModel.sharedInstance.fullname=fullName!
        
         //---------code to make the text with rounded edges code starts-------------
        visitTextArea.delegate = self
        visitTextArea.text = "Enter a description....."
        visitTextArea.textColor = UIColor.lightGray
        
        visitTextArea.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        visitTextArea.layer.borderWidth = 1.0
        visitTextArea.layer.cornerRadius = 10
        
        loadDataFromSerever();
         //---------code to make the text with rounded edges code ends-------------
        // Do any additional setup after loading the view.
    }
    
    func addGestureSwipe(){
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapNextPage))
        recognizer.direction = .left
        self.view.addGestureRecognizer(recognizer)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if visitTextArea.textColor == UIColor.lightGray {
            visitTextArea.text = ""
            visitTextArea.textColor = UIColor.black
        }
    }
    
    private var reasonsForVisitData = [String:AnyObject]()
    func loadDataFromSerever() {
        loaderStart()
        let api = mainUrl + "checkReasonsForVisitForNativeApp/" + "\(self.uuid!)"
        Alamofire.request( api ).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                if let objReasonsForVisit = responseData.result.value as? [String : Any] {
                    for (key, value) in objReasonsForVisit {
                        self.reasonsForVisitData[key] = JSON(value) as AnyObject
                    }
                }
                
            } else {
                let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                self.showPopupDialog(title: "Network Error !!!", message: "Some errror occured. Please contact us...", Buttons: [btnSessionEnd], Alignment: .horizontal)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // ====================== Blur Effect Defiend START ================= \\
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    func loaderStart() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
        loader.alpha = 2
        view.addSubview(loader)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        loadingIndicator.startAnimating();
        loader.contentView.addSubview(loadingIndicator)
        
        // screen roted and size resize automatic
        loader.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
    }
    
    func loaderEnd() {
        self.loader.removeFromSuperview();
    }
    // ====================== Blur Effect Defiend END ================= \\
    
    @IBOutlet weak var submitBtnView: UIButton!
    @IBAction func submitActionBtn(_ sender: Any) {
        let reasonsForVisit = self.reasonsForVisitData["data"] as AnyObject
        let reasonsForVisitData = JSON(reasonsForVisit)
        
        print("reasonsForVisitData: ", reasonsForVisitData)
        let api = mainUrl + "saveReasonForVisitForNativeApp/" + "\(reasonsForVisitData["eventId"].intValue)"
        let sentData = [
            "eventId": reasonsForVisitData["eventId"].intValue,
            "eventOn": reasonsForVisitData["eventOn"].stringValue,
            "purposeDetail": reasonsForVisitData["reasonForVisitDetail"].stringValue,
            "purposeId": reasonsForVisitData["reasonForVisitID"].intValue ,
            "purposeType": reasonsForVisitData["type"].stringValue,
            "visitedDoc": reasonsForVisitData["visitedDocID"].intValue,
            "visitedDocName": reasonsForVisitData["visitedDocName"].stringValue,
            "reasonForVisit": "11",
            "reasonForVisitDetails": self.visitTextArea.text!
            ] as [String : Any];
        
    
        print("sentdata: ",api, sentData)
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                let swiftyJsonVar=JSON(response.result.value!)
                print("swiftyJsonVar ", swiftyJsonVar)
                
                Toast(text: "Thank you for updated information", duration: Delay.short).show()
                self.tapNextPage()
                break
                
            case .failure(let error):
                print("Error: ",error)
            }
        }
        
    }
    
    func shadow(element: UIView, radius: CGFloat, opacity: Float, offset: CGSize, shadowColor: CGColor) {
        element.layer.shadowColor = shadowColor
        element.layer.shadowOpacity = opacity
        //        Header.layer.zPosition = -1
        element.layer.shadowOffset = offset
        element.layer.shadowRadius = radius
    }
    // ====================== Popup Dialog START ================= \\
    func showPopupDialog(title: String, message: String, Buttons: Array<Any>, Alignment: UILayoutConstraintAxis) {
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: Alignment,//.horizontal, // .vertical
            transitionStyle: .zoomIn,
            gestureDismissal: true,
            hideStatusBar: true
        )
        if Buttons.count > 0 {
            popup.addButtons(Buttons as! [PopupDialogButton])
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    // ====================== Popup Dialog END ================= \\
    
    // ============== Create Navigation item START ================= \\
    func InitializationNavItem() {
        NaveHeaderView.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(tapNextPage))
        
        loginNameLabel.text = UserSingletonModel.sharedInstance.fullname
        //        footerView.layer.zPosition = 2
        self.shadow(element: footerView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        
        logoutBtnView.addTarget(self, action:#selector(self.logout), for: .touchUpInside)
        self.shadow(element: logoutBtnView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        logoutBtnView.layer.cornerRadius = 10
    }
    @objc func tapNextPage() {
        self.performSegue(withIdentifier: "allergic", sender: self)
    }
    // ============== Create Navigation item END ================= \\
    // ==================== Footer View START ========================= \\
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logoutBtnView: UIButton!
    @IBAction func logoutAction(_ sender: Any) {
        print("Logout")
    }
    @objc func logout() {
        print("Logout function")
        removeSassion()
    }
    
    
    // ==================== Footer View END ========================= \\
    
    
    @IBAction func prev(_ sender: Any) {
        self.performSegue(withIdentifier: "contacthome", sender: self)
    }
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    
}
