//
//  SetTimerDialogVC.swift
//  FanNoise
//
//  Created by ADMIN on 5/7/25.
//

import UIKit
import GoogleMobileAds

private struct Const {
    static let loopCount = 100
    static let marginMinute: CGFloat = 20
    static let marginSecond: CGFloat = 25
    static let widthMinuteAndSecond: CGFloat = 40
    static let numberOfComponents = 2
    static let rowHeight: CGFloat = 51
}

class SetTimerDialogVC: BaseVC<SetTimerDialogPresenter, SetTimerDialogView> {
    // MARK: - Lifecycle

    @IBOutlet private weak var nativeView: UIView!
    @IBOutlet private weak var switchView: UIView!
    @IBOutlet private weak var offLbl: UILabel!
    @IBOutlet private weak var onLbl: UILabel!
    @IBOutlet private weak var circleView: UIView!
    @IBOutlet private weak var circleContainerView: UIView!
    @IBOutlet private weak var dialogView: UIView!
    @IBOutlet private weak var setTimerLbl: UILabel!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var doneBtn: UIButton!
    @IBOutlet private weak var cancelBtn: UIButton!
    @IBOutlet private weak var offView: UIView!
    @IBOutlet private weak var onView: UIView!
    
    let baseMinutes = Array(0...10)
    let baseSeconds = Array(0...59)
    
    var minutesData: [Int] = []
    var secondsData: [Int] = []
    var minuteDefault = 5
    var secondDefault = 30
    
    private let minLabel = UILabel()
    private let secLabel = UILabel()
    private var isSwitchOn: Bool = true
    private var nativeAdLoader = NativeAdLoader()
    private var gadNativeAdView: NativeAdView!
    private var nativeAdsView: UIView!
    
