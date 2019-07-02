//
//  LoginViewController.swift
//  Clinic Check in
//
//  Created by MK on 27/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import MRCountryPicker
import Toaster

class LoginViewController: UIViewController, UITextFieldDelegate, MRCountryPickerDelegate {

    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var deviceID = UIDevice.current.identifierForVendor!.uuidString
    public var sharedpreferences = UserDefaults.standard
    public var userID: Int!
    public var uuid: String!
    @IBOutlet weak var Header: UIView!
    @IBOutlet weak var btn_verify: UIButton!
    
    // ================== Verify Number Popup Start ================== \\
    @IBOutlet var verifyNumberPopup: UIView!
    
    @IBOutlet weak var verifyPopupOkBtnView: UIButton!
    @IBOutlet weak var verifyPopupCacelBtnView: UIButton!
    
    @IBOutlet weak var verifyNumberInput: UITextField!
    @IBAction func otpInputTextChange(_ sender: UITextField) {
        textSouportMaxLeangth(textFieldName: verifyNumberInput, max: 6)
    }
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    // ====================== Blur Effect Defiend ================= \\
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    @IBAction func VerifyNumber(_ sender: Any) {
        //======================================================= For test login ============================================================= \\
        
        let isLogin = self.sharedpreferences.bool(forKey: "isLogin")
        print("is login", isLogin)
        if(isLogin == true){
            print("is true")
//            UserSingletonModel.sharedInstance.numberWithCode = "+917685076979"
           
            self.performSegue(withIdentifier: "ContactPage", sender: self)
            return
        }
        
        //======================================================= END test =========================================================================== \\
        
        // Prepare the popup assets
        let numberWithCode = selectedPhoneCode + self.phoneNumberText.text!;
        if self.phoneNumberText.text!.isEmpty {
            self.shadow(element: phoneNumberText, radius: 0, opacity: 1, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.red.cgColor)
            UIView.animate(withDuration: 0.5, animations: {
                self.phoneNumberText.backgroundColor = UIColor.red
            }) { (success) in
                self.phoneNumberText.backgroundColor = UIColor.groupTableViewBackground
            }
            return
        }
        // Call server side to check
        
        verifyNumberInput.text = nil
        self.shadow(element: phoneNumberText, radius: 0, opacity: 1, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.gray.cgColor)
        
        loaderStart()
        
        Alamofire.request(mainUrl + "login/" + numberWithCode).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                let status = swiftyJsonVar["status"].stringValue
                let message = swiftyJsonVar["subTitle"].stringValue
                if(status == "failed"){
                    let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                    self.showPopupDialog(title: "Failed", message: message, Buttons: [btnSessionEnd])
                } else {
                    UserSingletonModel.sharedInstance.numberWithCode = numberWithCode
                    self.userID = swiftyJsonVar["userID"].int!
                    self.uuid = swiftyJsonVar["uuid"].stringValue
                    self.openVerifyPopup();
                }
            } else {
                let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                self.showPopupDialog(title: "Network Error !!!", message: "Some errror occured. Please contact us...", Buttons: [btnSessionEnd])
            }

        }
    }
    @IBAction func cancelVerifyPopup(_ sender: Any) {
        cancelVerifyPopup();
    }
    @IBAction func okVerifyPopup(_ sender: Any) {
        print("Ok verify popup")
        self.verifyNumberInput.backgroundColor = UIColor.groupTableViewBackground
        if self.verifyNumberInput.text!.isEmpty {
            print("Nothing to see here")
            UIView.animate(withDuration: 0.5, animations: {
                self.verifyNumberInput.backgroundColor = UIColor.red
            }) { (success) in
                self.verifyNumberInput.backgroundColor = UIColor.groupTableViewBackground
            }
            return
        }
        let api = mainUrl + "validateOTP/" + self.verifyNumberInput.text! + "/\(self.uuid!)"
        loaderStart()
        Alamofire.request( api ).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                print("testing \(swiftyJsonVar)")
                let status = swiftyJsonVar["status"].stringValue
                let message = swiftyJsonVar["message"].stringValue
                if(status == "success"){
                    self.cancelVerifyPopup();
                    let uId = swiftyJsonVar["userid"].stringValue
                    let uuid = swiftyJsonVar["uuid"].stringValue
                    let emailAddress = swiftyJsonVar["userObject"]["emailAddress"].stringValue
                    let fullName = swiftyJsonVar["userObject"]["userFullName"].stringValue
                    self.stroreSassion(userID: Int(uId)!, uuid: uuid, emailAddress: emailAddress, fullName: fullName)
                    
                    Toast(text: "Awesome!! You are checked in. Please review the information on the following screens. Better information leads to better health", duration: Delay.short).show()
                    self.performSegue(withIdentifier: "ContactPage", sender: self)
                } else if(status == "failed") {
                    var title = "ERROR !!!"
                    var showMessage = "Some errror occured. Please contact us..."
                    if( message == "OTP not correct" ) {
                        title = "OTP not correct"
                        showMessage = "Entered OTP is not correct. Please enter correct otp"
                    } else if( message == "Not a valid OTP" ) {
                        title = "Not a valid OTP"
                        showMessage = "Entered OTP is expired. Please enter valid OTP."
                    }
                    let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                    self.showPopupDialog(title: title, message: showMessage, Buttons: [btnSessionEnd])
                } else {
                    let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                    self.showPopupDialog(title: "ERROR !!!", message: "Some errror occured. Please contact us...", Buttons: [btnSessionEnd])
                }
            }

        }
    }
    func showPopupDialog(title: String, message: String, Buttons: Array<Any>) {
        let popup = PopupDialog(title: title,
                                message: message,
                                // buttonAlignment: .horizontal,
            transitionStyle: .zoomIn,
            gestureDismissal: true,
            hideStatusBar: true
        )
        if Buttons.count > 0 {
            popup.addButtons(Buttons as! [PopupDialogButton])
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    func designVerifyPopup() {
        verifyNumberInput.placeholder = "------"
        self.shadow(element: verifyPopupCacelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: verifyPopupOkBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    // ================== Verify Number Popup END ================== \\
    func textSouportMaxLeangth(textFieldName: UITextField, max: Int) {
        var length = textFieldName.text?.characters.count
        var textValue = textFieldName.text
        
        if (length! > max)
        {
            let index = textValue?.index((textValue?.startIndex)!, offsetBy: max)
            textFieldName.text = verifyNumberInput.text?.substring(to: index!)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove Sassion first
//        removeSassion()
        
        // Do any additional setup after loading the view.
        btn_verify.isEnabled = false
        self.shadow(element: Header, radius: 5, opacity: 1, offset: CGSize.zero, shadowColor: UIColor.black.cgColor)
        self.shadow(element: btn_verify, radius: 2, opacity: 10, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.black.cgColor)
        // === design Select Country view ===
        designSelectCountry();
        // === design verify popup view ===
        designVerifyPopup();
        
        //=========keyboard code=======
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        //=========keyboard code ends=======
    }
    
    //==========for keyboard=====
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (verifyNumberInput.returnKeyType == UIReturnKeyType.go){
            Toast(text: "Hello").show()
        }
        return true
    }
    //======keyboard code ends======
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(InactiveMode), name: NSNotification.Name(rawValue: "InactiveMode"), object: nil)
    }
    
    @objc func InactiveMode(){
        sessionEndAutoPopup()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Print touch")
        var touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        print("touch view name",touch?.view)
//        if touch?.view! == self.view {
//            print("Print touch condition")
//        }
//        touch?.view?.isHidden = true
    }
    
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
    func blurEffect() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.9
        view.addSubview(blurEffectView)
        // screen roted and size resize automatic
        blurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
    }
    func canelBlurEffect() {
        self.blurEffectView.removeFromSuperview();
    }
    func openVerifyPopup() {
        blurEffect()
        self.view.addSubview(verifyNumberPopup);
        verifyNumberPopup.center = self.view.center;
        verifyNumberPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        verifyNumberPopup.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.verifyNumberPopup.alpha = 1
            self.verifyNumberPopup.transform = CGAffineTransform.identity
        }
        self.shadow(element: verifyNumberPopup, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
    }
    func cancelVerifyPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.verifyNumberPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.verifyNumberPopup.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.verifyNumberPopup.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shadow(element: UIView, radius: CGFloat, opacity: Float, offset: CGSize, shadowColor: CGColor) {
        element.layer.shadowColor = shadowColor
        element.layer.shadowOpacity = opacity
//        Header.layer.zPosition = -1
        element.layer.shadowOffset = offset
        element.layer.shadowRadius = radius
    }
    func sessionEndAutoPopup() {
        let popOverVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "sesionEnd") as! sessionEndController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame=self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    // ================== Cuntru Picker Start ================== \\
    
    @IBOutlet weak var countryPopupHeader: UILabel!
    @IBOutlet weak var showSelectedCountryName: UILabel!
    @IBOutlet weak var showSelectedCuntryView: UIView!
    @IBOutlet var cuntryPicker: UIView!
    @IBOutlet weak var cuntryPickerScrol: MRCountryPicker!
    @IBOutlet weak var countryFlagView: UIImageView!
    
    @IBOutlet weak var countryPopupCancelBtn: UIButton!
    @IBOutlet weak var countryPopupOkBtn: UIButton!
    
    @IBOutlet weak var countryCodeView: UILabel!
    @IBOutlet weak var phoneNumberText: UITextField!
    
    @IBOutlet weak var numberView: UIView!
    var selectedPhoneCode: String! = "+1"
    var selectedCountryCode: String!
    var selectedCountryName: String!
    var selectedCountryFlag: UIImage!
    
    var setCountryCode = "US"
    
    //-------countrPhonePicker func helps to pick the country code(starts here)---------
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        selectedPhoneCode = phoneCode
        selectedCountryName = name
        selectedCountryCode = countryCode
        selectedCountryFlag = flag
    }
    //-------countrPhonePicker func helps to pick the country code(ends here)---------
    
    @IBAction func cuntryPickerCacleBtn(_ sender: Any) {
        closeCountryPopup()
    }
    @IBAction func selectCountry(_ sender: Any) {
        setCountryCode = selectedCountryCode
        self.showSelectedCountryName.text = selectedCountryName
        self.countryFlagView.image = selectedCountryFlag
        self.countryCodeView.text = selectedPhoneCode
        closeCountryPopup()
    }
    func designSelectCountry() {
        self.phoneNumberText.delegate = self
        self.showSelectedCountryName.text = "United States"
        self.countryCodeView.text = selectedPhoneCode
        
        self.showSelectedCountryName.textColor = UIColor.init(red: 0.045, green: 0.716, blue: 0.055, alpha: 0.66)
        self.shadow(element: showSelectedCuntryView, radius: 0, opacity: 2, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.gray.cgColor)
        //phoneNumberText // numberView
        phoneNumberText.placeholder = "Enter phone number"
        self.shadow(element: phoneNumberText, radius: 0, opacity: 1, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.gray.cgColor)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openSelectCountryPopup(_:)))
        showSelectedCuntryView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectCountryPopup(_:)))
        countryFlagView.addGestureRecognizer(tap2)
        countryFlagView.isUserInteractionEnabled = true
        
        //-----------latest countrycode picker using MRCountryPicker library code----------
        cuntryPickerScrol.countryPickerDelegate = self
        cuntryPickerScrol.showPhoneNumbers = true
        //countryPicker.setCountry("SI")
        cuntryPickerScrol.setCountry(setCountryCode)
        
        //countryPicker.setLocale("sl_SI")
        cuntryPickerScrol.setLocale("India")
        //  countryPicker.setCountryByName("Canada")
        //        cuntryPickerScrol.setCountryByName("United States")
        //-----------latest countrycode picker using MRCountryPicker library code ends----------
        
        self.shadow(element: countryPopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: countryPopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    // ======> Phone number field allow anly number
    @IBAction func phoneNumberTextChange(_ sender: UITextField) {
        if( phoneNumberText.text?.characters.count == 10 ) {
            btn_verify.isEnabled = true
        } else {
            btn_verify.isEnabled = false
        }
//        textSouportMaxLeangth(textFieldName: phoneNumberText, max: 10)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @objc func openSelectCountryPopup(_ sender: UITapGestureRecognizer) {
        blurEffect()
        self.view.addSubview(cuntryPicker);
        cuntryPicker.center = self.view.center;
        cuntryPicker.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        cuntryPicker.alpha = 054444
        
        UIView.animate(withDuration: 0.4) {
            self.cuntryPicker.alpha = 1
            self.cuntryPicker.transform = CGAffineTransform.identity
        }
        self.shadow(element: cuntryPicker, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
        
        countryPopupHeader.layer.borderWidth = 1
        countryPopupHeader.layer.borderColor = UIColor.gray.cgColor
//        self.shadow(element: countryPopupHeader, radius: 1, opacity: 3, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.black.cgColor)
        
    }
    func closeCountryPopup() {
        cuntryPickerScrol.setCountry(setCountryCode)
        UIView.animate(withDuration: 0.3, animations: {
            self.cuntryPicker.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.cuntryPicker.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.cuntryPicker.removeFromSuperview();
            self.blurEffectView.removeFromSuperview();
        }
    }
    
    // ================== Cuntru Picker END ================== \\
    // ============= Sassion store START ================= \\
    func stroreSassion(userID: Int, uuid: String, emailAddress: String, fullName: String) -> Bool {
        // DO
        self.sharedpreferences.set(true, forKey: "isLogin")
        self.sharedpreferences.set(userID, forKey: "userID")
        self.sharedpreferences.set(uuid, forKey: "uuid")
        self.sharedpreferences.set(emailAddress, forKey: "emailAddress")
        self.sharedpreferences.set(fullName, forKey: "fullName")
        self.sharedpreferences.synchronize()
        return true;
    }
    func removeSassion() {
        self.sharedpreferences.set(false, forKey: "isLogin")
        self.sharedpreferences.removeObject(forKey: "userID")
        self.sharedpreferences.removeObject(forKey: "uuid")
        self.sharedpreferences.removeObject(forKey: "emailAddress")
        self.sharedpreferences.removeObject(forKey: "fullName")
    }
    // ============= Sassion store END ================= \\
}
