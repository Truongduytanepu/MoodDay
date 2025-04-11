//
//  BaseVC.swift
//  SetTimer
//
//  Created by Manh Nguyen Ngoc on 02/07/2021.
//

import Foundation
import UIKit

class BaseVC<Presenter, View>: UIViewController, BaseView {
    // MARK: - Property
    private var viewWillAppeared: Bool = false
    private var viewDidAppeared: Bool = false
    var presenter: Presenter!
    var isShow = false

    static func factory() -> Self {
        let viewController = Self()
        viewController.injectPresenter()
        return viewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShow = true

        if !viewWillAppeared {
            viewWillAppeared = true
            self.viewWillFirstAppear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewDidAppeared {
            viewDidAppeared = true
            self.viewDidFirstAppear()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isShow = false
    }

    func viewWillFirstAppear() {

    }

    func viewDidFirstAppear() {

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Helper
    func injectPresenter() {
        self.presenter = DIContainer.shared.resolve(Presenter.self, agrument: self as! View)
    }
    
    // MARK: - Alert
    func showAlert(title: String = "", message: String = "", titleButtons: [String] = ["OK"], destructiveIndexs: [Int] = [], action: ((Int) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        titleButtons.forEach { (titleButton) in
            let index = titleButtons.firstIndex(of: titleButton)!
            let style = destructiveIndexs.contains(index) ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
            let alertAction = UIAlertAction.init(title: titleButton, style: style, handler: { (_) in
                action?(index)
            })

            alert.addAction(alertAction)
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertEdit(title: String = "", message: String = "", oldValue: String = "", titleButtons: [String] = ["OK"], action: ((Int, String) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.text = oldValue
        }
        
        titleButtons.forEach { (titleButton) in
            let index = titleButtons.firstIndex(of: titleButton)!
            let alertAction = UIAlertAction.init(title: titleButton, style: UIAlertAction.Style.default, handler: { (_) in
                
                let textField = alert.textFields?.first!
                action?(index, textField?.text ?? "")
            })
            
            alert.addAction(alertAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
