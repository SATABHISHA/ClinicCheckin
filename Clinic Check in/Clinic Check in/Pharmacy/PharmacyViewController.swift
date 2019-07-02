//
//  PharmacyViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 04/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class PharmacyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PharmacyTableViewCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
   
    @IBOutlet weak var tableview: UITableView!
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/"
    public var sharedpreferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        makeDesignAddButton()
        InitializationNavItem()
        loadDataFromServer()
        addGestureSwipe()
        designformEditPopup()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //------------function to get pharmacy list details--------
    var arrRes = [[String:AnyObject]]()
    func loadDataFromServer() {
        loaderStart()
        let api = mainUrl + "showpharmacyForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"

        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                print("load data: ",swiftyJsonVar)
                if let resData = swiftyJsonVar["data"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count > 0 {
                    self.tableview.backgroundView?.isHidden = true
                    self.tableview.reloadData()
                } else {
                    self.tableview.reloadData()
                    Toast(text: "No data", duration: Delay.short).show()
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
    //----------function to get pharmacy list details code ends----------
    
    //==============tableview code starts=====================
     private var selectTableRowData = [String:AnyObject]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PharmacyTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]

        let arData = JSON(dict)
        cell.inputTablecell1.text = arData["pharmacyName"].stringValue
        cell.inputTablecell2.text = arData["pharmacyStreetAddressLine1"].stringValue
        cell.inputTablecell3.text = arData["pharmacyStreetAddressLine2"].stringValue
        cell.inputTablecell4.text = arData["pharmacyCity"].stringValue
        cell.inputTablecell5.text = arData["pharmacyState"].stringValue
        cell.inputTablecell6.text = arData["pharmacyNotes"].stringValue
        
        return cell
    }
    
    func pharmacyTableViewCellDidTapEdit(_ sender: PharmacyTableViewCell) {
        funAction = "Edit"
        print("Edit is working")
        selectTableRowData = [String:AnyObject]()

        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]

        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        let getJsonData = JSON(selectTableRowData)

        inputName.text = getJsonData["pharmacyName"].stringValue
        inputAddressLine1.text = getJsonData["pharmacyStreetAddressLine1"].stringValue
        inputAddressLine2.text = getJsonData["pharmacyStreetAddressLine2"].stringValue
        inputCity.text = getJsonData["pharmacyCity"].stringValue
        inputState.text = getJsonData["pharmacyState"].stringValue
        inputNotes.text = getJsonData["pharmacyNotes"].stringValue
        openEditFormPopup()
    }
    
    func pharmacyTableViewCellDidTapDelete(_ sender: PharmacyTableViewCell) {
         funAction = "Delete"
        print("Delete is working")
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        let btnCancelEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnConfirmEnd = DefaultButton(title: "OK", height: 50, dismissOnTap: true) {
            self.deleteTableRow(index: tappedIndexPath.row)
        }
        self.showPopupDialog(title: "Confirm Delete", message: "Are you sure, you want to delete?", Buttons: [btnCancelEnd, btnConfirmEnd], Alignment: .horizontal)
    }
    func deleteTableRow(index: Int){
        
        loaderStart()
        let rowDara = arrRes[index]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
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
        
        let arPharmacyData = JSON(selectTableRowData)
        let apiParameters: [String:Any] = [
            "created_at": arPharmacyData["created_at"].stringValue,
            "id": arPharmacyData["id"].intValue,
            "orders": arPharmacyData["orders"].stringValue,
            "pharmacyCity": arPharmacyData["pharmacyCity"].stringValue,
            "userId": UserSingletonModel.sharedInstance.userid!,
            "currentDateTimeOfClient": "",
            "clientTimeOfActivity": dateInFormat,
            "clientDateTimeZone": localTimeZone,
            "createdByUserId": UserSingletonModel.sharedInstance.userid!,
            "activityDoneByUserId": UserSingletonModel.sharedInstance.userid!,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "pharmacy"
        ]
        let api = mainUrl + "destroypharmacyForNativeApp"
        
        print("Delete test: ",api,apiParameters)
        Alamofire.request(api, method: .post, parameters: apiParameters, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                print("swiftyJsonVar ", swiftyJsonVar)
                Toast(text: "Deleted Successfully!!", duration: Delay.short).show()
                self.loadDataFromServer()
                break
                
            case .failure(let error):
                self.loaderEnd()
                print(error)
            }
        }
    }
    //===============tableview code ends===================
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
        print("Go next page")
        self.performSegue(withIdentifier: "profile", sender: self)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "goal", sender: self)
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
        print("Add data")
        
        inputName.text = ""
        inputAddressLine1.text = ""
        inputAddressLine2.text = ""
        inputCity.text = ""
        inputState.text = ""
        inputNotes.text = ""
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
    
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputAddressLine1: UITextField!
    @IBOutlet weak var inputAddressLine2: UITextField!
    @IBOutlet weak var inputState: UITextField!
    @IBOutlet weak var inputCity: UITextField!
    @IBOutlet weak var inputNotes: UITextField!
    
    @IBAction func formEditCancel(_ sender: Any) {
        cancelEditFormPopup();
    }
    @IBAction func formEditSubmit(_ sender: Any) {
        updatePharmacy()
    }
    func designformEditPopup() {
        self.shadow(element: formViewPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    func openEditFormPopup() {
        blurEffect()
        self.formViewPopupSubmitBtnView.isEnabled = true
        pickerViewOfState.isHidden = true
        pickerViewOfCity.isHidden = true
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
    //============================ City and State Drop drown View Start =========================== \\
    
    @IBOutlet weak var pickerViewOfState: UIPickerView!
    @IBOutlet weak var pickerViewOfCity: UIPickerView!

    var filterdTerms = [String]()
    func filterContentForSearchText(searchText: String) {
        if dropDownType == "city" {
            filterdTerms = arMasterListOfCity.filter { termValue in
                return termValue.lowercased().contains(searchText.lowercased())
            }
        } else if dropDownType == "state" {
            filterdTerms = arMasterListOfState.filter { termValue in
                return termValue.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var dropDownType: String = ""
    
    var dropDownTypeFirstCharacterOfState: String = ""
    @IBAction func inputValueChangedForState(_ sender: Any) {
        dropDownType = "state"
        let getString = inputState.text!
        var firstCharacter = ""
        if let fstr = getString.first {
            firstCharacter = String(fstr)
        }
        if firstCharacter != "" && firstCharacter != dropDownTypeFirstCharacterOfState {
            dropDownTypeFirstCharacterOfState = firstCharacter
            
            let api = mainUrl + "getStateValueForNativeApp/" + "\(firstCharacter)"
            print("api: ",api)
            Alamofire.request(api).responseJSON{ (responseData) -> Void in
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
                        let name = data["stateName"].stringValue
                        self.arMasterListOfState.append(name)
//                        self.getDetailFromMasterListOfState[name] = data["id"].intValue
                    }
                    self.pickerViewOpen(string: getString)
                }
            }
            
        } else {
            pickerViewOpen(string: getString)
        }
        
    }
    var dropDownTypeFirstCharacterOfCity: String = ""
    @IBAction func inputValueChangeActionForCity(_ sender: Any) {
        dropDownType = "city"
        let getString = inputCity.text!
        var firstCharacter = ""
        if let fstr = getString.first {
            firstCharacter = String(fstr)
        }
        if firstCharacter != "" && firstCharacter != dropDownTypeFirstCharacterOfState {
            dropDownTypeFirstCharacterOfState = firstCharacter
            var api = ""
            if inputState.text! != "" {
                let sentData: [String: Any] = [
                    "city": getString,
                    "state": inputState.text!
                ]
                api = mainUrl + "getCityStateValueForNativeApp/" + "\(getString)"
                Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                    response in
                    switch response.result{
                    case .success:
                        if((response.result.value) != nil){
                            var getAllData = [String:AnyObject]()
                            if let returnData = response.result.value as? [String : Any] {
                                for (key, value) in returnData {
                                    getAllData[key] = JSON(value) as AnyObject
                                }
                            }
                            let jsonData = JSON(getAllData["data"] as Any)
                            
                            for (key, value) in jsonData {
                                let data = JSON(value)
                                let name = data["stateName"].stringValue
                                self.arMasterListOfCity.append(name)
                            }
                            self.pickerViewOpen(string: getString)
                        }
                        break
                        
                    case .failure(let error):
                        self.loaderEnd()
                        print("Error: ", error)
                    }
                }
            } else {
                api = mainUrl + "getCityValueForNativeApp/" + "\(firstCharacter)"
                Alamofire.request(api).responseJSON{ (responseData) -> Void in
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
                            let name = data["stateName"].stringValue
                            self.arMasterListOfCity.append(name)
                        }
                        self.pickerViewOpen(string: getString)
                    }
                }
            }
            
        } else {
            pickerViewOpen(string: getString)
        }
    }
    func distinct(source: [String]) -> [String] {
        var unique = [String]()
        for item in source {
            if !unique.contains(item)  {
                unique.append(item)
            }
        }
        return unique
    }
    func pickerViewOpen(string: String) {
        filterContentForSearchText(searchText: string)
        displayDropDownData = distinct(source: filterdTerms)
        print("displayDropDownData: ",displayDropDownData,dropDownType)
        if dropDownType == "city" {
            if displayDropDownData.count == 0 {
                pickerViewOfCity.isHidden = true
            } else {
                pickerViewOfCity.isHidden = false
            }
            
            pickerViewOfCity.reloadAllComponents()
            
            pickerViewOfCity.backgroundColor = UIColor.lightGray
            pickerViewOfCity.subviews[1].backgroundColor = UIColor.green
            pickerViewOfCity.subviews[2].backgroundColor = UIColor.green
        } else if dropDownType == "state" {
            if displayDropDownData.count == 0 {
                pickerViewOfState.isHidden = true
            } else {
                pickerViewOfState.isHidden = false
            }
            
            pickerViewOfState.reloadAllComponents()
            
            pickerViewOfState.backgroundColor = UIColor.lightGray
            pickerViewOfState.subviews[1].backgroundColor = UIColor.green
            pickerViewOfState.subviews[2].backgroundColor = UIColor.green
        }
    }
    var arMasterListOfCity = [String]()
    var getDetailFromMasterListOfCity = [String: Int]()
    
    var arMasterListOfState = [String]()
    var getDetailFromMasterListOfState = [String: Int]()
    
    var displayDropDownData: Array<Any> = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayDropDownData.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = displayDropDownData[row]
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.green])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = UIColor.groupTableViewBackground
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dropDownType == "city" {
            inputCity.text = displayDropDownData[row] as! String
            pickerViewOfCity.isHidden = true
        } else if dropDownType == "state" {
            inputState.text = displayDropDownData[row] as! String
            pickerViewOfState.isHidden = true
        }
    }
    //============================ City and State Drop drown View End =========================== \\
    //================== Edit Popup END =============== \\
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
    //======================function to update/add pharmacy code starts here===============
    func updatePharmacy(){
        loaderStart()

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
//        //---code to get current timezone code ends-----
        let getJsonData = JSON(selectTableRowData)
        if funAction == "Edit" {
            let api = mainUrl + "updatepharmacyForNativeApp/"+"\(UserSingletonModel.sharedInstance.userid!)"
            
            let sentData: [String:Any] = [
                "created_at": dateInFormat,
                "id": getJsonData["id"].intValue,
                "originId": getJsonData["id"].intValue,
                "pharmacyId": getJsonData["id"].intValue,
                "orders": "",
                "pharmacyCity": inputCity.text!,
                "pharmacyName": inputName.text!,
                "pharmacyNotes": inputNotes.text!,
                "pharmacyPhone": "",
                "pharmacyState": inputState.text!,
                "pharmacyStreetAddressLine1": inputAddressLine1.text!,
                "pharmacyStreetAddressLine2": inputAddressLine2.text!,
                "pharmacyURL": "",
                "primaryOrSecondary": "",
                "userId": UserSingletonModel.sharedInstance.userid!,
                "currentDateTimeOfClient": dateInFormat,
                "currentDateTime": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "createdTimeZone": localTimeZone,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "nameOfClient": "My Portal",
                "fieldNameOfActivity": "pharmacy"
            ]
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{
                    
                case .success:
                    self.loaderEnd()
                    let swiftyJsonVar = JSON(response.result.value!)
                    var message = "Updated Successfully!!";
                    if swiftyJsonVar["status"].stringValue == "fail" {
                        message = swiftyJsonVar["message"].stringValue
                        
                        Toast(text: message, duration: Delay.short).show()
                        print("Return edit data: ", swiftyJsonVar)
                    } else {
                        Toast(text: message, duration: Delay.short).show()
                        self.cancelEditFormPopup()
                        self.loadDataFromServer()
                    }
                    break
                    
                case .failure(let error):
                    self.loaderEnd()
                    print("Error: ", error)
                }
            }
        } else if funAction == "Add" {
            let api = mainUrl + "savepharmacyForNativeApp/"+"\(UserSingletonModel.sharedInstance.userid!)"

            let sentData: [String:Any] = [
                "created_at": dateInFormat,
                "id": "",
                "originId": "",
                "pharmacyId": "",
                "orders": "",
                "pharmacyCity": inputCity.text!,
                "pharmacyName": inputName.text!,
                "pharmacyNotes": inputNotes.text!,
                "pharmacyPhone": "",
                "pharmacyState": inputState.text!,
                "pharmacyStreetAddressLine1": inputAddressLine1.text!,
                "pharmacyStreetAddressLine2": inputAddressLine2.text!,
                "pharmacyURL": "",
                "primaryOrSecondary": "",
                "userId": UserSingletonModel.sharedInstance.userid!,
                "currentDateTimeOfClient": dateInFormat,
                "currentDateTime": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "createdTimeZone": localTimeZone,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "nameOfClient": "My Portal",
                "fieldNameOfActivity": "pharmacy"
            ]
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{

                case .success:
                    self.loaderEnd()
                    let swiftyJsonVar = JSON(response.result.value!)
                    var message = "Added Successfully!!";
                    if swiftyJsonVar["status"].stringValue == "fail" {
                        message = swiftyJsonVar["message"].stringValue

                        Toast(text: message, duration: Delay.short).show()
                        print("Return edit data: ", swiftyJsonVar)
                    } else {
                        Toast(text: message, duration: Delay.short).show()
                        self.cancelEditFormPopup()
                        self.loadDataFromServer()
                    }
                    break

                case .failure(let error):
                    self.loaderEnd()
                    print("Error: ", error)
                }
            }
        }
    }
    //======================function to update/add pharmacy code ends===============
    //==================session function code starts==============
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
}
