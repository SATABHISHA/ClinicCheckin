//
//  ScreeningListViewController.swift
//  Clinic Check in
//
//  Created by Satabhisha on 26/06/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog
import Toaster

class ScreeningListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ScreeningListTableViewCellDelegate {
    public var mainUrl = "https://www.savantcare.com/v3/api/ma-clinic-check-in/public/index.php/api/";
    public var sharedpreferences = UserDefaults.standard
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate=self
        self.tableview.dataSource=self
        
        InitializationNavItem()
        addGestureSwipe()
        loadDataFromServer()
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
    

    var arrRes = [[String:AnyObject]]()
    func loadDataFromServer(){
        loaderStart()
        let api = mainUrl + "getLoadDataOfScreeningForNativeApp/" + "\(UserSingletonModel.sharedInstance.uuid!)"
        Alamofire.request(api).responseJSON{ (responseData) -> Void in
            self.loaderEnd()
            if((responseData.result.value) != nil){
                let swiftyJsonVar=JSON(responseData.result.value!)
                if let resData = swiftyJsonVar["patientAssignedScreens"].arrayObject{
                    self.arrRes = resData as! [[String:AnyObject]]
                }
                if self.arrRes.count>0 {
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
            }
            
        }
    }
    //===============tableview code starts===================
    private var selectTableRowData = [String:AnyObject]()
    func screeningListTableViewCellDidTapScreening(_ sender: ScreeningListTableViewCell) {
        print("Do Screening is working")
        selectTableRowData = [String:AnyObject]()
        
        guard let tappedIndexPath = tableview.indexPath(for: sender) else { return }
        let rowDara = arrRes[tappedIndexPath.row]
        
        if let objectSelect = rowDara as? [String : Any] {
            for (key, value) in objectSelect {
                self.selectTableRowData[key] = JSON(value) as AnyObject
            }
        }
        
//        let jsonSelectedData = JSON(selectTableRowData)
        UserSingletonModel.sharedInstance.selectedScreen =  self.selectTableRowData
         self.performSegue(withIdentifier: "doScreening", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ScreeningListTableViewCell
        cell.delegate = self
        
        let dict = arrRes[indexPath.row]
        
        let arData = JSON(dict)
        cell.labelScreeningList.text = arData["name"].stringValue
        cell.labelTimeTaken.text = arData["createdOn"].stringValue
        return cell
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
        self.performSegue(withIdentifier: "goal", sender: self)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.performSegue(withIdentifier: "financehome", sender: self)
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
    //==================session function code starts==============
    
    //==================session function code starts==============
    func removeSassion() {
        self.performSegue(withIdentifier: "rootPage", sender: self)
        
    }
    //==================session function code ends==============
    //==================session function code ends==============
    
}
