//
//  ProfileViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 04/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Foundation
import SystemConfiguration
import Toaster
import PopupDialog

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/"
    public var sharedpreferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitializationNavItem()
        loadDataFromServer()
        // Do any additional setup after loading the view.
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
    // ============== Create Navigation item START ================= \\
    
    @IBOutlet weak var NaveHeaderView: UINavigationItem!
    func InitializationNavItem() {
        NaveHeaderView.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapCompleteSession))
        
        loginNameLabel.text = UserSingletonModel.sharedInstance.fullname!
        //        footerView.layer.zPosition = 2
        self.shadow(element: footerView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        
        self.shadow(element: logoutBtnView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        logoutBtnView.layer.cornerRadius = 10
    }
    @objc func tapCompleteSession() {
        print(" Complete Session")
        
        let btnCancel = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnTouchToTalk = DefaultButton(title: "Touch to talk", height: 50, dismissOnTap: true) {
            self.presentPrompt()
        }
        let btnOk = DefaultButton(title: "OK", height: 50, dismissOnTap: true) {
            self.removeSassion()
        }
        self.showPopupDialog(title: "Thank you", message: "Thanks, you're all checked in! Please have a seat and your provider will be with you shortly.", Buttons: [btnCancel, btnTouchToTalk, btnOk], Alignment: .horizontal)
    }
    func presentPrompt(){
        
        let btnCancel = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnSend = DefaultButton(title: "Send", height: 50, dismissOnTap: true) {
            self.sendMessage()
        }
        self.showPopupDialog(title: "Touch to talk", message: "Tap to 'Send' button and Doctor Assistant will call (\(UserSingletonModel.sharedInstance.numberWithCode!)) you immediately. Tap to 'Cancel' otherwise.", Buttons: [btnCancel, btnSend], Alignment: .horizontal)
        
    }
    func sendMessage(){
        let api = mainUrl + "sendMessageOnDaChanelForNativeApp/"+"\(UserSingletonModel.sharedInstance.uuid!)"
        
        let sentData: [String:Any] = [
            "message": UserSingletonModel.sharedInstance.numberWithCode!
        ]
        print("send messageL: ",api,sentData)
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{

            case .success:
                let swiftyJsonVar = JSON(response.result.value!)
                Toast(text: "Thank you. Doctor Assistant will call you immediately.", duration: Delay.short).show()
                self.removeSassion()
                break

            case .failure(let error):
                print("Error: ", error)
            }
        }
    }
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "pharmacy", sender: self)
    }
    // ============== Create Navigation item END ================= \\
    // ==================== Footer View START ========================= \\
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logoutBtnView: UIButton!
    @IBAction func logoutAction(_ sender: Any) {
        removeSassion()
    }
    
    // ==================== Footer View END ========================= \\
    func shadow(element: UIView, radius: CGFloat, opacity: Float, offset: CGSize, shadowColor: CGColor) {
        element.layer.shadowColor = shadowColor
        element.layer.shadowOpacity = opacity
        //        Header.layer.zPosition = -1
        element.layer.shadowOffset = offset
        element.layer.shadowRadius = radius
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
    
    //=====================function to load profile image from api starts==============
    
    @IBOutlet weak var profileImageView: UIImageView!
    func loadDataFromServer(){
        profileImageView.image = #imageLiteral(resourceName: "blank-profile-picture")
        let api = mainUrl + "showImageForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        
        print("Api: ", api)
//        let url = URL(string: api)!
//        self.profileImageView.af_setImage(withURL: url)
        loaderStart()
        Alamofire.request(api).responseData { (response) in
            self.loaderEnd()
            if response.error == nil {
                // Show the downloaded image:
                if let data = response.data {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
    }
    //=====================function to load profile image from api ends==============
    
    
    //========================camera code starts===================
    
    @IBAction func takePhotoFromCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
//            self.present(imagePicker, animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
//            print("Image data: ",imagePicker)
        }
    }
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.contentMode = .scaleToFill
            picker.dismiss(animated: true, completion: nil)
            loaderStart()
            
//            var imageData = UIImagePNGRepresentation(pickedImage)
            var imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            let base64String = imageData?.base64EncodedString()
            
            //===============upload photo to the server code starts==========
            //-------code for dateformatting-------
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let dateInFormat = dateFormatter.string(from: NSDate() as Date)
            //-------code for dateformatting code ends-------
            
            //---code to get current timezone code starts-----
            let zoneName = NSTimeZone.abbreviationDictionary
            // Iterate through the dictionary
            let currentAutoUpdateTZ = TimeZone.current.identifier
            var localTimeZone:String!
            for (key,value) in zoneName {
                if(value == currentAutoUpdateTZ){
                    localTimeZone = key
                }
            }
            //---code to get current timezone code ends-----
            
            let api = mainUrl + "imageUploadForNativeApp/" + "\(UserSingletonModel.sharedInstance.userid!)"
            
            let sentData: [String:Any] = [
                "fileName": "cliniccheckinapp_\(NSDate().timeIntervalSince1970).jpg",
                "snaptoemrFilePath": base64String,
                "scEmrUserID": "",
                "snaptoemrFlag": "true",
                "uploadedDataTime": dateInFormat,
                "uploadedTimeZone": localTimeZone,
                "userId": UserSingletonModel.sharedInstance.userid!
            ]
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{
                case .success:
                    self.loaderEnd()
                    self.profileImageView.image = pickedImage
                    let message = "Added successfully!!";
                    Toast(text: message, duration: Delay.short).show()
                    break

                case .failure(let error):
                    self.loaderEnd()
                    print("Error: ", error)
                }
            }
            //===============upload photo to the server code ends===========
        }
       
    }
    
    //=======================camera code ends=================
    //==================session function code starts==============
    
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
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
  
}
