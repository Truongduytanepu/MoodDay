//
//  ListItemSoundVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit

class ListItemSoundVC: BaseVC<ListItemSoundPresenter, ListItemSoundView> {
    // MARK: - Lifecycle
    var coordinator : ListItemSoundCoordinator!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {

    }
}

extension ListItemSoundVC: ListItemSoundView {
    
}
