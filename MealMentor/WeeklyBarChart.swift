//
//  WeeklyBarChart.swift
//  MealMentor
//
//  Created by Gina Jeon on 4/12/25.
//

import Foundation
import DGCharts
import UIKit

// make the bar chart view
public func makeBaseBarChartView() -> BarChartView {
    let chartView = BarChartView()
    chartView.backgroundColor = .clear
    chartView.rightAxis.enabled = false
    chartView.leftAxis.axisMinimum = 0
    chartView.leftAxis.drawGridLinesEnabled = false
    chartView.leftAxis.enabled = false
    chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
    chartView.xAxis.granularity = 1
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.axisMinimum = 0.5
    chartView.xAxis.axisMaximum = 7.5
    chartView.xAxis.labelCount = 7
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.labelTextColor = .black
    chartView.legend.enabled = false
    return chartView
}

// set data for the bar charts
func setBarChartData(nutritionData: [BarChartDataEntry], label: String, unit: String, barChartView: BarChartView) {
    let set = BarChartDataSet(entries: nutritionData, label: label)
    set.valueFormatter = BarChartYValueUnitValueFormatter(unit: unit)
    set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
    set.valueTextColor = .black
    let data = BarChartData(dataSet: set)
    barChartView.data = data
}
