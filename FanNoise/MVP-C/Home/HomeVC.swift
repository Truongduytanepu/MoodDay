//
//  HomeVC.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit
import SVProgressHUD
import FirebaseAnalytics

private struct Const {
    static let insetLeftRight: CGFloat = 12
    static let cellSpacing: CGFloat = 12
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    static let numberOfColumns: CGFloat = 2
    static let ratioCellFirst: CGFloat = 336 / 180
}

class HomeVC: BaseVC<HomePresenter, HomeView> {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    
    var coordinator: HomeCoordinator!
    var idCategory: String = ""
    private var homeCategories: [HomeCategory] = []
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupGradient()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
    }
    
    // MARK: - Config
    private func config() {
        self.setupFont()
        self.setupCollectionview()
        self.loadCategory()
        self.configNetwork()
    }
    
    @objc private func notificationNetwork() {
        if !self.isShow { return }
        
        if !MonitorNetwork.shared.isConnectedNetwork() {
            self.postAlert("Notification", message: "No Internet")
            return
        }
        
        self.loadCategory()
    }
    
    private func configNetwork() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNetwork), name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
    }
    
    private func setupFont() {
        self.titleLabel.font = AppFont.font(.mPLUS2Black, size: 20)
        self.descriptionLabel.font = AppFont.font(.mPLUS2Regular, size: 11)
    }
    
    private func loadCategory() {
        SVProgressHUD.show()
        self.presenter.getHomeCategory()
    }
    
    private func setupGradient() {
        // Tạo một gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Đặt kích thước layer
        gradientLayer.frame = view.bounds
        
        // Đặt màu cho gradient
        gradientLayer.colors = [
            UIColor(rgb: 0xEDFFE8).cgColor,
            UIColor(rgb: 0xE5F0FF).cgColor
        ]
        
        // Thêm gradient layer vào view
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupCollectionview() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
    }
    
    private func startNaturalSoundWhiteNoiseCoordinator(navigationController: UINavigationController, homeCategory: HomeCategory) {
        let naturalSoundWhiteNoiseCoordinator = NaturalSoundWhiteNoiseCoordinator(navigation: navigationController, homeCategory: homeCategory)
        naturalSoundWhiteNoiseCoordinator.start()
    }
    
    private func startListItemSound(navigationController: UINavigationController,
                                    sound: [Sound],
                                    video: [Video],
                                    categoryID: String) {
        let listItemSoundCoordinator = ListItemSoundCoordinator(navigation: navigationController,
                                                                sound: sound,
                                                                video: video,
                                                                categoryID: categoryID)
        listItemSoundCoordinator.start()
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action: () -> Void
        
        Analytics.logEvent("Home", parameters: [
            "name": "Home_Category_\(homeCategories[indexPath.row].name ?? "")"
        ])
        
        if indexPath.row == 1 || indexPath.row == 2 {
            action = { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard let navigationController = self.navigationController else {
                    return
                }
                
                self.startNaturalSoundWhiteNoiseCoordinator(navigationController: navigationController,homeCategory: homeCategories[indexPath.row])
            }
        } else {
            action = { [weak self] in
                guard let self = self else {
                    return
                }
                
                guard let navigationController = self.navigationController else {
                    return
                }
                
                let categoryID = self.homeCategories[indexPath.row].id ?? ""
                let sound = self.presenter.getSoundByCategoryId(categoryId: categoryID)
                let video = self.presenter.getVideoByCategoryId(categoryId: categoryID)
                self.startListItemSound(navigationController: navigationController,
                                        sound: sound,
                                        video: video,
                                        categoryID: categoryID)
            }
        }
        
        self.executeWithAdCheck(action)
    }
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: CategoryCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.setupTitleLabel(index: indexPath.row)
        cell.configure(homeCategories[indexPath.row])
        return cell
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let width = collectionView.bounds.width - 2 * Const.insetLeftRight
            let height = width / Const.ratioCellFirst
            return CGSize(width: width, height: height)
            
        } else {
            let width = (collectionView.bounds.width - Const.cellSpacing * (Const.numberOfColumns - 1) - 2 * Const.insetLeftRight) / Const.numberOfColumns
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Const.insetForSectionAt
    }
}

extension HomeVC: HomeView {
    func saveDataCategory(_ data: [HomeCategory]) {
        HomeCategoryManager.shared.updateCategories(data)
    }
    
    func onLoadHomeCategory(_ data: [HomeCategory]) {
        SVProgressHUD.dismiss()
        self.homeCategories = data
        self.collectionView.reloadData()
    }
    
    func onError(_ error: Error) {
        SVProgressHUD.dismiss()
        self.postAlert("Notification", message: "No Internet")
    }
}
