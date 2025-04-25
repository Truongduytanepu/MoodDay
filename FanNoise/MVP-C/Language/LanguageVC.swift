//
//  LanguageVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import UIKit

private struct Const {
    static let sizeHeight: Float = 48
    static let minimumInteritemSpacing: CGFloat = 12
}

class LanguageVC: BaseVC<LanguagePresenter, LanguageView> {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var acceptButton: UIButton!
    @IBOutlet private weak var navigationLabel: UILabel!
        
    var coordinator : LanguageCoordinator!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupCollectionView()
        self.setupFont()
        self.setupAcceptButton()
    }
    
    private func setupFont() {
        self.navigationLabel.font = AppFont.font(.mPLUS2SemiBold, size: 16)
    }
    
    private func setupAcceptButton() {
        self.acceptButton.isHidden = true
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "LanguageCell", bundle: nil),forCellWithReuseIdentifier: "LanguageCell")
    }
    
    private func navigateToNextScreen() {
            if let navigationController = self.navigationController {
                let tabbarCoordinator = TabbarCoordinator(navigation: navigationController)
                tabbarCoordinator.start()
            }
        }
    
// MARK: - Action
    @IBAction private func acceptButtonDidTap(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isFirstShowLanguageScreen")

        self.navigateToNextScreen()
    }
}

// MARK: - UICollectionViewDelegate
extension LanguageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.acceptButton.isHidden = false
        for index in 0..<DataLanguage.instance.languageList.count {
            DataLanguage.instance.languageList[index].isSelectLanguage = false
        }
        
        DataLanguage.instance.languageList[indexPath.item].isSelectLanguage = true
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension LanguageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataLanguage.instance.languageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCell", for: indexPath) as? LanguageCell {
            let languageItem = DataLanguage.instance.languageList[indexPath.item]
            cell.configure(with: languageItem)
            return cell
        }
        
        return UICollectionViewCell()
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension LanguageVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CGFloat(Const.sizeHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.minimumInteritemSpacing
    }
}

extension LanguageVC: LanguageView {
    
}
