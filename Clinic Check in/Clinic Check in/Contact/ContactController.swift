//
//  ContactController.swift
//  Clinic Check in
//
//  Created by MK on 09/05/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import MRCountryPicker
import Toaster

class ContactController: UIViewController,UITableViewDataSource, UITableViewDelegate, MRCountryPickerDelegate, UITextFieldDelegate, ContactTableViewCellDelegate {
   
    
    
    
    @IBOutlet weak var tableview: UITableView!
    
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var deviceID = UIDevice.current.identifierForVendor!.uuidString
    public var sharedpreferences = UserDefaults.standard
    public var isLogin: Bool!
    public var userID: Int!
    public var uuid: String!
    public var fullName: String!
    
    @IBOutlet weak var NaveHeaderView: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.delegate=self
        self.tableview.dataSource=self
        
        isLogin = self.sharedpreferences.bool(forKey: "isLogin")
        userID = self.sharedpreferences.integer(forKey: "userID")
        uuid = self.sharedpreferences.string(forKey: "uuid")
        fullName = self.sharedpreferences.string(forKey: "fullName")
        UserSingletonModel.sharedInstance.fullname = fullName!
        UserSingletonModel.sharedInstance.userid = userID!
        UserSingletonModel.sharedInstance.uuid = uuid!
        // Do any additional setup after loading the view.
        
        InitializationNavItem();
        makeDesignAddButton();
        addGestureSwipe();
        get_Contact_details();
        designformEditPopup();
        designSelectCountry();
        
    }
    func addGestureSwipe(){
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapNextPage))
        recognizer.direction = .left
        self.view.addGestureRecognizer(recognizer)
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
    // ============== Create Navigation item START ================= \\
    func InitializationNavItem() {
        NaveHeaderView.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(tapNextPage))
        
        loginNameLabel.text = fullName!
