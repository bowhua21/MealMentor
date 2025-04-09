//
//  ThisWeekDayCell.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/1/25.
//

import UIKit

class ThisWeekDayCell: UICollectionViewCell {
    static let identifier = "ThisWeekDayCell"
    // day of the week label
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var checkMarkIcon: UIImageView!
    
    func configure(with date: Date, isTracked: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // "EEE" for abbreviated weekday name (Mon, Tue, etc.)
        let weekdayName = formatter.string(from: date)
        dayLabel.text = weekdayName  // Set the text as the weekday name
        // change colors if day is tracked or not
        if isTracked {
            contentView.backgroundColor = UIColor(red: 0.2509, green: 0.4588, blue: 0.1764, alpha: 1.0)
            dayLabel.textColor = .white
            checkMarkIcon.tintColor = UIColor(red: 0.7529, green: 0.878, blue: 0.7098, alpha: 1.0)
        }
        else {
            contentView.backgroundColor = .white
            dayLabel.textColor = UIColor(red: 0.2509, green: 0.4588, blue: 0.1764, alpha: 1.0)
            checkMarkIcon.tintColor = .gray
        }
        contentView.layer.cornerRadius = 20
    }
}
