//
//  AdsFilterTrendingCell.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 7/9/25.
//

import UIKit
import GoogleMobileAds

class AdsFilterTrendingCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!

    private var nativeAdView: NativeAdView!

    override func awakeFromNib() {
        super.awakeFromNib()
        nativeAdView = Bundle.main.loadNibNamed("FilterTrendingAdView", owner: nil, options: nil)!.first as! NativeAdView
        self.containerView.addSubview(self.nativeAdView)
        self.nativeAdView.fitSuperviewConstraint()
    }

    func bind(nativeAd: NativeAd) {
        self.nativeAdView.nativeAd = nativeAd
        
        print("nativeAd.headline = \(String(describing: nativeAd.headline))")
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        nativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
}
