//
//  UpdateYourMedicationsViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 14/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class UpdateYourMedicationsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UpdateYourMedicationsTableViewCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var deviceID = UIDevice.current.identifierForVendor!.uuidString
    public var sharedpreferences = UserDefaults.standard
    public var isLogin: Bool!
    public var userID: Int!
    public var uuid: String!
    public var fullName: String!
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        makeDesignAddButton();
        InitializationNavItem();
        loadDataFromServer()
        
        addGestureSwipe()
        designformEditPopup();
        designSelectDate()
        designformAddSideEffectsPopup()
        
       
        // Do any additional setup after loading the view.
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
    
    
    var medicationData = [[String:AnyObject]]()
    func loadDataFromServer(){
        loaderStart()
        var api = mainUrl + "showmedicationsForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["data"].arrayObject{
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count>0 {
                    self.tableview.backgroundView?.isHidden = true
                    self.tableview.reloadData()
                }else{
                    self.tableview.reloadData()
                    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableview.bounds.size.width, height: self.tableview.bounds.size.height))
                    noDataLabel.text          = "No data available"
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    self.tableview.backgroundView  = noDataLabel
                    self.tableview.separatorStyle  = .none
                    
                }
            }
            
        }
        api = mainUrl + "showmasterMedication"
        self.medicationNameInput.isEnabled = false
        self.medicationNameInput.placeholder = "Please wait while loading medicine names..."
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.medicationNameInput.isEnabled = true
            self.medicationNameInput.placeholder = "Enter medicine name"
            if((responseData.result.value) != nil){
                var getAllData = [String:AnyObject]()
                if let returnData = responseData.result.value as? [String : Any] {
                    for (key, value) in returnData {
                        getAllData[key] = JSON(value) as AnyObject
                    }
                }
                let jsonData = JSON(getAllData["data"] as Any)
                
                for (key, value) in jsonData {
                    let data = JSON(value)
                    self.arMedicationName.append(data["name"].stringValue)
                    self.arMedicationNameWithId[data["name"].stringValue] = data["id"].intValue
                }
            }
        }
        
    }
    
    //====================tableview code starts=================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    
    var arrRes = [[String:AnyObject]]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UpdateYourMedicationsTableViewCell
        
        let dict = arrRes[indexPath.row]

        let arData = JSON(dict)
        
        if arData["prescribedBy"].intValue == 0 {
            cell.addSideEffectsbtn.isHidden = true
            cell.editBtnView.isHidden = false
            cell.deleteBtnView.isHidden = false
        } else {
            cell.addSideEffectsbtn.isHidden = false
            cell.editBtnView.isHidden = true
            cell.deleteBtnView.isHidden = true
        }
        
        cell.displayMedicationName.text = arData["name"].stringValue + arData["refilstatus"].stringValue
        cell.displayDosageOfMedication.text = arData["frequency"].stringValue
        cell.displayStartDate.text = arData["startDate"].stringValue
        
        if arData["discontinuedOnDateTimeToShow"].stringValue == "" {
            cell.displayDiscontinuedDate.text = "Continue"
        } else {
            cell.displayDiscontinuedDate.text = arData["discontinuedOnDateTimeToShow"].stringValue
        }
        var effectOnPatientText = ""
        for (key, value) in arData["effectOnPatient"] {
            if Int(key) != 0 {
                effectOnPatientText += ", "
            }
            let arValue = JSON(value)
            effectOnPatientText += arValue["notes"].stringValue
        }
        cell.displaySideEffects.text = effectOnPatientText
        
        cell.delegate = self
        return cell
    }
    private var selectTableRowData = [String:AnyObject]()
    func updateYourMedicationsTableViewCellDidTapEdit(_ sender: UpdateYourMedicationsTableViewCell) {
        funAction = "Edit"
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        
        let jsonSelectedData = JSON(selectTableRowData)
        
        medicationNameInput.text = jsonSelectedData["name"].stringValue
        medicationDosageInput.text = jsonSelectedData["frequency"].stringValue
        startDate.text = jsonSelectedData["startDate"].stringValue
        discontinuedDate.text = jsonSelectedData["discontinuedOnDateTimeToShow"].stringValue
        txtAddSideEffectsInput.text = jsonSelectedData["effectOnPatient"][0]["notes"].stringValue
        openEditFormPopup()
    }
    //------function to delete table row code ends--------
    func updateYourMedicationsTableViewCellDidTapAddSideEffects(_ sender: UpdateYourMedicationsTableViewCell) {
        funAction = "SideEffects"
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        
        sideEffectsInput.text = ""
        
        openAddSideEffectsFormPopup()
    }
    
    func updateYourMedicationsTableViewCellDidTapDelete(_ sender: UpdateYourMedicationsTableViewCell) {
        funAction = "Delete"
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        
        let btnCancelEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnConfirmEnd = DefaultButton(title: "OK", height: 50, dismissOnTap: true) {
            self.deleteTableRow(index: tappedIndexPath.row)
        }
        self.showPopupDialog(title: "Confirm Delete", message: "Are you sure, you want to delete?", Buttons: [btnCancelEnd, btnConfirmEnd], Alignment: .horizontal)
        
    }
    
    //------function to delete table row--------
    func deleteTableRow(index: Int){
         loaderStart()
        let rowDara = arrRes[index]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        let jsonSelectedData = JSON(selectTableRowData)
        
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
        
        var arEffectOnPatientData = [[String:AnyObject]]()
        if let resData = jsonSelectedData["effectOnPatient"].arrayObject{
            arEffectOnPatientData = resData as! [[String:AnyObject]]
        }
        var medicineID = 0;
        if let getMedicineID = self.arMedicationNameWithId[jsonSelectedData["name"].stringValue] {
            medicineID = getMedicineID;
        }
        let sentData: [String: Any] = [
            "id": jsonSelectedData["id"].intValue,
            "doctor": UserSingletonModel.sharedInstance.userid,
            "isItLocked": "no",
            "isMainRow": 1,
            "isMinimized": 0,
            "medicineForm": "",
            "medicineID": medicineID,
            "name": jsonSelectedData["name"].stringValue,
            "uid": UserSingletonModel.sharedInstance.userid,
            "uniqueRowId": 0,
            "userSubMedicine": "",
            "effectOnPatient": arEffectOnPatientData,
            "frequency": jsonSelectedData["frequency"].stringValue,
            "startDate": jsonSelectedData["startDate"].stringValue,
            "discontinuedOnDateTime": jsonSelectedData["discontinuedOnDateTime"].stringValue,
            "discontinuedOnDateTimeToShow": jsonSelectedData["discontinuedOnDateTimeToShow"].stringValue,
            "createdByUserId": UserSingletonModel.sharedInstance.userid,
            "uidOnActivityDone": UserSingletonModel.sharedInstance.userid,
            "nameOfSectionOnActivityDone": "My Portal",
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "fieldname": "remove",
            "typeOfActivityLog": "remove"
        ]
        let api = mainUrl + "updatemedicationsForNativeApp/" + "\(jsonSelectedData["id"].intValue)"
        
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
                
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Deleted Successfully!!";
                if swiftyJsonVar["status"].stringValue == "success" {
                    let data = swiftyJsonVar["message"].stringValue
                    
                    Toast(text: message, duration: Delay.short).show()
                    self.loadDataFromServer()
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    
                    Toast(text: message, duration: Delay.short).show()
                    print("Return edit data: ", swiftyJsonVar)
                }
                break
                
            case .failure(let error):
                self.loaderEnd()
                print("Error: ", error)
            }
        }
        
    }
    
    //====================tableview code ends=================

    
    // ============== Create Navigation item START ================= \\
    
    @IBOutlet weak var NaveHeaderView: UINavigationItem!
    func InitializationNavItem() {
        NaveHeaderView.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(tapNextPage))
        
        loginNameLabel.text = UserSingletonModel.sharedInstance.fullname!
        //        footerView.layer.zPosition = 2
        self.shadow(element: footerView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        
        self.shadow(element: logoutBtnView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        logoutBtnView.layer.cornerRadius = 10
    }
    @objc func tapNextPage() {
        self.performSegue(withIdentifier: "lifeEvent", sender: self)
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "allergic", sender: self)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let strDate = dateFormatter.string(from: datePickerView.date)
        
        medicationNameInput.text = ""
        medicationDosageInput.text = ""
        startDate.text = strDate
        discontinuedDate.text = strDate
        txtAddSideEffectsInput.text = ""
        openEditFormPopup()
        
    }
    
    // ==================== ADD Button END ========================= \\
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
    
    
    
    //================== Edit Popup START =============== \\
    @IBOutlet var editFormView: UIView!
    @IBOutlet weak var formViewPopupCancelBtnView: UIButton!
    @IBOutlet weak var formViewPopupSubmitBtnView: UIButton!
    
    @IBOutlet weak var medicationNameInput: UITextField!
    @IBOutlet weak var medicationDosageInput: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var discontinuedDate: UITextField!
    
    @IBOutlet weak var txtAddSideEffectsInput: UITextView!
    
    
    @IBAction func formEditCancel(_ sender: Any) {
        cancelEditFormPopup();
    }
    @IBAction func formEditSubmit(_ sender: Any) {
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
        var medicineID = 0;
        if let getMedicineID = self.arMedicationNameWithId[self.medicationNameInput.text!] {
            medicineID = getMedicineID;
        }
        if funAction == "Add" {
            let api = mainUrl + "savemedicationsForNative"
            let sentData: [String:Any] = [
                "id": "",
                "doctor": UserSingletonModel.sharedInstance.userid!,
                "isItLocked": "no",
                "isMainRow": 1,
                "isMinimized": 0,
                "medicineForm": "",
                "medicineID": medicineID,
                "name": self.medicationNameInput.text!,
                "uid": UserSingletonModel.sharedInstance.userid!,
                "uniqueRowId": 0,
                "userSubMedicine": "",
                "effectOnPatient": [[
                    "id": "",
                    "notes": self.txtAddSideEffectsInput.text!
                ]],
                "frequency": self.medicationDosageInput.text!,
                "startDate": self.startDate.text!,
                "discontinuedOnDateTime":  self.discontinuedDate.text!,
                "discontinuedOnDateTimeToShow": dateInFormat,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "uidOnActivityDone": UserSingletonModel.sharedInstance.userid!,
                "nameOfSectionOnActivityDone": "My Portal",
                "currentDateTimeOfClient": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "fieldname": "effectOnPatient",
                "typeOfActivityLog": "edit"
            ]
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{
                case .success:
                    Toast(text: "Added Successfully!!", duration: Delay.short).show()
                    self.cancelEditFormPopup()
                    self.loadDataFromServer()
                    break

                case .failure(let error):
                    print("Error: ", error)
                }
            }
        } else if funAction == "Edit" {
            
            var jsonSelectedData = JSON(selectTableRowData)
            jsonSelectedData["effectOnPatient"][0]["notes"].stringValue = self.txtAddSideEffectsInput.text!
            var arEffectOnPatientData = [[String:AnyObject]]()
            if let resData = jsonSelectedData["effectOnPatient"].arrayObject{
                arEffectOnPatientData = resData as! [[String:AnyObject]]
            }
            let api = mainUrl + "updatemedicationsForNativeApp/" + "\(jsonSelectedData["id"].intValue)"
            let sentData: [String:Any] = [
                "id": jsonSelectedData["id"].intValue,
                "doctor": UserSingletonModel.sharedInstance.userid!,
                "isItLocked": "no",
                "isMainRow": 1,
                "isMinimized": 0,
                "medicineForm": "",
                "medicineID": medicineID,
                "name": self.medicationNameInput.text!,
                "uid": UserSingletonModel.sharedInstance.userid!,
                "uniqueRowId": 0,
                "userSubMedicine": "",
                "effectOnPatient": arEffectOnPatientData,
                "frequency": self.medicationDosageInput.text!,
                "startDate": self.startDate.text!,
                "discontinuedOnDateTime":  self.discontinuedDate.text!,
                "discontinuedOnDateTimeToShow": dateInFormat,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "uidOnActivityDone": UserSingletonModel.sharedInstance.userid!,
                "nameOfSectionOnActivityDone": "My Portal",
                "currentDateTimeOfClient": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "fieldname": "effectOnPatient",
                "typeOfActivityLog": "edit"
            ]
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{
                case .success:
                    let swiftyJsonVar = JSON(response.result.value!)
                    var message = "Submitted Successfully!!";
                    if swiftyJsonVar["status"].stringValue == "success" {
                        let data = swiftyJsonVar["message"].stringValue
                        if !data.isEmpty {
                            message = data
                        }
                        Toast(text: message, duration: Delay.short).show()
                        self.cancelEditFormPopup()
                        self.loadDataFromServer()
                    } else {
                        let message = swiftyJsonVar["message"].stringValue

                        Toast(text: message, duration: Delay.short).show()
                        print("Return edit data: ", swiftyJsonVar)
                    }
                    break

                case .failure(let error):
                    print("Error: ", error)
                }
            }
        }
        
    }
    
    @IBOutlet weak var medicationDropDown: UIPickerView!
    func designformEditPopup() {
        medicationDropDown.isHidden = true;
        
        self.shadow(element: formViewPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        
        medicationDropDown.delegate = self
    }
    //============================ Medication Drop drown View Start =========================== \\
    var filterdTerms = [String]()
    func filterContentForSearchText(searchText: String) {
        filterdTerms = arMedicationName.filter { termValue in
            return termValue.lowercased().contains(searchText.lowercased())
        }
        
    }
    
    // ======> Phone number field allow anly number
    
    @IBAction func typeInputFieldOnChangeActionForMedName(_ sender: Any) {
        
        let string = medicationNameInput.text!
        
        filterContentForSearchText(searchText: string)
        displayMedicationData = filterdTerms
        if displayMedicationData.count == 0 {
            medicationDropDown.isHidden = true
        } else {
            medicationDropDown.isHidden = false
        }
        medicationDropDown.reloadAllComponents()
        
        medicationDropDown.backgroundColor = UIColor.lightGray
        medicationDropDown.subviews[1].backgroundColor = UIColor.green
        medicationDropDown.subviews[2].backgroundColor = UIColor.green
    }
    var MedicationPickerData = [[String:AnyObject]]()
    var arMedicationName = [String]()
    var arMedicationNameWithId = [String: Int]()
    var displayMedicationData: Array<Any> = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayMedicationData.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = displayMedicationData[row]
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.green])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = UIColor.groupTableViewBackground
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        medicationNameInput.text = displayMedicationData[row] as! String
        medicationDropDown.isHidden = true
    }
    //============================ Medication Drop drown View End =========================== \\
    
    
    func openEditFormPopup() {
        blurEffect()
        medicationDropDown.isHidden = true
        
//        if displayMedicationData.count == 0 {
//            displayMedicationData = MedicationPickerData
//        }
        self.formViewPopupSubmitBtnView.isEnabled = true
        self.view.addSubview(editFormView);
        
        let screenSize = UIScreen.main.bounds;
        let screenWidth = screenSize.width;
        //        let screenHeight = screenSize.height;
        
        editFormView.frame.size = CGSize.init(width: screenWidth, height: editFormView.frame.height);
        editFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        editFormView.center = self.view.center;
        editFormView.alpha = 0
        editFormView.sizeToFit()
        
        UIView.animate(withDuration: 0.3) {
            self.editFormView.alpha = 1
            self.editFormView.transform = CGAffineTransform.identity
        }
        self.shadow(element: editFormView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
        
    }
    func cancelEditFormPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.editFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.editFormView.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.editFormView.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //================== Select date popup Start =============== \\
    @IBOutlet var datePopup: UIView!
    @IBOutlet weak var datePopupHeader: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    
    @IBOutlet weak var datePopupCancelBtn: UIButton!
    @IBOutlet weak var datePopupOkBtn: UIButton!
    
    
    
    
    @IBAction func datePickerCacleBtn(_ sender: Any) {
        closeDatePopup()
    }
    @IBAction func selectDateSubmitBtn(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let strDate = dateFormatter.string(from: datePickerView.date)
        if datePopupType == "startDate" {
            startDate.text = strDate
        } else {
            discontinuedDate.text = strDate
        }
        closeDatePopup()
    }
    
    
    func designSelectDate() {
        //        self.showSelectedDateName.text = "United States"
        startDate.isUserInteractionEnabled = false
        discontinuedDate.isUserInteractionEnabled = false
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectDatePopupForStartDate(_:)))
        startDate.addGestureRecognizer(tap2)
        startDate.isUserInteractionEnabled = true
        
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectDatePopupForDiscontinuedDate(_:)))
        discontinuedDate.addGestureRecognizer(tap3)
        discontinuedDate.isUserInteractionEnabled = true
        
        self.shadow(element: datePopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: datePopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    var dateBlurEffectView: UIVisualEffectView!
    var datePopupType: String!
    @objc func openSelectDatePopup(type: String!) {
        datePopupType = type
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        dateBlurEffectView = UIVisualEffectView(effect: blurEffect)
        dateBlurEffectView.frame = view.bounds
        dateBlurEffectView.alpha = 0.9
        view.addSubview(dateBlurEffectView)
        // screen roted and size resize automatic
        dateBlurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
        self.view.addSubview(datePopup);
        datePopup.center = self.view.center;
        
        
        
        datePopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        datePopup.alpha = 054444
        
        UIView.animate(withDuration: 0.4) {
            self.datePopup.alpha = 1
            self.datePopup.transform = CGAffineTransform.identity
        }
        self.shadow(element: datePopup, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
        
        datePopupHeader.layer.borderWidth = 1
        datePopupHeader.layer.borderColor = UIColor.gray.cgColor
        //        self.shadow(element: datePopupHeader, radius: 1, opacity: 3, offset: CGSize(width: 0, height: 1), shadowColor: UIColor.black.cgColor)
        
    }
    @objc func openSelectDatePopupForStartDate(_ sender: UITapGestureRecognizer) {
        openSelectDatePopup(type: "startDate")
    }
    @objc func openSelectDatePopupForDiscontinuedDate(_ sender: UITapGestureRecognizer) {
        openSelectDatePopup(type: "discontinuedDate")
    }
    func closeDatePopup() {
        //        cuntryPickerPopup.setDate(setDateCode)
        UIView.animate(withDuration: 0.3, animations: {
            self.datePopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.datePopup.alpha = 0
            self.dateBlurEffectView.alpha = 0.3
        }) { (success) in
            self.datePopup.removeFromSuperview();
            self.dateBlurEffectView.removeFromSuperview();
        }
    }
    
    
    //================== Select date popup END =============== \\
    //================== Edit Popup END =============== \\
    
    
    
    //===================Add Side Effects Popup code starts================
    
    @IBOutlet var addSideEffectsFormView: UIView!
    @IBOutlet weak var formViewAddSideEffectsPopupCancelBtnView: UIButton!
    @IBOutlet weak var formViewAddSideEffectsPopupSubmitBtnView: UIButton!
    
    @IBOutlet weak var sideEffectsInput: UITextView!
    
    
    @IBAction func formAddSideEffectsCancel(_ sender: Any) {
        cancelAddSideEffectsFormPopup()
    }
    
    @IBAction func formAddSideEffectsSubmit(_ sender: Any) {
        var jsonSelectedData = JSON(selectTableRowData)
        jsonSelectedData["effectOnPatient"][0]["id"].stringValue = ""
        jsonSelectedData["effectOnPatient"][0]["notes"].stringValue = self.sideEffectsInput.text!
        var arEffectOnPatientData = [[String:AnyObject]]()
        if let resData = jsonSelectedData["effectOnPatient"].arrayObject{
            arEffectOnPatientData = resData as! [[String:AnyObject]]
        }
        var medicineID = 0;
        if let getMedicineID = self.arMedicationNameWithId[jsonSelectedData["name"].stringValue] {
            medicineID = getMedicineID;
        }
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
        
        let api = mainUrl + "updatemedicationsForNativeApp/" + "\(jsonSelectedData["id"].intValue)"
        let sentData: [String:Any] = [
            "id": jsonSelectedData["id"].intValue,
            "doctor": UserSingletonModel.sharedInstance.userid!,
            "isItLocked": "no",
            "isMainRow": 1,
            "isMinimized": 0,
            "medicineForm": "",
            "medicineID": medicineID,
            "name": jsonSelectedData["name"].stringValue,
            "uid": UserSingletonModel.sharedInstance.userid!,
            "uniqueRowId": 0,
            "userSubMedicine": "",
            "effectOnPatient": arEffectOnPatientData,
            "frequency": jsonSelectedData["frequency"].stringValue,
            "startDate": jsonSelectedData["startDate"].stringValue,
            "discontinuedOnDateTime": jsonSelectedData["discontinuedOnDateTime"].stringValue,
            "discontinuedOnDateTimeToShow": dateInFormat,
            "createdByUserId": UserSingletonModel.sharedInstance.userid!,
            "uidOnActivityDone": UserSingletonModel.sharedInstance.userid!,
            "nameOfSectionOnActivityDone": "My Portal",
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "fieldname": "effectOnPatient",
            "typeOfActivityLog": "edit"
        ]
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Submitted Successfully!!";
                if swiftyJsonVar["status"].stringValue == "success" {
                    let data = swiftyJsonVar["message"].stringValue
                    if !data.isEmpty {
                        message = data
                    }
                    Toast(text: message, duration: Delay.short).show()
                    self.cancelAddSideEffectsFormPopup()
                    self.loadDataFromServer()
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    
                    Toast(text: message, duration: Delay.short).show()
                    print("Return edit data: ", swiftyJsonVar)
                }
                break
                
            case .failure(let error):
                print("Error: ", error)
            }
        }
    }
    func designformAddSideEffectsPopup() {
        self.shadow(element: formViewAddSideEffectsPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewAddSideEffectsPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    func openAddSideEffectsFormPopup(){
        blurEffect()
        self.formViewAddSideEffectsPopupSubmitBtnView.isEnabled = true
        self.view.addSubview(addSideEffectsFormView);
        
        let screenSize = UIScreen.main.bounds;
        let screenWidth = screenSize.width;
        //        let screenHeight = screenSize.height;
        
        addSideEffectsFormView.frame.size = CGSize.init(width: screenWidth, height: addSideEffectsFormView.frame.height);
        addSideEffectsFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addSideEffectsFormView.center = self.view.center;
        addSideEffectsFormView.alpha = 0
        addSideEffectsFormView.sizeToFit()
        
        UIView.animate(withDuration: 0.3) {
            self.addSideEffectsFormView.alpha = 1
            self.addSideEffectsFormView.transform = CGAffineTransform.identity
        }
        self.shadow(element: editFormView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
    }
    
    func cancelAddSideEffectsFormPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.addSideEffectsFormView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addSideEffectsFormView.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.addSideEffectsFormView.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    
    //===================Add Side Effects Popup code ends================
    
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
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
}



