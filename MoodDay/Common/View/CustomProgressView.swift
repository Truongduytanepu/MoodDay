//
//  CustomProgressView.swift
//  MoodDay
//
//  Created by Trương Duy Tân on 26/8/25.
//

import UIKit

class CustomProgressView: UIView {
    // Thanh nền (background)
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1) // Xám nhạt
        return view
    }()
    // Thanh tiến trình (phần xanh đậm)
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 17/255, green: 29/255, blue: 51/255, alpha: 1) // #111D33
        return view
    }()
    // Thanh trắng nhỏ bên trong
    private let innerProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        return view
    }()
    
    // Giá trị progress (0...1)
    var progress: CGFloat = 0.4 {
        didSet { setNeedsLayout() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    
    private func setup() {
        addSubview(backgroundView)
        addSubview(progressView)
        progressView.addSubview(innerProgressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Bo tròn các góc
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
        
        let progressWidth = bounds.width * progress
        progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
        progressView.layer.cornerRadius = bounds.height / 2
        
        // Inner bar nhỏ bên trong
        let margin: CGFloat = 8
        let innerHeight = bounds.height * 0.38
        let innerY = (bounds.height - innerHeight) / 2
        let innerWidth = max(progressWidth - margin * 2, 0)
        innerProgressView.frame = CGRect(x: margin, y: innerY, width: innerWidth, height: innerHeight)
        innerProgressView.layer.cornerRadius = innerHeight / 2
    }
    
    func animateProgress(to value: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.progress = value
            self.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
}
