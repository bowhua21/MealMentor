//
//  LoadingIndicatorView.swift
//  MealMentor
//
//  Created by Yingting Cao on 4/9/25.
//

import UIKit

class LoadingIndicatorView: UIView {
    private let circleLayer = CAShapeLayer()
    private let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - 5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        
        // Configure the shape layer
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.systemGray.cgColor
        circleLayer.lineWidth = 4
        circleLayer.lineCap = .round
        circleLayer.strokeEnd = 0.8
        
        layer.addSublayer(circleLayer)
    }
    
    func startAnimating() {
        rotationAnimation.duration = 1
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.repeatCount = .infinity
        layer.add(rotationAnimation, forKey: "rotation")
    }
    
    func stopAnimating() {
        layer.removeAnimation(forKey: "rotation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the path when the view resizes
        let newPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - 5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        circleLayer.path = newPath.cgPath
    }
}
