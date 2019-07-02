//
//  LifeEventViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 15/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster


class LifeEventViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,LifeEventTableViewCellDelegate {
   
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
        designformEditPopup();
        designSelectDate();

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
    func loadDataFromServer() {
        loaderStart()
        let api = mainUrl + "showlifeeventsForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["shMajorLifeEvent"].arrayObject {
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
  //----------function to get major life event details code ends----------
    
    
    //-----------tableview code starts-----------
     private var selectTableRowData = [String:AnyObject]()
    func updateLifeEventDetailsTableViewCellDidTapEdit(_ sender: LifeEventTableViewCell) {
        funAction = "Edit"
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        let getJsonData = JSON(selectTableRowData)
        
        inputEvent.text = getJsonData["entityValSet"][0].stringValue
        reactionsInput.text = getJsonData["entityValSet"][3].stringValue
        inputStartDate.text = getJsonData["entityValSet"][1].stringValue
        openEditFormPopup()
    }
    
    func updateLifeEventDetailsTableViewCellDidTapDelete(_ sender: LifeEventTableViewCell) {
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
        
        let getJsonData = JSON(selectTableRowData)
        
        
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
        let api = mainUrl + "destroylifeeventsForNativeApp/"+"\(getJsonData["entityId"].intValue)"
        
        let sentData: [String:Any] = [
            "entityId": getJsonData["entityId"].intValue,
            "entityTypeId": "mle",
            "element": "Major life event",
            "entityValSet": [getJsonData["entityValSet"][0].stringValue, getJsonData["entityValSet"][1].stringValue, getJsonData["entityValSet"][2].stringValue, getJsonData["entityValSet"][3].stringValue],
            "title": getJsonData["entityValSet"][0].stringValue,
            "description": getJsonData["entityValSet"][3].stringValue,
            "value": getJsonData["entityValSet"][0].stringValue,
            "when": getJsonData["entityValSet"][1].stringValue,
            "whenType": getJsonData["entityValSet"][2].stringValue,
            "type": getJsonData["type"].stringValue,
            "userId": UserSingletonModel.sharedInstance.userid!,
            "currentDateTimeOfClient": dateInFormat,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "createdByUserId": UserSingletonModel.sharedInstance.userid!,
            "nameOfClient": "My Portal",
            "fieldNameOfActivity": "Details"
        ]
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
                
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Deleted Successfully!!";
                if swiftyJsonVar["status"].stringValue == "fail" {
                    let message = swiftyJsonVar["message"].stringValue
                    
                    Toast(text: message, duration: Delay.short).show()
                    print("Return Delete False data: ", swiftyJsonVar)
                } else {
                    let data = swiftyJsonVar["message"].stringValue
                    
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
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LifeEventTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]
        
        let arData = JSON(dict)
        cell.displayEvent.text = arData["entityValSet"][0].stringValue
        cell.displayAffect.text = arData["entityValSet"][3].stringValue
        cell.displayStartDate.text = arData["entityValSet"][1].stringValue
        
        return cell
    }
    //----------- tableview code ends -------------
    
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
        self.performSegue(withIdentifier: "financedemo", sender: self)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "updateMedication", sender: self)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let strDate = dateFormatter.string(from: datePickerView.date)
        inputEvent.text = ""
        reactionsInput.text = ""
        inputStartDate.text = strDate
        
        print("datePickerView.date", datePickerView.date)
        datePickerView.setDate(datePickerView.date, animated: false)
        
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
    
    @IBOutlet weak var inputEvent: UITextField!
    @IBOutlet weak var reactionsInput: UITextField!
    @IBOutlet weak var inputStartDate: UITextField!
    
    @IBAction func formEditCancel(_ sender: Any) {
        cancelEditFormPopup();
    }
    @IBAction func formEditSubmit(_ sender: Any) {
        updateLifeEvent()
    }
    func designformEditPopup() {
        self.shadow(element: formViewPopupCancelBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: formViewPopupSubmitBtnView, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    func openEditFormPopup() {
        blurEffect()
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
        
        //------DatePicker  set value code starts (later)--------
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-mm-dd"
        if let date = inputFormatter.date(from: self.inputStartDate.text!) {
            datePickerView.setDate(date, animated: false)
        }
        //------DatePicker  set value code ends--------
        
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
        inputStartDate.text = strDate
        closeDatePopup()
    }
    
    
    func designSelectDate() {
        //        self.showSelectedDateName.text = "United States"
        inputStartDate.isUserInteractionEnabled = false
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.openSelectDatePopup(_:)))
        inputStartDate.addGestureRecognizer(tap2)
        inputStartDate.isUserInteractionEnabled = true
        
        self.shadow(element: datePopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: datePopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
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
    
    //======================function to update LifeEvent code starts here===============
    func updateLifeEvent(){
        loaderStart()
        
        let getJsonData = JSON(selectTableRowData)
        
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
        if funAction == "Edit" {
            let api = mainUrl + "updatelifeeventsForNativeApp/"+"\(UserSingletonModel.sharedInstance.userid!)"
            
            let sentData: [String:Any] = [
                "entityId": getJsonData["entityId"].intValue,
                "entityTypeId": "mle",
                "element": "Major life event",
                "entityValSet": [self.inputEvent.text!, self.inputStartDate.text!, getJsonData["entityValSet"][2].stringValue, self.reactionsInput.text!],
                "title": self.inputEvent.text!,
                "description": self.reactionsInput.text!,
                "value": self.inputEvent.text!,
                "when": self.inputStartDate.text!,
                "whenType": getJsonData["entityValSet"][2].stringValue,
                "type": getJsonData["type"].stringValue,
                "userId": UserSingletonModel.sharedInstance.userid!,
                "currentDateTimeOfClient": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "nameOfClient": "My Portal",
                "fieldNameOfActivity": "Details"
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
            let api = mainUrl + "savelifeeventsForNativeApp/"+"\(UserSingletonModel.sharedInstance.userid!)"
            
            let sentData: [String:Any] = [
                "entityId": "",
                "entityTypeId": "mle",
                "element": "Major life event",
                "entityValSet": [self.inputEvent.text!, self.inputStartDate.text!, "date", self.reactionsInput.text!],
                "title": self.inputEvent.text!,
                "description": self.reactionsInput.text!,
                "value": self.inputEvent.text!,
                "when": self.inputStartDate.text!,
                "whenType": "date",
                "type": "",
                "userId": UserSingletonModel.sharedInstance.userid!,
                "currentDateTimeOfClient": dateInFormat,
                "timeZoneAbbreviationOfClient": localTimeZone,
                "createdByUserId": UserSingletonModel.sharedInstance.userid!,
                "nameOfClient": "My Portal",
                "fieldNameOfActivity": "Details"
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
    //======================function to update LifeEvent code ends===============
   
    
    //==================session function code starts==============
    func removeSassion() {
//        self.performSegue(withIdentifier: "rootPage", sender: self)
        
        self.performSegue(withIdentifier: "root", sender: self)
        
    }
    //==================session function code ends==============
    
}
