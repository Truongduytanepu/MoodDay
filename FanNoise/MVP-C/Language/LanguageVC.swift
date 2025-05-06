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
    private var choseLanguage: Language?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.choseLanguage = LanguageManager.shared.getChoseLanguage()
        self.setupCollectionView()
        self.setupFont()
    }
    
    private func setupFont() {
        self.navigationLabel.font = AppFont.font(.mPLUS2SemiBold, size: 16)
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: LanguageCell.self)
    }
    
    private func navigateToNextScreen() {
        if let navigationController = self.navigationController {
            let tabbarCoordinator = TabbarCoordinator(navigation: navigationController)
            tabbarCoordinator.start()
        }
    }
    
    // MARK: - Action
    @IBAction private func acceptButtonDidTap(_ sender: Any) {
        if let choseLanguage = choseLanguage {
            LanguageManager.shared.setChoseLanguage(choseLanguage)
        }
        
        self.navigateToNextScreen()
    }
}

// MARK: - UICollectionViewDelegate
extension LanguageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath
    ) {
        if let choseLanguage = choseLanguage,
           let cell = collectionView.cellForItem(at: IndexPath(item: choseLanguage.rawValue, section: 0)) as? LanguageCell {
            cell.deselect()
        }
        
        self.choseLanguage = Language.allCases[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? LanguageCell {
            cell.select()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension LanguageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Language.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: LanguageCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.config(language: Language.allCases[indexPath.item])
        if let choseLanguage = choseLanguage, choseLanguage == Language.allCases[indexPath.item] {
            cell.select()
        } else {
            cell.deselect()
        }
        
        return cell
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
