//
//  LineChartXAxisMonthFormatter.swift
//  MealMentor
//
//  Created by Gina Jeon on 4/15/25.
//

import Foundation
import DGCharts

class LineChartXAxisMonthFormatter: IndexAxisValueFormatter {
    private let months = ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"]
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value.rounded()) - 1
        guard index >= 0 && index < months.count else { return "" }
        return months[index]
    }
}
