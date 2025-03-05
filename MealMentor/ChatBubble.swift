//
//  ChatBubble.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 3/5/25.
//
import UIKit

class ChatBubble: UILabel {
    var textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