    var onTimeSelected: ((Int, Int, Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.setUpFont()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadNativeAds()
    }
    
    private func config() {
        self.configNativeAdsView()
        self.setupTimerData()
        self.setupPickerView()
        self.scrollToValue(minute: self.minuteDefault,
                           second: self.secondDefault)
        self.setupUnitLabels()
        self.setupOnSwitch()
    }
    
    private func setupTimerData() {
        for _ in 0..<Const.loopCount {
            self.minutesData += self.baseMinutes
            self.secondsData += self.baseSeconds
        }
    }
    
    private func configNativeAdsView() {
        self.nativeAdsView = UIView()
        self.nativeAdsView.backgroundColor = .white
        self.nativeAdsView.translatesAutoresizingMaskIntoConstraints = false
        self.nativeView.addSubview(self.nativeAdsView)
        self.nativeAdsView.fitSuperviewConstraint()
        
        self.gadNativeAdView = Bundle.main.loadNibNamed("MainNativeAdIntro", owner: nil, options: nil)!.first as! NativeAdView
        self.gadNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        self.nativeAdsView.addSubview(self.gadNativeAdView)
        self.gadNativeAdView.fitSuperviewConstraint()
    }
    
    private func loadNativeAds() {
        self.nativeAdLoader.loadNativeAd(adCnt: 1, viewController: self) { [weak self] in
            guard let self else { return }
            if !self.nativeAdLoader.nativeAds.isEmpty {
                DispatchQueue.main.async {
                    self.bindNativeAds(gadNativeAdView: self.gadNativeAdView, nativeAd: self.nativeAdLoader.nativeAds[0])
                }
            }
        }
    }
    
    private func bindNativeAds(gadNativeAdView: NativeAdView, nativeAd: NativeAd) {
        gadNativeAdView.nativeAd = nativeAd
        (gadNativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        gadNativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (gadNativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        gadNativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (gadNativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        gadNativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (gadNativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        gadNativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        gadNativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
    private func setupPickerView() {
        self.timePickerView.delegate = self
        self.timePickerView.dataSource = self
    }
    
    private func setupUI() {
        self.circleView.layoutIfNeeded()
        self.switchView.layoutIfNeeded()
        
        self.circleView.layer.cornerRadius = self.circleView.frame.height / 2
        self.circleView.frame.origin.x = self.circleContainerView.bounds.width - self.circleView.frame.width - 2
        self.circleView.clipsToBounds = true
        
        self.switchView.layer.cornerRadius = self.switchView.frame.height / 2
    }
    
    private func setupOnSwitch() {
        self.offView.isHidden = true
        self.onView.isHidden = false
    }
    
    private func setupOffSwitch() {
        self.onView.isHidden = true
        self.offView.isHidden = false
    }
    
    private func setUpFont() {
        self.setTimerLbl.font = AppFont.font(.mPLUS2Bold, size: 14)
        self.onLbl.font = AppFont.font(.mPLUS2Bold, size: 13)
        self.offLbl.font = AppFont.font(.mPLUS2Bold, size: 13)
        self.cancelBtn.titleLabel?.font = AppFont.font(.mPLUS2SemiBold, size: 14)
        self.doneBtn.titleLabel?.font = AppFont.font(.mPLUS2SemiBold, size: 14)
    }
    
    private func setupUnitLabels() {
        let rowHeight = self.timePickerView.rowSize(forComponent: 0).height
        let pickerFrame = self.timePickerView.frame
        let selectedRowY = pickerFrame.midY - (rowHeight / 2)

        // Cập nhật vị trí của nhãn "min"
        self.minLabel.frame = CGRect(
            x: pickerFrame.origin.x + pickerFrame.width * 0.25 + Const.marginMinute,
            y: selectedRowY,
            width: Const.widthMinuteAndSecond,
            height: rowHeight
        )
        self.minLabel.text = "min"
        self.minLabel.font = AppFont.font(.mPLUS2Medium, size: 13)
        self.minLabel.textAlignment = .left
        self.dialogView.addSubview(self.minLabel)
        
        // Cập nhật vị trí của nhãn "sec"
        self.secLabel.frame = CGRect(
            x: pickerFrame.origin.x + pickerFrame.width * 0.75 + Const.marginSecond,
            y: selectedRowY,
            width: Const.widthMinuteAndSecond,
            height: rowHeight
        )
        self.secLabel.text = "sec"
        self.secLabel.font = AppFont.font(.mPLUS2Medium, size: 13)
        self.secLabel.textAlignment = .left
        self.dialogView.addSubview(self.secLabel)
    }

    private func scrollToValue(minute: Int, second: Int) {
        let minuteRow = self.centerRow(for: minute,
                                       in: self.baseMinutes,
                                       total: self.minutesData.count)
        let secondRow = self.centerRow(for: second,
                                       in: self.baseSeconds,
                                       total: self.secondsData.count)
        
        self.timePickerView.selectRow(minuteRow, inComponent: 0, animated: false)
        self.timePickerView.selectRow(secondRow, inComponent: 1, animated: false)
    }
    
    private func centerRow(for value: Int, in baseArray: [Int], total: Int) -> Int {
        let baseCount = baseArray.count
        let middle = (total / 2) - ((total / 2) % baseCount)
        return middle + (value % baseCount)
    }
    
    @IBAction private func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func doneBtnTapped(_ sender: Any) {
        let selectedMinute = self.minutesData[self.timePickerView.selectedRow(inComponent: 0)]
        let selectedSecond = self.secondsData[self.timePickerView.selectedRow(inComponent: 1)]
        
        self.onTimeSelected?(selectedMinute, selectedSecond, self.isSwitchOn)
    }
    
    @IBAction private func switchBtnTapped(_ sender: Any) {
        self.isSwitchOn.toggle()
        
        self.isSwitchOn ? self.setupOnSwitch() : self.setupOffSwitch()
        
        let containerWidth = self.circleContainerView.bounds.width
        let circleWidth = self.circleView.bounds.width
        let padding: CGFloat = 2
        
        UIView.animate(withDuration: 0.25) {
            self.circleView.frame.origin.x = self.isSwitchOn ?
            (containerWidth - circleWidth - padding) :
            padding
        }
    }
}

extension SetTimerDialogVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Const.numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? self.minutesData.count : self.secondsData.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat {
        return Const.rowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width / 2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let selectedRow = pickerView.selectedRow(inComponent: component)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.text = String(format: "%02d", component == 0 ? self.minutesData[row] : self.secondsData[row])
        
        if row == selectedRow {
            label.font = AppFont.font(.mPLUS2SemiBold, size: 24)
        } else {
            label.font = AppFont.font(.mPLUS2Regular, size: 20)
        }
        
        let containerView = UIView()
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: pickerView.rowSize(forComponent: component).height)
        ])
        
        return containerView
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let baseCount = component == 0 ? self.baseMinutes.count : self.baseSeconds.count
        let totalData = component == 0 ? self.minutesData.count : self.secondsData.count

        if row < baseCount || row > totalData - baseCount {
            let middle = (totalData / 2) - ((totalData / 2) % baseCount)
            let newRow = middle + (row % baseCount)
            pickerView.selectRow(newRow, inComponent: component, animated: false)
        }

        pickerView.reloadComponent(component)
    }
}

extension SetTimerDialogVC: SetTimerDialogView {
    
}
