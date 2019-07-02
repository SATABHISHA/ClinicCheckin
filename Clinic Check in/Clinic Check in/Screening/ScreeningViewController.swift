//
//  ScreeningViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 02/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class ScreeningViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ScreeningTableViewCellDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
   
    
    
    @IBOutlet weak var tableview: UITableView!
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var deviceID = UIDevice.current.identifierForVendor!.uuidString
    public var sharedpreferences = UserDefaults.standard
    public var isLogin: Bool!
    
    @IBOutlet weak var NavHeaderView: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate=self
        self.tableview.dataSource=self
        
        loadDataFromServer();
        
        InitializationNavItem()
        designSelectAnswerPopup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //====================function to get questions and answers starts==============
    var arrRes = [[String:AnyObject]]()
    var screenReportID: Int = 0;
    func loadDataFromServer(){
        var selectedJsonData = JSON(UserSingletonModel.sharedInstance.selectedScreen)
        NavHeaderView.title = selectedJsonData["name"].stringValue
        loaderStart()
        let api = mainUrl + "getScreeningDetailsForNativeApp/" + "\(selectedJsonData["screenId"].intValue)"
        
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar = JSON(responseData.result.value!)
                self.totalQutionNumber = swiftyJsonVar["totalQuestionsNo"].intValue
                self.totalAnswerNumber = swiftyJsonVar["totalAnswerNumber"].intValue
                if let resData = swiftyJsonVar["shScreening"].arrayObject{
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
    //====================function to get questions and answers ends==============
    //=====================tableview code starts===============
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    var cellViewColorMode: Bool = false
    var totalQutionNumber: Int = 0
    var totalAnswerNumber: Int = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ScreeningTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]
        
        let arData = JSON(dict)
        if(arData["screenReportID"].stringValue != "") {
            screenReportID = arData["screenReportID"].intValue
        }
        cell.labelScreeningQuestion.text = arData["groupName"].stringValue + " " + arData["element"].stringValue
        var selectAnswer = "Select Answer";
        cell.labelSelectedAnswer.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        let jsonDataOfAnswer = JSON(dict["fieldAnsList"] as Any)
        
        var cellViewWidth = 0
        var cellViewBorderColor = UIColor.clear.cgColor
        for (_, value) in jsonDataOfAnswer {
            let data = JSON(value)
            cellViewWidth = 1
            cellViewBorderColor = UIColor.red.cgColor
            if(arData["entityVal"].intValue != 0 && data["answerId"].intValue == arData["entityVal"].intValue) {
                selectAnswer = data["text"].stringValue
                
                cell.labelSelectedAnswer.setTitleColor(UIColor.green, for: UIControlState.normal)
                cellViewWidth = 1
                cellViewBorderColor = UIColor.green.cgColor
                break
            }
        }
        if(cellViewColorMode == true) {
            cell.DisplayTableCellView.layer.borderWidth = CGFloat(cellViewWidth)
            cell.DisplayTableCellView.layer.borderColor = cellViewBorderColor
        }
        cell.labelSelectedAnswer.setTitle(selectAnswer, for: .normal)
        
        return cell
    }
    
   
    var selecteTableRowIndex: Int = 0
    func screeningTableViewCellDidTapSelectAnswer(_ sender: ScreeningTableViewCell) {
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        selecteTableRowIndex = tappedIndexPath.row
        let rowDara = arrRes[tappedIndexPath.row]
        let jsonData = JSON(rowDara["fieldAnsList"] as Any)
        arAnswerDataWithName = [String: Int]()
        answerListData = []
        
        for (key, value) in jsonData {
            let data = JSON(value)
            self.answerListData.append(data["text"].stringValue)
            self.arAnswerDataWithName[data["text"].stringValue] = data["answerId"].intValue
        }
        answerPickerView.reloadAllComponents()
        
        let getAnswer = sender.labelSelectedAnswer.titleLabel?.text
        openSelectAnswerPopup(answer: getAnswer!)
    }
    //=====================tableview code ends===============
    
    
    // ============== Create Navigation item START ================= \\
    
  func InitializationNavItem() {
        let submitButton = UIButton()
        submitButton.frame = CGRect(x:0, y:0, width:70, height:30)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.setTitle("Submit", for: .highlighted)
        submitButton.backgroundColor = UIColor.green
        submitButton.layer.cornerRadius = 5.0
        submitButton.addTarget(self, action: #selector(tapSubmitScreening), for: .touchUpInside)
    
        let rightBarButton = UIBarButtonItem(customView: submitButton)
        NavHeaderView.rightBarButtonItem = rightBarButton
//        NavHeaderView.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(tapSubmitScreening))
    
        loginNameLabel.text = UserSingletonModel.sharedInstance.fullname!
        //        footerView.layer.zPosition = 2
        self.shadow(element: footerView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
    
        self.shadow(element: logoutBtnView, radius: 1, opacity: 2, offset: CGSize(width: 0, height: -1), shadowColor: UIColor.gray.cgColor)
        logoutBtnView.layer.cornerRadius = 10
    }
   @objc func tapSubmitScreening() {
        cellViewColorMode = true
        if totalQutionNumber == totalAnswerNumber {
            
            loaderStart()
            let sentData: [String:Any] = [
                "reportID": screenReportID
            ]
            let api = mainUrl + "completeScreeningAnswerForNativeApp/" + "\(screenReportID)"
            
            Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                response in
                switch response.result{
                case .success:
                    self.loaderEnd()
                    let swiftyJsonVar = JSON(response.result.value!)
                    var message = "Saved successfully!!";
                    if swiftyJsonVar["status"].stringValue == "success" {
                        let data = swiftyJsonVar["message"].stringValue
                        if !data.isEmpty {
                            message = data
                        }
                        Toast(text: message, duration: Delay.short).show()
                        self.performSegue(withIdentifier: "screeningList", sender: self)
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
            
        } else {
            let remainAns = totalQutionNumber - totalAnswerNumber
            Toast(text: "You still have to answer \(remainAns) required questions", duration: Delay.short).show()
            self.tableview.reloadData()
        }
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
        removeSassion()
    }
    // ==================== Footer View END ========================= \\
    
    func shadow(element: UIView, radius: CGFloat, opacity: Float, offset: CGSize, shadowColor: CGColor) {
        element.layer.shadowColor = shadowColor
        element.layer.shadowOpacity = opacity
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
    
    //================== Select answer popup Start =============== \\
    @IBOutlet var answerPopup: UIView!
    @IBOutlet weak var answerPopupHeader: UILabel!
    @IBOutlet weak var answerPickerView: UIPickerView!
    
    @IBOutlet weak var answerPopupCancelBtn: UIButton!
    @IBOutlet weak var answerPopupOkBtn: UIButton!
    
    
    
    @IBAction func answerPickerCacleBtn(_ sender: Any) {
        closeAnswerPopup()
    }
    @IBAction func selectAnswerSubmitBtn(_ sender: Any) {
        let selectedAnswerPickerIndex = answerPickerView.selectedRow(inComponent: 0)
        let selectAnswer = answerListData[selectedAnswerPickerIndex]
        
        var prData = arrRes[selecteTableRowIndex]
        
        var answerID = 0;
        if let getAnswerID = arAnswerDataWithName[selectAnswer as! String] {
            answerID = getAnswerID;
        }
        
        prData["entityVal"] = answerID as AnyObject
        
        loaderStart()
        let sentData: [String:Any] = [
            "loginID": UserSingletonModel.sharedInstance.userid!,
            "patientID": UserSingletonModel.sharedInstance.userid!,
            "screening": prData
        ]
        let api = mainUrl + "saveScreeningAnswerForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        
        Alamofire.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
            response in
            switch response.result{
            case .success:
                self.loaderEnd()
                let swiftyJsonVar = JSON(response.result.value!)
                var message = "Answer Selected!!";
                if swiftyJsonVar["status"].stringValue == "success" {
                    let data = swiftyJsonVar["message"].stringValue
                    if !data.isEmpty {
                        message = data
                    }
                    Toast(text: message, duration: Delay.short).show()
                    self.closeAnswerPopup()
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
    
    
    func designSelectAnswerPopup() {
        self.shadow(element: answerPopupCancelBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
        self.shadow(element: answerPopupOkBtn, radius: 2, opacity: 1, offset: CGSize(width: 1, height: 0), shadowColor: UIColor.gray.cgColor)
    }
    
    func cancelSelectAnswerPopup() {
        closeAnswerPopup()
    }
    var answerBlurEffectView: UIVisualEffectView!
    func openSelectAnswerPopup(answer: String) {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        answerBlurEffectView = UIVisualEffectView(effect: blurEffect)
        answerBlurEffectView.frame = view.bounds
        answerBlurEffectView.alpha = 0.9
        view.addSubview(answerBlurEffectView)
        // screen roted and size resize automatic
        answerBlurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
        self.view.addSubview(answerPopup);
        answerPopup.center = self.view.center;
        
        
        
        answerPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        answerPopup.alpha = 054444
        
        UIView.animate(withDuration: 0.4) {
            self.answerPopup.alpha = 1
            self.answerPopup.transform = CGAffineTransform.identity
        }
        self.shadow(element: answerPopup, radius: 1, opacity: 2, offset: CGSize(width: 0, height: 0), shadowColor: UIColor.black.cgColor)
        
        answerPopupHeader.layer.borderWidth = 1
        answerPopupHeader.layer.borderColor = UIColor.gray.cgColor
        
        // ========= set picker value Start ========================= \\
        var defaultRowIndex = answerListData.index(where: { $0 as! String == answer})
        if(defaultRowIndex == nil) { defaultRowIndex = 0 }
        answerPickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        // ========= set picker value End ========================= \\
        
    }
    func closeAnswerPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.answerPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.answerPopup.alpha = 0
            self.answerBlurEffectView.alpha = 0.3
        }) { (success) in
            self.answerPopup.removeFromSuperview();
            self.answerBlurEffectView.removeFromSuperview();
        }
    }
    var arAnswerDataWithName = [String: Int]()
    var answerListData: Array<Any> = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answerListData.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = answerListData[row]
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedStringKey.foregroundColor:UIColor.green])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = UIColor.groupTableViewBackground
        return pickerLabel
    }
    
    //================== Select answer popup END =============== \\
    //==================session function code starts==============
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============

}
