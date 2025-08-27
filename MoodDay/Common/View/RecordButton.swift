//
//  RecordButton.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 6/18/25.
//

import UIKit

class RecordButton: UIView {
    
    @IBInspectable var progress: CGFloat = 0.0 {
        didSet { setNeedsDisplay() }
    }
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupTap()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTap()
    }
    
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        self.onTap?()
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.width/2, y: rect.height/2)
        let progressLineWidth: CGFloat = 4 // Giảm lại cho nhỏ hơn
        let inset = progressLineWidth / 2

        // Vẽ nền trắng mờ TRƯỚC
        let bgInset = progressLineWidth - 2 // (nếu muốn mỏng nền hơn nữa có thể giảm -2)
        let bgRect = rect.insetBy(dx: bgInset, dy: bgInset)
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.4).cgColor)
        ctx.fillEllipse(in: bgRect)

        // Vẽ arc đỏ SAU
        let radius = min(rect.width, rect.height) / 2 - inset
        let startAngle = -CGFloat.pi/2
        let endAngle = startAngle + progress * 2 * .pi

        ctx.saveGState()
        ctx.setStrokeColor(UIColor(rgb: 0xFF1D1D).cgColor)
        ctx.setLineWidth(progressLineWidth)
        ctx.setLineCap(.round)
        ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        ctx.strokePath()
        ctx.restoreGState()

        // Vẽ hình vuông đỏ giữa nút
        let squareSize: CGFloat = rect.width / 3.2
        let squareRect = CGRect(
            x: center.x - squareSize/2,
            y: center.y - squareSize/2,
            width: squareSize, height: squareSize
        )
        let cornerRadius = squareSize * 0.2
        let roundedSquare = UIBezierPath(roundedRect: squareRect, cornerRadius: cornerRadius)
        UIColor(rgb: 0xFF1D1D).setFill()
        roundedSquare.fill()
    }
}
