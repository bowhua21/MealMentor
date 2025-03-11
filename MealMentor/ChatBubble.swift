//
//  ChatBubble.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 3/5/25.
//
import UIKit

class ChatBubble: UILabel {
    let margins = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabelFields()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLabelFields()
    }
    
    private func initLabelFields() {
        numberOfLines = 0
        layer.cornerRadius = 10
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + CGFloat(margins), height: size.height + CGFloat(margins))
    }
}