//        footerView.layer.zPosition = 2
        self.shadow(element: footerView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        
        self.shadow(element: logoutBtnView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        logoutBtnView.layer.cornerRadius = 10
    }
    @objc func tapNextPage() {
        print("Go next page")
        let api = mainUrl + "getEmergencyContacts/" + "\(self.uuid!)"
        Alamofire.request( api ).responseJSON{ (responseData) -> Void in
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                print(swiftyJsonVar)
                if swiftyJsonVar.count == 0 {
                    self.performSegue(withIdentifier: "allergic", sender: self)
                } else {
                    self.performSegue(withIdentifier: "visit", sender: self)
                }
                
            } else {
                let btnSessionEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
                self.showPopupDialog(title: "Network Error !!!", message: "Some errror occured. Please contact us...", Buttons: [btnSessionEnd], Alignment: .horizontal)
            }
            
        }
        
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
    
    // ==================== ADD Button START ========================= \\
    
    @IBOutlet weak var addButtonView: UIButton!
    func makeDesignAddButton() {
        addButtonView.backgroundColor = UIColor.white
        self.shadow(element: addButtonView, radius: 1, opacity: 4, offset: CGSize(width: 0, height: -2), shadowColor: UIColor.black.cgColor)
        addButtonView.layer.borderWidth = 0.5
        addButtonView.layer.borderColor = UIColor.gray.cgColor
        addButtonView.layer.cornerRadius = 0.5 * addButtonView.bounds.size.width
        
    }
    
    //--button function to add data to the server-----
    var funAction:String!
    @IBAction func addButtonAction(_ sender: Any) {
        funAction = "Add"
        submitAddFormData();
        
    }
    
    // ==================== ADD Button END ========================= \\
    // ==================== Display server data START ====================== \\
    var streetAddressType: Array<Any>!
    var emergencyContact: Array<Any>!
    var phoneType: Array<Any>!
    var emailType: Array<Any>!
    
    func displayData(prData: NSArray){
        for item in prData {
            let data = JSON(item)
            
            let myLabel = UILabel()
            myLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 10)
            myLabel.center = CGPoint(x: 0, y: 0)
            myLabel.textAlignment = .center
            myLabel.text = "NAME: " + data["emailAddress"].string!
            self.view.addSubview(myLabel)
            
            print(data["emailAddress"])
        }
    }
    // ==================== Display server data END ========================= \\
    
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
    
    //-----------function to get contact details from api using Alamofire and Jsonswifty---------------
    
    @IBOutlet weak var tableView: UITableView!
    func get_Contact_details(){
        
        loaderStart()
        tableView.layer.zPosition = -1
        
        let api = mainUrl + "getEmergencyContacts/" + "\(self.uuid!)"
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["emergencyContact"].arrayObject{
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count>0 {
                    self.tableview.backgroundView?.isHidden = true
                    self.tableview.reloadData()
                }else{
                    self.tableview.reloadData()
                    //                    Toast(text: "No data", duration: Delay.short).show()
                    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableview.bounds.size.width, height: self.tableview.bounds.size.height))
                    noDataLabel.text          = "No data available"
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    self.tableview.backgroundView  = noDataLabel
                    self.tableview.separatorStyle  = .none
                    
                }
            }
            
        }
    }
    //-----------function to get contact details from api using Alamofire and Jsonswifty code ends---------------
    
    
    //---------tableview code starts here---------------
    var arrRes = [[String:AnyObject]]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        
        var dict = arrRes[indexPath.row]
        
        cell.DisplayName.text = dict["name"] as? String
        let dialCode = dict["dialCode"] as? String
        let phoneNumber = dict["phoneNumber"] as? String
        cell.DisplayPhoneNo.text = "\(dialCode ?? "") \(phoneNumber ?? "")"
        cell.DisplayEmail.text = dict["emailAddress"] as? String
        
        var address = "";
        if((dict["addressLine1"] as? String) != ""){
            address += dict["addressLine1"] as? String ?? ""
        }
        if((dict["addressLine2"] as? String) != ""){
            if(address != "") {
                address += ", "
            }
            address += dict["addressLine2"] as? String ?? ""
        }
        if((dict["city"] as? String) != ""){
            if(address != "") {
                address += ", "
            }
            address += dict["city"] as? String ?? ""
        }
        
        if((dict["state"] as? String) != ""){
            if(address != "") {
                address += ", "
            }
            address += dict["state"] as? String ?? ""
        }
        
        if((dict["country"] as? String) != ""){
            if(address != "") {
                address += ", "
            }
            address += dict["country"] as? String ?? ""
        }
        
        if((dict["zipCode"] as? String) != ""){
            if(address != "") {
                address += ", "
            }
            address += dict["zipCode"] as? String ?? ""
        }
        
        cell.DisplayAddress.text = address
        cell.delegate = self
        return cell
    }
    
    private var aid: Int!
    private var selectTableID: Int!
    var selectTableRowIndexId: Int!
    private var selectTableRowData = [String:AnyObject]()
    
    func editTableRow(id: Int) {
        let api = mainUrl + "editEmergencyContactsForNative/" + "\(id)" //editEmergencyContactsForNative
        print(api)
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            if((responseData.result.value) != nil){
                if let arEmergencyContact = responseData.result.value as? [String : Any] {
                    for (key, value) in arEmergencyContact {
                        self.selectTableRowData[key] = JSON(value) as AnyObject
                    }
                }
                
                let emergencyContact = self.selectTableRowData["emergencyContact"] as AnyObject
                let arEmergencyContact = JSON(emergencyContact)
                
                self.aid = arEmergencyContact["aid"].intValue
                self.selectTableID = arEmergencyContact["id"].intValue
                
                if arEmergencyContact["dialCode"].stringValue != "" && arEmergencyContact["dialCode"].stringValue != nil {
                    self.selectedPhoneCode = arEmergencyContact["dialCode"].stringValue
                } else {
                    self.selectedPhoneCode =  "+1"
                }
                
                self.showDailCode.text = self.selectedPhoneCode
                self.nameInput.text = arEmergencyContact["name"].stringValue
                self.phoneInput.text = arEmergencyContact["phoneNumber"].stringValue
                self.emailInput.text = arEmergencyContact["emailAddress"].stringValue
                self.addressLine1.text = arEmergencyContact["addressLine1"].stringValue
                self.addressLine2.text = arEmergencyContact["addressLine2"].stringValue
                self.cityInput.text = arEmergencyContact["city"].stringValue
                self.stateInput.text = arEmergencyContact["state"].stringValue
                self.countryInput.text = arEmergencyContact["country"].stringValue
                self.zipCodeInput.text = arEmergencyContact["zipCode"].stringValue
                
                self.openFormPopup()
            }
            
        }
    }
    func deleteTableRow(contactID: Int) {
        let sendData: [String:Any] = [
            "prTableRowId": contactID,
            "uid": self.userID
        ]
        
        let api = mainUrl + "removeContactForNativeAppById/\(sendData["prTableRowId"] as! Int)"
        Alamofire.request(api, method: .post, parameters: sendData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                if self.funAction != "Add" {
                    Toast(text: "Deleted Successfully!!", duration: Delay.short).show()
                }
                let swiftyJsonVar=JSON(response.result.value!)

                self.get_Contact_details()

                break

            case .failure(let error):
                print("ERROR: ", error)
            }
        }
    }
    
    // The cell calls this method when the user taps the heart button
    func contactTableViewCellDidTapEdit(_ sender: ContactTableViewCell) {
        
        funAction = "Edit"
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        editTableRow(id: rowDara["id"] as! Int)
    }
    
    func contactTableViewCellDidTapDelete(_ sender: ContactTableViewCell) {
        
        funAction = "Delete"
       /*   guard let tappedIndexPath1 = tableView.indexPath(for: sender) else { return }*/
        guard let index = tableView.indexPath(for: sender) else { return }
        
        let btnCancelEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnConfirmEnd = DefaultButton(title: "OK", height: 50, dismissOnTap: true) {
            let rowData = self.arrRes[index.row]
            self.deleteTableRow(contactID: rowData["id"] as! Int)
        }
        self.showPopupDialog(title: "Confirm Delete", message: "Are you sure, you want to delete?", Buttons: [btnCancelEnd, btnConfirmEnd], Alignment: .horizontal)
        
    }

    //--------------tableview code ends--------------------
    
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
    
    //================== Contact Form popup START =============== \\
    @IBOutlet var cotactFormView: UIView!
    @IBOutlet weak var formViewPopupCancelBtnView: UIButton!
    @IBOutlet weak var formViewPopupSubmitBtnView: UIButton!
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var phoneInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var addressLine1: UITextField!
    @IBOutlet weak var addressLine2: UITextField!
    @IBOutlet weak var cityInput: UITextField!
    @IBOutlet weak var stateInput: UITextField!
    @IBOutlet weak var countryInput: UITextField!
    @IBOutlet weak var zipCodeInput: UITextField!
    
    @IBAction func formEditCancel(_ sender: Any) {
        if funAction == "Add" {
            print("deleteTableRow from add")
            if newContactTableID != nil {
                print("deleteTableRow codition true from add")
                deleteTableRow(contactID: newContactTableID)
            }
        }
        cancelEditFormPopup()
    }
    @IBAction func formEditSubmit(_ sender: Any) {
        if self.phoneInput.text!.count<10{
            Toast(text: "Your phone number must be at least 10 digits", duration: Delay.short).show()
        }else{
        submitEditFormData()
        }
    }
    var newContactTableID: Int!
    func submitAddFormData(){
        let api = mainUrl + "createContactsTableNative"
        
        // ================================================ TEST ==================================
        
        var arrRes1=[[String:AnyObject]]()
        
        //-------code for dateformatting-------
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        //-------code for dateformatting code ends-------
        
        //---code to get current timezone code starts-----
        let zoneName = NSTimeZone.abbreviationDictionary
        // Iterate through the dictionary
        let currentAutoUpdateTZ = TimeZone.current.identifier
        var finalTimeZoneName:String!
        for (key,value) in zoneName {
            if(value == currentAutoUpdateTZ){
                finalTimeZoneName = key
            }
        }
        //---code to get current timezone code ends-----
        
        
        //--------latest parameters(after api changing)------
        let apiparameters: [String:Any]=[
            "addressLine1": "",
            "addressLine2": "",
            "aid": "",
            "city": "",
            "country": "",
            "element": "address",
            "state": "",
            "typeId": "1",
            "typeName": "",
            "uid": self.userID!,
            "id": "",
            "uniqueRowId": 0,
            "zipCode": "",
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": finalTimeZoneName,
            "createdByUserId": self.userID!,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "zipCode",
            "addressList": [],
            "cid": "",
            "emailList": [],
            "isItLocked": "no",
            "name": "",
            "phoneList": [],
            "type": "",
            "indexTypeId": "",
        ]
        Alamofire.request(api, method: .post, parameters: apiparameters, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                let swiftyJsonVar=JSON(response.result.value!)
                print("swiftyJsonVar ", swiftyJsonVar)
                let id = swiftyJsonVar["emergencyContact"]["id"].intValue
                self.newContactTableID = id;
                print("getting id: ", id)
                self.editTableRow(id: id);
                break
                
            case .failure(let error):
                print(error)
            }
        }
        
        // ================================ END ==============================================
        
    }
    func submitEditFormData(){
        print("Sub mit")
        formViewPopupSubmitBtnView.isEnabled = false
        let api = mainUrl + "contactsUpdateForNativeApp/" + "\(self.selectTableID!)"
        
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
        
        let emergencyContact = self.selectTableRowData["emergencyContact"] as AnyObject
        let arEmergencyContact = JSON(emergencyContact)
        
        let updateAddressData: [String: Any] = [
            "element": "address",
            "typeId": "1",
            "typeName": "",
            "uid": self.userID!,
            "createdByUserId": self.userID!,
            "id": self.selectTableID!,
            "aid": self.aid!,
            "uniqueRowId": 0,
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "zipCode",
            
            "addressLine1": self.addressLine1.text!,
            "addressLine2": self.addressLine2.text!,
            "city": self.cityInput.text!,
            "state": self.stateInput.text!,
            "country": self.countryInput.text!,
            "zipCode": self.zipCodeInput.text!
        ]
        
        Alamofire.request(api, method: .post, parameters: updateAddressData, encoding: JSONEncoding.default, headers: nil).responseJSON{ (responseData) -> Void in }
        
        let phoneData: [String: Any] = [
            "element": "phone",
            "typeId": arEmergencyContact["phoneNumberTypeID"].intValue,
            "typeName": arEmergencyContact["phone_type"].stringValue,
            "uid": self.userID!,
            "createdByUserId": self.userID!,
            "id": self.selectTableID!,
            "pid": arEmergencyContact["contactPhoneNumbersTableId"].stringValue,
            "uniqueRowId": 0,
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "Phone number",
            
            "dialCode": self.showDailCode.text!,
            "phone": self.phoneInput.text!
        ]
        
        Alamofire.request(api, method: .post, parameters: phoneData).responseJSON{ (responseData) -> Void in }
        
        let sendContactData: [String: Any] = [
            "element": "contacts",
            "typeId": "1",
            "typeName": "",
            "type": "",
            "uid": self.userID!,
            "createdByUserId": self.userID!,
            "id": self.selectTableID!,
            "cid": self.selectTableID!,
            "uniqueRowId": 0,
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "Phone number",
            
            "phoneList": [],
            "emailList": [],
            "isItLocked": "no",
            "name": self.nameInput.text!
        ]
        
        Alamofire.request(api, method: .post, parameters: sendContactData).responseJSON{ (responseData) -> Void in }
        
        let sendEmailData: [String: Any] = [
            "element": "emails",
            "typeId": arEmergencyContact["emailAddressTypeID"].intValue,
            "typeName": arEmergencyContact["email_type"].intValue,
            "uid": self.userID!,
            "createdByUserId": self.userID!,
            "id": self.selectTableID!,
            "eid": arEmergencyContact["contactEmailAddressTableId"].stringValue,
            "uniqueRowId": 0,
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "Phone number",
            
            "email": self.emailInput.text!
        ]
        Alamofire.request(api, method: .post, parameters: sendEmailData).responseJSON{ (responseData) -> Void in
            print("success 1t")
            self.formViewPopupSubmitBtnView.isEnabled = true
            if((responseData.result.value) != nil){
                let returnData = JSON(responseData.result.value!)
                print(responseData.result.value!)
                Toast(text: "Submitted Successfully!!", duration: Delay.short).show()
                self.cancelEditFormPopup()
                self.get_Contact_details()
            }
        }
    }
    
    
    func designformEditPopup() {
        self.shadow(element: formViewPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    func openFormPopup() {
        blurEffect()
        self.formViewPopupSubmitBtnView.isEnabled = true
        self.view.addSubview(cotactFormView);
        
        let screenSize = UIScreen.main.bounds;
        let screenWidth = screenSize.width;
//        let screenHeight = screenSize.height;
        
        cotactFormView.frame.size = CGSize.init(width: screenWidth, height: cotactFormView.frame.height);
        cotactFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        cotactFormView.center = self.view.center;
        cotactFormView.alpha = 0
        cotactFormView.sizeToFit()
        
        UIView.animate(withDuration: 0.3) {
            self.cotactFormView.alpha = 1
            self.cotactFormView.transform = CGAffineTransform.identity
        }
        self.shadow(element: cotactFormView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
    }
    func cancelEditFormPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.cotactFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.cotactFormView.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.cotactFormView.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    
    //================== SElect Country popup Start =============== \\
    @IBOutlet var countryPopup: UIView!
    @IBOutlet weak var countryPopupHeader: UILabel!
    //@IBOutlet weak var showCountryFlag: UIImageView!
    @IBOutlet weak var showDailCode: UILabel!
    @IBOutlet weak var cuntryPickerPopup: MRCountryPicker!
    
    @IBOutlet weak var countryPopupCancelBtn: UIButton!
    @IBOutlet weak var countryPopupOkBtn: UIButton!
    
    
    var selectedPhoneCode: String! = "+1"
    var selectedCountryCode: String!
    var selectedCountryName: String!
    var selectedCountryFlag: UIImage!
    
    @IBAction func cuntryPickerCacleBtn(_ sender: Any) {
        closeCountryPopup()
    }
    @IBAction func selectCountry(_ sender: Any) {
        setCountryCode = selectedCountryCode
        //self.showCountryFlag.image = selectedCountryFlag
        self.showDailCode.text = selectedPhoneCode
        closeCountryPopup()
    }
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        selectedPhoneCode = phoneCode
        selectedCountryName = name
        selectedCountryCode = countryCode
        selectedCountryFlag = flag
    }
    
    var setCountryCode = "US"
    func designSelectCountry() {
        self.phoneInput.delegate = self
//        self.showSelectedCountryName.text = "United States"
        self.showDailCode.text = selectedPhoneCode
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectCountryPopup(_:)))
        showDailCode.addGestureRecognizer(tap2)
        showDailCode.isUserInteractionEnabled = true
        
        //-----------latest countrycode picker using MRCountryPicker library code----------
        cuntryPickerPopup.countryPickerDelegate = self
        cuntryPickerPopup.showPhoneNumbers = true
        //countryPicker.setCountry("SI")
        cuntryPickerPopup.setCountry(setCountryCode)
        
        //countryPicker.setLocale("sl_SI")
        cuntryPickerPopup.setLocale("India")
        //  countryPicker.setCountryByName("Canada")
        //        cuntryPickerScrol.setCountryByName("United States")
        //-----------latest countrycode picker using MRCountryPicker library code ends----------
        
        self.shadow(element: countryPopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: countryPopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    var countryBlurEffectView: UIVisualEffectView!
    @objc func openSelectCountryPopup(_ sender: UITapGestureRecognizer) {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        countryBlurEffectView = UIVisualEffectView(effect: blurEffect)
        countryBlurEffectView.frame = view.bounds
        countryBlurEffectView.alpha = 0.9
        view.addSubview(countryBlurEffectView)
        // screen roted and size resize automatic
        countryBlurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
        self.view.addSubview(countryPopup);
        countryPopup.center = self.view.center;
        countryPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        countryPopup.alpha = 054444
        
        UIView.animate(withDuration: 0.4) {
            self.countryPopup.alpha = 1
            self.countryPopup.transform = CGAffineTransform.identity
        }
        self.shadow(element: countryPopup, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
        
        countryPopupHeader.layer.borderWidth = 1
        countryPopupHeader.layer.borderColor = UIColor.gray.cgColor
        //        self.shadow(element: countryPopupHeader, radius: 1, opacity: 3, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.black.cgColor)
        
    }
    func closeCountryPopup() {
        cuntryPickerPopup.setCountry(setCountryCode)
        UIView.animate(withDuration: 0.3, animations: {
            self.countryPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.countryPopup.alpha = 0
            self.countryBlurEffectView.alpha = 0.3
        }) { (success) in
            self.countryPopup.removeFromSuperview();
            self.countryBlurEffectView.removeFromSuperview();
        }
    }
    
    
    //================== Contact Form popup END =============== \\
    
    //================== Contact Form popup END =============== \\
    
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    
}

