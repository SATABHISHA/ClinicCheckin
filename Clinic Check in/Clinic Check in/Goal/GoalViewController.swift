//
//  GoalViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 03/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class GoalViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, GoalTableViewCellDelegate {
   
    
    
     public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var sharedpreferences = UserDefaults.standard
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate=self
        self.tableview.dataSource=self
        // Do any additional setup after loading the view.
        InitializationNavItem()
        loadDataFromServer()
        addGestureSwipe()
        designformEditPopup()
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
    
    var arrRes = [[String:AnyObject]]()
    func loadDataFromServer(){
        loaderStart()
        let api = mainUrl + "getLoadDataOfGoalForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
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
    //===============tableview code starts===================
    private var selectTableRowData = [String:AnyObject]()
//    func screeningListTableViewCellDidTapScreening(_ sender: ScreeningListTableViewCell) {
//        print("Do Screening is working")
//        selectTableRowData = [String:AnyObject]()
//
//        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
//        let rowDara = arrRes[tappedIndexPath.row]
//
//        if let objectSelect = rowDara as? [String : Any] {
//            for (key, value) in objectSelect {
//                self.selectTableRowData[key] = JSON(value) as AnyObject
//            }
//        }
//
//        //        let jsonSelectedData = JSON(selectTableRowData)
//        UserSingletonModel.sharedInstance.selectedScreen =  self.selectTableRowData
//        self.performSegue(withIdentifier: "doScreening", sender: self)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GoalTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]
        
        let arData = JSON(dict)
        cell.labelGoalName.text = arData["goal"].stringValue
        cell.sliderRating.value = arData["valueOfTheRating"].floatValue
        return cell
    }
    func goalTableViewCellDidTapSlider(_ sender: GoalTableViewCell) {
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        let getJsonSelectedRow = JSON(rowDara)
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
        
        let api = mainUrl + "saveGoalRatingForNativeApp/"+"\(UserSingletonModel.sharedInstance.userid!)"
        let sentData: [String:Any] = [
            "loginID": UserSingletonModel.sharedInstance.userid!,
            "patientID": UserSingletonModel.sharedInstance.userid!,
            "id": getJsonSelectedRow["id"].intValue,
            "dateOfRate": dateInFormat,
            "createdAt": dateInFormat,
            "valueOfTheRating": Int(sender.sliderRating.value),
            "comment": ""
        ]
        print("Add Goal: ",api,sentData)
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Successfully Rated!!";
                if swiftyJsonVar["status"].stringValue == "success" {
                    Toast(text: message, duration: Delay.short).show()
                } else {
                    Toast(text: "Can't be rated right now!!", duration: Delay.short).show()
                    print("Return edit data: ", swiftyJsonVar)
                }
                break

            case .failure(let error):
                print("Error: ", error)
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
        print("Next")
        self.performSegue(withIdentifier: "pharmacylist", sender: self)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "screeningList", sender: self)
    }
    // ============== Create Navigation item END ================= \\
    // ==================== Footer View START ========================= \\
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logoutBtnView: UIButton!
    @IBAction func logoutAction(_ sender: Any) {
        print("Logout")
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
        inputGoalName.text = ""
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
    
    @IBOutlet weak var inputGoalName: UITextField!
    
    @IBAction func formEditCancel(_ sender: Any) {
        cancelEditFormPopup();
    }
    @IBAction func formEditSubmit(_ sender: Any) {
        addGoal()
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
    
     //--------function to add Goal Name code starts-------
    func addGoal(){
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
        
        let api = mainUrl + "SaveNewGoalForNativeApp"
        loaderStart()
        let sentData: [String:Any] = [
            "uid": UserSingletonModel.sharedInstance.userid!,
            "createdByUserId": UserSingletonModel.sharedInstance.userid!,
            "timeZoneAbbreviationOfClient": localTimeZone,
            "currentDateTimeOfClient": dateInFormat,
            "goal": inputGoalName.text!,
            "priority": "none",
            "created_at": "created_at"
        ]
        print("Add Goal: ",api,sentData)
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Added successfully!!";
                Toast(text: message, duration: Delay.short).show()
                self.cancelEditFormPopup()
                self.loadDataFromServer()
                break

            case .failure(let error):
                self.loaderEnd()
                print("Error: ", error)
            }
        }
    }
    //--------function to add Goal Name code ends-------
    //==================session function code starts==============
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
}
