//
//  FinanceDemoViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 25/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class FinanceHomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FinancialHomeTableViewCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/"
    public var sharedpreferences = UserDefaults.standard
    
    
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var labelPaymentDue: UILabel!
    @IBOutlet weak var labelInternalAc: UILabel!
    @IBOutlet weak var labelTransactionStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate=self
        self.tableview.dataSource=self
        
        InitializationNavItem()
        makeDesignAddButton()
        addGestureSwipe()
        loadDataFromServer()
        designformEditPopup()
        //        designSelectDate()
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
    //------------function to get major life event details--------
    var arrRes = [[String:AnyObject]]()
    func loadDataFromServer(){
        loaderStart()
        let api = mainUrl + "showPayerForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        print("api for payer",api)
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar = JSON(responseData.result.value!)
                self.labelInternalAc.text = swiftyJsonVar["internalAccountFunds"].stringValue
                self.labelPaymentDue.text = swiftyJsonVar["paymentDue"].stringValue
                self.labelTransactionStatus.text = "Your last transaction is \(swiftyJsonVar["lastTransaction"].stringValue)"
                if let resData = swiftyJsonVar["data"].arrayObject{
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count > 0 {
                    self.tableview.backgroundView?.isHidden = true
                    self.tableview.reloadData()
                } else {
                    self.tableview.reloadData()
                    //                    Toast(text: "No data", duration: Delay.short).show()
                    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableview.bounds.size.width, height: self.tableview.bounds.size.height))
                    noDataLabel.text          = "No data available"
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    self.tableview.backgroundView  = noDataLabel
                    self.tableview.separatorStyle  = .none
                    
                }
                //-------code for getting the insurance company names-----------
                var getAllData = [String:AnyObject]()
                if let returnData = responseData.result.value as? [String : Any] {
                    for (key, value) in returnData {
                        getAllData[key] = JSON(value) as AnyObject
                    }
                }
                let jsonData = JSON(getAllData["paymentInsuranceCompanyMaster"] as Any)
                
                for (key, value) in jsonData {
                    let data = JSON(value)
                    self.arInsuranceCompanyName.append(data["name"].stringValue)
                    self.arInsuranceCompanyNameWithId[data["name"].stringValue] = data["id"].intValue
                }
                print("Insurance company name:",self.arInsuranceCompanyName)
                //-------code for getting the insurance company names ends-----------
            }
            
        }
        
    }
    //----------function to get major life event details code ends----------
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    //--------------tableview code starts------------
    private var selectTableRowData = [String:AnyObject]()
    func financialHomeTableViewCellDidTapEdit(_ sender: FinancialHomeTableViewCell) {
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
        
        let jsonSelectedData = JSON(selectTableRowData)
        print("get table row data: ",selectTableRowData)
        inputBankAcntPatientName.text = jsonSelectedData["isThisAccountOwnedByPatient"].stringValue
        inputAcntHolderName.text = jsonSelectedData["accountHolderName"].stringValue
        inputAcntType.text = jsonSelectedData["type"].stringValue
        if jsonSelectedData["type"].stringValue == "Insurance"{
            
            
            labelCreditCardNo.isHidden = false
            inputCreditCardNo.isHidden = false
            labelCreditCardNo.text = "Insurance account no:"
            inputCreditCardNo.text = jsonSelectedData["forTypeBankOrCCOrInsuranceAccountNumber"].stringValue
            
            labelExpiryDate.isHidden = false
            inputExpiryDate.isHidden = false
            labelExpiryDate.text = "Select insurance company name:"
            inputExpiryDate.text = jsonSelectedData["payerNote"]["name"].stringValue
            cancelSelectDatePopup()
            
            labelCardIdNo.isHidden = true
            inputCardIdNo.isHidden = true
            
            labelZipCode.isHidden = true
            inputZipCode.isHidden = true
        } else if jsonSelectedData["type"].stringValue == "Bank account"{
            labelCreditCardNo.isHidden = false
            inputCreditCardNo.isHidden = false
            labelCreditCardNo.text = "A/c number:"
            inputCreditCardNo.text = jsonSelectedData["forTypeBankOrCCOrInsuranceAccountNumber"].stringValue
            
            labelExpiryDate.isHidden = false
            inputExpiryDate.isHidden = false
            labelExpiryDate.text = "Routing number:"
            inputExpiryDate.text = jsonSelectedData["forTypeBankRoutingNumber"].stringValue
            cancelSelectDatePopup()
            
            labelCardIdNo.isHidden = false
            inputCardIdNo.isHidden = false
            labelCardIdNo.text = "Bank name:"
            inputCardIdNo.text = jsonSelectedData["name"].stringValue
            
            
            labelZipCode.isHidden = true
            inputZipCode.isHidden = true
        } else if jsonSelectedData["type"].stringValue == "CC"{
            labelCreditCardNo.isHidden = false
            inputCreditCardNo.isHidden = false
            labelCreditCardNo.text = "Credit card number:"
            inputCreditCardNo.text = jsonSelectedData["displayCreditCardNumberFormat"].stringValue
            
            labelExpiryDate.isHidden = false
            inputExpiryDate.isHidden = false
            labelExpiryDate.text = "Expiry date (MM/YYYY):"
            inputExpiryDate.text = "\(jsonSelectedData["forTypeCCExpirationMonth"].intValue)/\(jsonSelectedData["forTypeCCExpirationYear"].intValue)"
            addSelectDatePopup()
            
            labelCardIdNo.isHidden = false
            inputCardIdNo.isHidden = false
            labelCardIdNo.text = "Card identification number:"
            inputCardIdNo.text = jsonSelectedData["name"].stringValue
            
            labelZipCode.isHidden = false
            inputZipCode.isHidden = false
            labelZipCode.text = "Billing zip code:"
            inputZipCode.text = jsonSelectedData["forTypeCCBillingZipCode"].stringValue
            inputZipCode.placeholder = "Enter Billing zip code"
        }
        openEditFormPopup()
    }
    
    func financialHomeTableViewCellDidTapDelete(_ sender: FinancialHomeTableViewCell) {
        funAction = "Delete"
        print("Delete is working")
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        
        let btnCancelEnd = CancelButton(title: "Cancel", height: 50, dismissOnTap: true) {}
        let btnConfirmEnd = DefaultButton(title: "OK", height: 50, dismissOnTap: true) {
            self.deleteTableRow(index: tappedIndexPath.row)
        }
        self.showPopupDialog(title: "Confirm Delete", message: "Are you sure, you want to delete?", Buttons: [btnCancelEnd, btnConfirmEnd], Alignment: .horizontal)
    }
    
    //====================function to delete table row================
    func deleteTableRow(index: Int){
        loaderStart()
        let rowDara = arrRes[index]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        let jsonSelectedData = JSON(selectTableRowData)
        
        let api = mainUrl + "destroyPayerForNativeApp/" + "\(jsonSelectedData["id"].intValue)"
        
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
        let sentData: [String: Any] = [
            "accountHolderName": jsonSelectedData["accountHolderName"].stringValue,
            "attachments": jsonSelectedData["attachments"].stringValue,
            "created_at": jsonSelectedData["created_at"].stringValue,
            "forTypeBankOrCCOrInsuranceAccountNumber": jsonSelectedData["forTypeBankOrCCOrInsuranceAccountNumber"].stringValue,
            "forTypeBankRoutingNumber": jsonSelectedData["forTypeBankRoutingNumber"].stringValue,  //self.inputExpiryDate.text!,
            "forTypeCCBillingZipCode": jsonSelectedData["forTypeCCBillingZipCode"].stringValue,
            "forTypeCCExpirationMonth": jsonSelectedData["forTypeCCExpirationMonth"].stringValue,  //self.inputExpiryDate.text!,
            "forTypeCCExpirationYear": jsonSelectedData["forTypeCCExpirationYear"].stringValue,  // self.inputExpiryDate.text!,
            "forTypeCCIsCVVValid": jsonSelectedData["forTypeCCIsCVVValid"].stringValue,
            "forTypeCCIsCardValid": jsonSelectedData["forTypeCCIsCardValid"].stringValue,
            "forTypeCCIsExpiryValid": jsonSelectedData["forTypeCCIsExpiryValid"].stringValue,
            "forTypeCCIsZipValid": jsonSelectedData["forTypeCCIsZipValid"].stringValue,
            "forTypeCCSecurityCode": jsonSelectedData["forTypeCCSecurityCode"].stringValue,
            "forTypeInsuranceUIDOfCompany": jsonSelectedData["forTypeInsuranceUIDOfCompany"].stringValue,//421,
            "id": jsonSelectedData["id"].intValue,
            "isItLocked": jsonSelectedData["isItLocked"].stringValue,
            "isPrimary": jsonSelectedData["isPrimary"].stringValue,
            "isThisAccountOwnedByPatient": jsonSelectedData["isThisAccountOwnedByPatient"].stringValue,//"Yes",
            "name": jsonSelectedData["name"].stringValue,
            "note": jsonSelectedData["note"].stringValue,
            "payerNote": jsonSelectedData["payerNote"].stringValue, //self.inputExpiryDate.text!,
            "priority": jsonSelectedData["priority"].stringValue,
            "relationWithPatient": jsonSelectedData["relationWithPatient"].stringValue,
            "timeZoneAbbreviationForCreatedAt": jsonSelectedData["timeZoneAbbreviationForCreatedAt"].stringValue,
            "timeZoneAbbreviationForUpdatedAt": jsonSelectedData["timeZoneAbbreviationForUpdatedAt"].stringValue,
            "type": jsonSelectedData["type"].stringValue,
            "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
            "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
            "createdByUserId": UserSingletonModel.sharedInstance.userid!,
            "nameOfClient": "My Portal",
            "timeZoneAbbreviationOfClient": localTimeZone,
            "fieldNameOfActivity": "Details Finance",
            "updated_at": dateInFormat,
            "currentDateTimeOfClient": dateInFormat,
            "userId": UserSingletonModel.sharedInstance.userid!
        ]
        print("Submit Details: ",api,sentData)
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
                
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Deleted Successfully!!";
                if swiftyJsonVar["status"].stringValue == "fail" {
                    message = swiftyJsonVar["message"].stringValue
                    
                    Toast(text: message, duration: Delay.short).show()
                    print("Return edit data: ", swiftyJsonVar)
                    
                } else {
                    Toast(text: message, duration: Delay.short).show()
                    self.loadDataFromServer()
                }
                break
                
            case .failure(let error):
                self.loaderEnd()
                print("Error: ", error)
            }
        }
        
    }
    //====================function to delete table row code ends================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FinancialHomeTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]
        
        let arData = JSON(dict)
        //        cell.labelAcntHolder.text = arData[""]
        cell.inputAcntHolder.text = arData["accountHolderName"].stringValue
        
        //        cell.labelAcntType.text = arData["accountHolderName"].stringValue
        cell.inputAcntType.text = arData["type"].stringValue
        
        //        cell.labelBankAcntPatientName.text = arData["accountHolderName"].stringValue
        cell.inputBankAcntPatientName.text = arData["isThisAccountOwnedByPatient"].stringValue
        if arData["type"].stringValue == "Bank account" {
            cell.labelCardNo.isHidden = false
            cell.inputCardNo.isHidden = false
            cell.labelCardNo.text = "A/c number:"
            cell.inputCardNo.text = arData["forTypeBankOrCCOrInsuranceAccountNumber"].stringValue
            
            cell.labelExpiryDate.isHidden = false
            cell.inputExpiryDate.isHidden = false
            cell.labelExpiryDate.text = "Routing number:"
            cell.inputExpiryDate.text = arData["forTypeBankRoutingNumber"].stringValue
            
            cell.labelCardIdNo.isHidden = false
            cell.inputCardIdNo.isHidden = false
            cell.labelCardIdNo.text = "Bank name:"
            cell.inputCardIdNo.text = arData["name"].stringValue
            
            cell.labelBillingZipCode.isHidden = true
            cell.inputBillingZipCode.isHidden = true
        } else if arData["type"].stringValue == "CC" {
            cell.labelCardNo.isHidden = false
            cell.inputCardNo.isHidden = false
            cell.labelCardNo.text = "Credit card number:"
            cell.inputCardNo.text = arData["displayCreditCardNumberFormat"].stringValue
            
            cell.labelExpiryDate.isHidden = false
            cell.inputExpiryDate.isHidden = false
            cell.labelExpiryDate.text = "Expiry date (MM/YYYY):"
            cell.inputExpiryDate.text = arData["forTypeCCExpirationMonth"].stringValue + "/" + arData["forTypeCCExpirationYear"].stringValue
            
            cell.labelCardIdNo.isHidden = false
            cell.inputCardIdNo.isHidden = false
            cell.labelCardIdNo.text = "Card identification number:"
            cell.inputCardIdNo.text = arData["forTypeCCSecurityCode"].stringValue
            
            cell.labelBillingZipCode.isHidden = false
            cell.inputBillingZipCode.isHidden = false
            cell.labelBillingZipCode.text = "Billing zip code:"
            cell.inputBillingZipCode.text = arData["forTypeCCBillingZipCode"].stringValue
        } else if arData["type"].stringValue == "Insurance" {
            cell.labelCardNo.isHidden = false
            cell.inputCardNo.isHidden = false
            cell.labelCardNo.text = "Insurance account no:"
            cell.inputCardNo.text = arData["forTypeBankOrCCOrInsuranceAccountNumber"].stringValue
            
            cell.labelExpiryDate.isHidden = false
            cell.inputExpiryDate.isHidden = false
            cell.labelExpiryDate.text = "Insurance company name:"
            cell.inputExpiryDate.text = arData["payerNote"]["name"].stringValue
            
            cell.labelCardIdNo.isHidden = true
            cell.inputCardIdNo.isHidden = true
            
            cell.labelBillingZipCode.isHidden = true
            cell.inputBillingZipCode.isHidden = true
        } else {
            cell.labelCardNo.isHidden = true
            cell.inputCardNo.isHidden = true
            
            cell.labelExpiryDate.isHidden = true
            cell.inputExpiryDate.isHidden = true
            
            cell.labelCardIdNo.isHidden = true
            cell.inputCardIdNo.isHidden = true
            
            cell.labelBillingZipCode.isHidden = true
            cell.inputBillingZipCode.isHidden = true
        }
        
        return cell
    }
    
    //--------------tableview code ends------------
    
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
        self.performSegue(withIdentifier: "screeninglist", sender: self)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "lifeEvent", sender: self)
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
        
        inputAcntHolderName.text = ""
        inputAcntType.text = ""
        inputBankAcntPatientName.text = ""
        
        labelCreditCardNo.isHidden = true
        inputCreditCardNo.isHidden = true
        
        labelExpiryDate.isHidden = true
        inputExpiryDate.isHidden = true
        
        labelCardIdNo.isHidden = true
        inputCardIdNo.isHidden = true
        
        labelZipCode.isHidden = true
        inputZipCode.isHidden = true
        
        
        print("Add data")
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
    
    //=======================Edit popup code starts================
    
    @IBOutlet var editFormView: UIView!
    @IBOutlet weak var formViewPopupCancelBtnView: UIButton!
    @IBOutlet weak var formViewPopupSubmitBtnView: UIButton!
    
    
    @IBOutlet weak var labelAcntHolderName: UILabel!
    @IBOutlet weak var inputAcntHolderName: UITextField!
    
    @IBOutlet weak var labelAcntType: UILabel!
    @IBOutlet weak var inputAcntType: UITextField!
    
    @IBOutlet weak var labelBankAcntPatientName: UILabel!
    @IBOutlet weak var inputBankAcntPatientName: UITextField!
    
    @IBOutlet weak var labelCreditCardNo: UILabel!
    @IBOutlet weak var inputCreditCardNo: UITextField!
    
    @IBOutlet weak var labelExpiryDate: UILabel!
    @IBOutlet weak var inputExpiryDate: UITextField!
    
    @IBOutlet weak var labelCardIdNo: UILabel!
    @IBOutlet weak var inputCardIdNo: UITextField!
    
    @IBOutlet weak var labelZipCode: UILabel!
    @IBOutlet weak var inputZipCode: UITextField!
    
    @IBAction func formEditCancel(_ sender: Any) {
        print("Edit form Cancel")
        cancelEditFormPopup();
    }
    @IBAction func formEditSubmit(_ sender: Any) {
        print("Submit data")
        updatePayerDetails()
    }
    func designformEditPopup() {
        //        dropDownOfAcntType.isHidden = true  // not in use anymore
        accountTypeView.isHidden = true
        inputAcntType.isUserInteractionEnabled = false
        self.shadow(element: formViewPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectAccountType(_:)))
        inputAcntType.addGestureRecognizer(tap2)
        inputAcntType.isUserInteractionEnabled = true
        
        //----for "Is this bank acnt in patient name" gesture recognizer-------
        bankAccntInPatientNameView.isHidden = true
        inputBankAcntPatientName.isUserInteractionEnabled = false
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.openIsBankAccntInPatientName(_:)))
        inputBankAcntPatientName.addGestureRecognizer(tap3)
        inputBankAcntPatientName.isUserInteractionEnabled = true
    }
    func openEditFormPopup() {
        blurEffect()
        self.formViewPopupSubmitBtnView.isEnabled = true
        insuranceCompanyListDropDown.isHidden = true
        accountTypeView.isHidden = true
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
    //========Is this Bank acnt in patients name Start========
    
    @IBOutlet weak var bankAccntInPatientNameView: UIView!
    
    @objc func openIsBankAccntInPatientName(_ sender:UITapGestureRecognizer){
        bankAccntInPatientNameView.isHidden = false
    }
    
    @IBAction func btnBankAccntInPatientNameYes(_ sender: Any) {
        bankAccntInPatientNameView.isHidden = true
        inputBankAcntPatientName.text = "Yes"
    }
    
    @IBAction func btnBankAccntInPatientNameNo(_ sender: Any) {
        bankAccntInPatientNameView.isHidden = true
        inputBankAcntPatientName.text = "No"
    }
    //========Is this Bank acnt in patients name Ends========
    //==========================Account Type View Start=============
    
    @IBOutlet weak var accountTypeView: UIView!
    @objc func openSelectAccountType(_ sender: UITapGestureRecognizer) {
        accountTypeView.isHidden = false
    }
    
    @IBAction func btnBankAccount(_ sender: Any) {
        insuranceCompanyListDropDown.isHidden = true
        accountTypeView.isHidden = true
        inputAcntType.text = "Bank account"
        //        inputAcntHolderName.text = ""
        inputBankAcntPatientName.text = ""
        
        labelCreditCardNo.isHidden = false
        inputCreditCardNo.isHidden = false
        labelCreditCardNo.text = "A/c number:"
        inputCreditCardNo.text = ""
        inputCreditCardNo.placeholder = "Enter Account Number"
        
        labelExpiryDate.isHidden = false
        inputExpiryDate.isHidden = false
        labelExpiryDate.text = "Routing number:"
        inputExpiryDate.text = ""
        inputExpiryDate.placeholder = "Enter Routing number"
        cancelSelectDatePopup()
        
        labelCardIdNo.isHidden = false
        inputCardIdNo.isHidden = false
        labelCardIdNo.text = "Bank name:"
        inputCardIdNo.text = ""
        inputCardIdNo.placeholder = "Enter Bank name"
        
        labelZipCode.isHidden = true
        inputZipCode.isHidden = true
    }
    
    @IBAction func btnCC(_ sender: Any) {
        insuranceCompanyListDropDown.isHidden = true
        accountTypeView.isHidden = true
        inputAcntType.text = "CC"
        //        inputAcntHolderName.text = ""
        inputBankAcntPatientName.text = ""
        
        labelCreditCardNo.isHidden = false
        inputCreditCardNo.isHidden = false
        labelCreditCardNo.text = "Credit card number:"
        inputCreditCardNo.text = ""
        inputCreditCardNo.placeholder = "Enter Credit card number"
        
        labelExpiryDate.isHidden = false
        inputExpiryDate.isHidden = false
        labelExpiryDate.text = "Expiry date (MM/YYYY):"
        inputExpiryDate.text = ""
        inputExpiryDate.placeholder = "Enter Expiry date (MM/YYYY)"
        addSelectDatePopup()
        
        labelCardIdNo.isHidden = false
        inputCardIdNo.isHidden = false
        labelCardIdNo.text = "Card identification number:"
        inputCardIdNo.text = ""
        inputCardIdNo.placeholder = "Enter Card identification number"
        
        labelZipCode.isHidden = false
        inputZipCode.isHidden = false
        labelZipCode.text = "Billing zip code:"
        inputZipCode.text = ""
        inputZipCode.placeholder = "Enter Billing zip code"
    }
    
    @IBAction func btnInsurance(_ sender: Any) {
        insuranceCompanyListDropDown.isHidden = true
        accountTypeView.isHidden = true
        inputAcntType.text = "Insurance"
        //        inputAcntHolderName.text = ""
        inputBankAcntPatientName.text = ""
        
        labelCreditCardNo.isHidden = false
        inputCreditCardNo.isHidden = false
        labelCreditCardNo.text = "Insurance account no:"
        inputCreditCardNo.text = ""
        inputCreditCardNo.placeholder = "Enter Enter insurance account no"
        
        labelExpiryDate.isHidden = false
        inputExpiryDate.isHidden = false
        labelExpiryDate.text = "Select insurance company name:"
        inputExpiryDate.text = ""
        inputExpiryDate.placeholder = "Enter Select insurance company name"
        cancelSelectDatePopup()
        
        labelCardIdNo.isHidden = true
        inputCardIdNo.isHidden = true
        
        labelZipCode.isHidden = true
        inputZipCode.isHidden = true
    }
    //==========================Account Type View Ends=============
    
    //=======================Insurance Company List Dropdown starts========================
    
    @IBOutlet weak var insuranceCompanyListDropDown: UIPickerView!
    var filterdTerms = [String]()
    func filterContentForSearchText(searchText: String) {
        filterdTerms = arInsuranceCompanyName.filter { termValue in
            return termValue.lowercased().contains(searchText.lowercased())
        }
        
    }
    
    // ======> Phone number field allow anly number
    
    @IBAction func typeInputFieldOnChangeActionForInsuranceCmpnyName(_ sender: Any) {
        if inputAcntType.text == "Insurance" {
            let string = inputExpiryDate.text!
            
            filterContentForSearchText(searchText: string)
            displayInsuranceData = filterdTerms
            print("displayInsuranceData :",displayInsuranceData)
            if displayInsuranceData.count == 0 {
                insuranceCompanyListDropDown.isHidden = true
            } else {
                insuranceCompanyListDropDown.isHidden = false
            }
            insuranceCompanyListDropDown.reloadAllComponents()
            
            insuranceCompanyListDropDown.backgroundColor = UIColor.lightGray
            insuranceCompanyListDropDown.subviews[1].backgroundColor = UIColor.green
            insuranceCompanyListDropDown.subviews[2].backgroundColor = UIColor.green
        }
    }
    var arInsuranceCompanyName = [String]()
    var arInsuranceCompanyNameWithId = [String: Int]()
    var displayInsuranceData: Array<Any> = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayInsuranceData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = displayInsuranceData[row]
        print("titleData",titleData)
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.green])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = UIColor.groupTableViewBackground
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        inputExpiryDate.text = displayInsuranceData[row] as! String
        insuranceCompanyListDropDown.isHidden = true
    }
    //=======================Insurance Company List Dropdown ends========================
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
        //        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.dateFormat = "MM/YYYY"
        let strDate = dateFormatter.string(from: datePickerView.date)
        inputExpiryDate.text = strDate
        closeDatePopup()
    }
    
    
    func addSelectDatePopup() {
        
        
        inputExpiryDate.isUserInteractionEnabled = false
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectDatePopup(_:)))
        inputExpiryDate.addGestureRecognizer(tap2)
        inputExpiryDate.isUserInteractionEnabled = true
        
        self.shadow(element: datePopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: datePopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        
    }
    
    func cancelSelectDatePopup() {
        inputExpiryDate.gestureRecognizers?.removeAll()
        inputExpiryDate.isUserInteractionEnabled = true
        inputExpiryDate.becomeFirstResponder()
    }
    var dateBlurEffectView: UIVisualEffectView!
    @objc func openSelectDatePopup(_ sender: UITapGestureRecognizer) {
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
    
    //=======================Edit popup code ends====================
    
    //======================function to update/add/delete Finance/Payer details code starts========================
    func updatePayerDetails(){
        
        if inputAcntHolderName.text == "" {
            Toast(text: "Please enter Name of the A/c Holder", duration: Delay.short).show()
        }
        if inputAcntType.text == "" {
            Toast(text: "Please select account Type", duration: Delay.short).show()
        }
        if inputBankAcntPatientName.text == "" {
            Toast(text: "Please enter patient's name used in this bank", duration: Delay.short).show()
        }
        
        //==Bank Account
        if inputAcntType.text == "Bank account" && inputCreditCardNo.text == ""{
            Toast(text: "Please enter Bank a/c number ", duration: Delay.short).show()
        }
        if inputAcntType.text == "Bank account" &&  inputExpiryDate.text == ""{
            Toast(text: "Please enter Routing number ", duration: Delay.short).show()
        }
        if inputAcntType.text == "Bank account" && inputCardIdNo.text == ""{
            Toast(text: "Please enter Bank number ", duration: Delay.short).show()
        }
        if inputAcntType.text == "Bank account" && inputCreditCardNo.text == ""{
            Toast(text: "Please enter Bank a/c number ", duration: Delay.short).show()
        }
        
        //===CC
        if inputAcntType.text == "CC" && inputCreditCardNo.text == ""{
            Toast(text: "Please enter Credit card number ", duration: Delay.short).show()
        }
        if inputAcntType.text == "CC" &&  inputExpiryDate.text == ""{
            Toast(text: "Please enter Expiry date (MM/YYYY) ", duration: Delay.short).show()
        }
        if inputAcntType.text == "CC" && inputCardIdNo.text == ""{
            Toast(text: "Please enter identification number ", duration: Delay.short).show()
        }
        if inputAcntType.text == "CC" && inputCreditCardNo.text == ""{
            Toast(text: "Please enter Billing zip code ", duration: Delay.short).show()
        }
        
        //==Insurance
        if inputAcntType.text == "Insurance" && inputCreditCardNo.text == "" {
            Toast(text: "Please enter insurance account no ", duration: Delay.short).show()
        }
        if inputAcntType.text == "Insurance" &&  inputExpiryDate.text == ""{
            Toast(text: "Please select insurance company name", duration: Delay.short).show()
        }
        
        
        //       loaderStart()
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
        if funAction == "Add" {
            var sentData: [String:Any] = [:]
            let api = mainUrl + "savePayerForNativeApp"
            if inputAcntType.text! == "CC" {
                let expiryDate = inputExpiryDate.text!
                let arExpiryDate = expiryDate.components(separatedBy: "/")
                
                let getMonth    = arExpiryDate[0]
                let getYear = arExpiryDate[1]
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": "",  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": getMonth,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": getYear,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": self.inputCardIdNo.text!,
                    "forTypeInsuranceUIDOfCompany": 0,//421,
                    "id": "",
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
                
            }
            else if inputAcntType.text! == "Insurance" {
                var insuranceID = 0;
                if let getMedicineID = self.arInsuranceCompanyNameWithId[self.inputExpiryDate.text!] {
                    insuranceID = getMedicineID;
                }
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": "",  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": 0,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": 0,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": "yes",
                    "forTypeInsuranceUIDOfCompany": insuranceID,//421,
                    "id": "",
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
            }
            else if inputAcntType.text! == "Bank account" {
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": inputExpiryDate.text!,  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": 0,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": 0,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": "yes",
                    "forTypeInsuranceUIDOfCompany": 0,//421,
                    "id": "",
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
            }
            print("Submit Details: ",api,sentData)
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
            //======================Edit part to submit============
        else if funAction == "Edit" {
             var jsonSelectedData = JSON(selectTableRowData)
            var sentData: [String:Any] = [:]
            let api = mainUrl + "updatePayerForNativeApp/" + "\(jsonSelectedData["id"].intValue)"
            if inputAcntType.text! == "CC" {
                let expiryDate = inputExpiryDate.text!
                let arExpiryDate = expiryDate.components(separatedBy: "/")
                
                let getMonth    = arExpiryDate[0]
                let getYear = arExpiryDate[1]
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": "",  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": getMonth,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": getYear,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": self.inputCardIdNo.text!,
                    "forTypeInsuranceUIDOfCompany": 0,//421,
                    "id": jsonSelectedData["id"].intValue,
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
                
            }
            else if inputAcntType.text! == "Insurance" {
                var insuranceID = 0;
                if let getMedicineID = self.arInsuranceCompanyNameWithId[self.inputExpiryDate.text!] {
                    insuranceID = getMedicineID;
                }
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": "",  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": 0,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": 0,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": "yes",
                    "forTypeInsuranceUIDOfCompany": insuranceID,//421,
                    "id": jsonSelectedData["id"].intValue,
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
            }
            else if inputAcntType.text! == "Bank account" {
                sentData = [
                    "accountHolderName": self.inputAcntHolderName.text!,
                    "attachments": "",
                    "created_at": dateInFormat,
                    "forTypeBankOrCCOrInsuranceAccountNumber": self.inputCreditCardNo.text!,
                    "forTypeBankRoutingNumber": inputExpiryDate.text!,  //self.inputExpiryDate.text!,
                    "forTypeCCBillingZipCode": self.inputZipCode.text!,
                    "forTypeCCExpirationMonth": 0,  //self.inputExpiryDate.text!,
                    "forTypeCCExpirationYear": 0,  // self.inputExpiryDate.text!,
                    "forTypeCCIsCVVValid": "yes",
                    "forTypeCCIsCardValid": "yes",
                    "forTypeCCIsExpiryValid": "yes",
                    "forTypeCCIsZipValid": "yes",
                    "forTypeCCSecurityCode": "yes",
                    "forTypeInsuranceUIDOfCompany": 0,//421,
                    "id": jsonSelectedData["id"].intValue,
                    "isItLocked": "no",
                    "isPrimary": 0,
                    "isThisAccountOwnedByPatient": inputBankAcntPatientName.text!,//"Yes",
                    "name": self.inputCardIdNo.text!,
                    "note": "",
                    "payerNote": "test", //self.inputExpiryDate.text!,
                    "priority": 0,
                    "relationWithPatient": "",
                    "timeZoneAbbreviationForCreatedAt": localTimeZone,
                    "timeZoneAbbreviationForUpdatedAt": localTimeZone,
                    "type": self.inputAcntType.text!,
                    "uidOfCreatedBy": UserSingletonModel.sharedInstance.userid!,
                    "uidOfPatient": UserSingletonModel.sharedInstance.userid!,
                    "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                    "nameOfClient": "My Portal",
                    "timeZoneAbbreviationOfClient": localTimeZone,
                    "fieldNameOfActivity": "Details",
                    "updated_at": dateInFormat,
                    "currentDateTimeOfClient": dateInFormat
                ]
            }
            print("Submit Details: ",api,sentData)
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
        }
        
    }
    //======================function to update/add/delete Finance/Payer details code ends========================
    //==================session function code starts==============
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
    
}
