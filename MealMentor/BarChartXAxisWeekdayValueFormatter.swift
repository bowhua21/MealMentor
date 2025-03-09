//
//  BarChartXAxisWeekdayValueFormatter.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/8/25.
//

import Foundation
import DGCharts

// convert double to a weekday
class BarChartXAxisWeekdayValueFormatter: IndexAxisValueFormatter {
    private let daysOfWeek = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        return (index >= 1 && index <= 7) ? daysOfWeek[index] : ""
    }
}
