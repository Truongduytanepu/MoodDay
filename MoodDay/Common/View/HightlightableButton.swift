//
//  HightlightableButton.swift
//  TrumVoiceChange
//
//  Created by Thanh Vu on 18/11/2020.
//

import Foundation
import UIKit

public class HightlightableButton: UIButton {
    @IBInspectable var hightlightAlpha: CGFloat = 0.6
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.animate(alpha: self.hightlightAlpha)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.animate(alpha: 1)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.animate(alpha: 1)
    }

    private func animate(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            self.cornerRadius = isHighlighted ? 4 : 0
            self.backgroundColor = isHighlighted ? .lightGray : .clear
        }
    }
}
