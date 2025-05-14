//
//  RoundPageControl.swift
//  ChargingAnimation
//
//  Created by BemBoy on 5/18/23.
//

import UIKit

private class RoundItemPageControl: UIView {
    func selected() {
        self.backgroundColor = .white
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.layoutIfNeeded()
    }
    
    func unselected() {
        self.backgroundColor = UIColor(rgb: 0xD8D8D8)
        self.transform = CGAffineTransform(scaleX: 7.0/9.0, y: 7.0/9.0)
        self.layoutIfNeeded()
    }
}

class RoundPageControl: UIView {
    private var stackView: UIStackView!
    
    var count: Int = 3 {
        didSet {
            self.buildStackView()
        }
    }

    var current: Int = 0 {
        didSet {
            self.refresh()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.stackView.arrangedSubviews.forEach {
            $0.layoutIfNeeded()
            $0.cornerRadius = $0.bounds.height/2
        }
    }
    
    func commonInit() {
        self.stackView = UIStackView()
        self.stackView.axis = .horizontal
        self.stackView.backgroundColor = .clear
        self.stackView.spacing = 5
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.buildStackView()
    }
    
    func buildStackView() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in 0 ..< self.count {
            let itemView = RoundItemPageControl()
            itemView.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview(itemView)
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor),
                itemView.topAnchor.constraint(equalTo: self.stackView.topAnchor),
                itemView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor)
            ])
            
            UIView.animate(withDuration: 0.25) {
                if index == self.current {
                    itemView.selected()
                } else {
                    itemView.unselected()
                }
            }
        }
    }
    
    func refresh() {
        self.stackView.arrangedSubviews.enumerated().forEach { iterator in
            UIView.animate(withDuration: 0.25) {
                if iterator.offset == self.current {
                    (iterator.element as? RoundItemPageControl)?.selected()
                } else {
                    (iterator.element as? RoundItemPageControl)?.unselected()
                }
            }
        }
    }
}
