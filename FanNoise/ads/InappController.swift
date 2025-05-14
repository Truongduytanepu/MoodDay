import UIKit
import StoreKit
import SwiftyStoreKit
import Firebase
import SVProgressHUD
import AVKit
// swiftlint:disable all
@objc public class InappController: UIViewController {
    
    @IBOutlet weak var btnYear: UIImageView!
    @IBOutlet weak var btnWeek: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    
    var nameScreen = "Killapp"
    var checkInapp: Bool = false
    var productId = ProductID.keyyearly
    var eventFb = "click_year"
    var preferences = UserDefaults.standard
    var checkCancel = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        btnYear.isUserInteractionEnabled = true
        btnYear.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickYear)))
        btnWeek.isUserInteractionEnabled = true
        btnWeek.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickWeek)))
    }
    
    
    @IBAction func clickCancle(_ sender: Any) {
        let event = nameScreen + "_X"
        Analytics.logEvent(event, parameters: [
            "name": event as NSObject,
            "full_text": "cancle" as NSObject
        ])
        
        let preferences = UserDefaults.standard
        let currentLevelKey = "ShowAds"
        if preferences.object(forKey: currentLevelKey) != nil {
            let newCount = preferences.integer(forKey: currentLevelKey) + 1
            if newCount > 2 {
                preferences.set(1, forKey: currentLevelKey)
                preferences.synchronize()
            } else {
                preferences.set(newCount, forKey: currentLevelKey)
                preferences.synchronize()
            }
        } else {
            preferences.set(1, forKey: currentLevelKey)
            preferences.synchronize()
        }
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @objc func clickYear(){
        productId = ProductID.keyyearly
        btnYear.image = UIImage(named: "bg_yeart")
        btnWeek.image = UIImage(named: "bg_weekf")
        eventFb = "_Year"
    }
    
    @objc func clickWeek(){
        productId = ProductID.keyweekly
        btnYear.image = UIImage(named: "bg_yearf")
        btnWeek.image = UIImage(named: "bg_weekt")
        eventFb = "_Week"
        
    }
    
    
    func clickContinue() {
        InappPurchase.purchase(productID: productId, atomically: true, completion: { (isSuccess, error) in
            self.handlePurchase(isSuccess: isSuccess, error: error)
        })
        
        let event = nameScreen + eventFb
        Analytics.logEvent(event, parameters: [
            "name": event as NSObject,
            "full_text": "Click Continue" as NSObject
        ])
    }
    
    @IBAction func clickBtnTrial(_ sender: Any) {
        clickContinue()
    }
    
    @IBAction func clickPolicy(_ sender: Any) {
        let url =  UtilsADS.POLICYURL
        if let shareUrl = URL(string: url) {
            UIApplication.shared.open(shareUrl, options: [:], completionHandler: nil)
        }
        
        Analytics.logEvent("click_term", parameters: [
            "name": "solar jsc" as NSObject,
            "full_text": "click_term" as NSObject
        ])
    }
    
    @IBAction func clickRestore(_ sender: Any) {
        Analytics.logEvent("click_restore", parameters: [
            "name": "solar jsc" as NSObject,
            "full_text": "click_restore" as NSObject
        ])
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if !results.restoreFailedPurchases.isEmpty {
                self.showAlertMessage(titleStr: "Failed", messageStr: "\(results.restoreFailedPurchases)")
            }else if !results.restoredPurchases.isEmpty {
                self.showAlertMessage(titleStr: "Success", messageStr: "")
                self.openMainTabbar(isSuccess: true)
            }else {
                self.showAlertMessage(titleStr: "Nothing", messageStr: "")
            }
        }
    }
    
    func handlePurchase(isSuccess: Bool, error: SKError?) {
        if isSuccess {
            
            self.openMainTabbar(isSuccess: isSuccess)
            
            Analytics.logEvent("sub_success", parameters: [
                "name": "solar jsc" as NSObject,
                "full_text": eventFb as NSObject
            ])
        } else {
            let event = "False_"  + nameScreen + eventFb
            Analytics.logEvent(event, parameters: [
                "name": event as NSObject,
                "full_text": "false" as NSObject
            ])
            
            self.showError(error: error)
        }
    }
    
    func openMainTabbar(isSuccess: Bool) -> Void {
        SVProgressHUD.show()
        PremiumUser.isPremium = isSuccess
        if PremiumUser.isPremium == true {
            UtilsADS.shared.removePurchase(key: KEY_ENCODE.isPremium)
            UtilsADS.shared.savePurchase(key: KEY_ENCODE.isPremium, value: true)
        } else {
            UtilsADS.shared.removePurchase(key: KEY_ENCODE.isPremium)
            UtilsADS.shared.savePurchase(key: KEY_ENCODE.isPremium, value: false)
        }
        
        SVProgressHUD.dismiss()
        self.navigationController?.popViewController(animated: true)
    }
    
    func showError(error: SKError?) {
        switch error?.code {
        case .unknown?:
            if let errorDesc = error?.localizedDescription {
                self.showAlertMessage(titleStr: "Unknown error!", messageStr: errorDesc)
            } else {
                self.showAlertMessage(titleStr: "Unknown error", messageStr: "Unknown error! Please contact support.")
            }
            
            break
        case .clientInvalid?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "Not allowed to make the payment.")
            break
        case .paymentCancelled?:
            
            break
        case .paymentInvalid?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "The purchase identifier was invalid.")
            break
        case .paymentNotAllowed?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "The device is not allowed to make the payment.")
            break
        case .storeProductNotAvailable?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "The product is not available in the current storefront.")
            break
        case .cloudServicePermissionDenied?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "Access to cloud service information is not allowed.")
            break
        case .cloudServiceNetworkConnectionFailed?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "Could not connect to the network.")
            break
        case .cloudServiceRevoked?:
            self.showAlertMessage(titleStr: "Error!", messageStr: "User has revoked permission to use this cloud service.")
            break
        default:
            //self.showAlertMessage(titleStr: "Oops!!!", messageStr: "Somethings went wrong! \nPlease try again!")
            break
        }
    }
}

extension UIViewController {
    func showAlertMessage(titleStr:String, messageStr:String) {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
