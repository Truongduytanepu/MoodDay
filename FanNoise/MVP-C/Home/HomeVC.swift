//
//  HomeVC.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit
import SVProgressHUD

private struct Const {
    static let insetLeft: CGFloat = 12
    static let insetRigtht: CGFloat = 12
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
    
    // MARK: - Config
    private func config() {
        self.setupFont()
        self.configNetwork()
        self.configCollectionview()
    }
    
    private func configNetwork() {
        if MonitorNetwork.shared.isConnectedNetwork() {
            self.loadCategory()
            self.contentView.isHidden = false
        } else {
            self.contentView.isHidden = true
        }
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
    
    private func configCollectionview() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
    }
    
    private func startNaturalSoundWhiteNoiseCoordinator(navigationController: UINavigationController,
                                            categoryId: String,
                                            categoryName: String) {
        let naturalSoundWhiteNoiseCoordinator = NaturalSoundWhiteNoiseCoordinator(navigation: navigationController,
                                                          categoryId: categoryId,
                                                          categoryName: categoryName)
        naturalSoundWhiteNoiseCoordinator.start()
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Chỉ xử lý khi chọn cell thứ 2 hoặc 3 (index 1 hoặc 2)
        
        if indexPath.row == 1 || indexPath.row == 2 {
            guard let navigationController = self.navigationController else { return }
            let homeCategoryName = HomeCategoryManager.shared.getCategories()[indexPath.row].name ?? ""
            let homeCategoryId = HomeCategoryManager.shared.getCategories()[indexPath.row].id ?? ""
            self.startNaturalSoundWhiteNoiseCoordinator(navigationController: navigationController,
                                       categoryId: homeCategoryId,
                                       categoryName: homeCategoryName)
        }
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
            let width = collectionView.bounds.width - Const.insetLeft - Const.insetRigtht
            let height = width / Const.ratioCellFirst
            return CGSize(width: width, height: height)

        } else {
            let width = (collectionView.bounds.width - Const.cellSpacing * (Const.numberOfColumns - 1) - Const.insetLeft - Const.insetRigtht) / Const.numberOfColumns
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
