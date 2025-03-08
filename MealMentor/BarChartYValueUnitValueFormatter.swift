//
//  BarChartYValueGramsValueFormatter.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/8/25.
//

import Foundation
import DGCharts

// convert double to string: integer with unit label (40.0 -> "40g")
class BarChartYValueUnitValueFormatter: ValueFormatter {
    private let unit: String
        
    init(unit: String) {
        self.unit = unit
    }
    func stringForValue(_ value: Double, entry: DGCharts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: DGCharts.ViewPortHandler?) -> String {
        return "\(Int(value))\(unit)"
    }
}
