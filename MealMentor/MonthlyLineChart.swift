//
//  MonthlyLineChart.swift
//  MealMentor
//
//  Created by Gina Jeon on 4/15/25.
//

import Foundation
import DGCharts
import UIKit

// fake data for monthly tracking
let dummyMonthlyProteinDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 48.0),
    ChartDataEntry(x: 2.0, y: 45.0),
    ChartDataEntry(x: 3.0, y: 30.0),
    ChartDataEntry(x: 4.0, y: 48.0),
    ChartDataEntry(x: 5.0, y: 39.0),
    ChartDataEntry(x: 6.0, y: 40.0),
]
let dummyMonthlyCaloriesDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 2300.0),
    ChartDataEntry(x: 2.0, y: 1990.0),
    ChartDataEntry(x: 3.0, y: 2500.0),
    ChartDataEntry(x: 4.0, y: 2450.0),
    ChartDataEntry(x: 5.0, y: 2340.0),
    ChartDataEntry(x: 6.0, y: 2190.0),
]
let dummyMonthlyCarbsDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 200.0),
    ChartDataEntry(x: 2.0, y: 195.0),
    ChartDataEntry(x: 3.0, y: 250.0),
    ChartDataEntry(x: 4.0, y: 245.0),
    ChartDataEntry(x: 5.0, y: 199.0),
    ChartDataEntry(x: 6.0, y: 224.0),
]
let dummyMonthlyFatDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 42.0),
    ChartDataEntry(x: 2.0, y: 30.0),
    ChartDataEntry(x: 3.0, y: 59.0),
    ChartDataEntry(x: 4.0, y: 60.0),
    ChartDataEntry(x: 5.0, y: 48.0),
    ChartDataEntry(x: 6.0, y: 55.0),
]
let dummyMonthlyFiberDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 15.0),
    ChartDataEntry(x: 2.0, y: 23.0),
    ChartDataEntry(x: 3.0, y: 25.0),
    ChartDataEntry(x: 4.0, y: 32.0),
    ChartDataEntry(x: 5.0, y: 12.0),
    ChartDataEntry(x: 6.0, y: 19.0),
]
let dummyMonthlyVitADataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 90.0),
    ChartDataEntry(x: 2.0, y: 75.0),
    ChartDataEntry(x: 3.0, y: 115.0),
    ChartDataEntry(x: 4.0, y: 120.0),
    ChartDataEntry(x: 5.0, y: 67.0),
    ChartDataEntry(x: 6.0, y: 84.0),
]
let dummyMonthlyVitCDataPts: [ChartDataEntry] = [
    ChartDataEntry(x: 1.0, y: 45.0),
    ChartDataEntry(x: 2.0, y: 67.0),
    ChartDataEntry(x: 3.0, y: 48.0),
    ChartDataEntry(x: 4.0, y: 71.0),
    ChartDataEntry(x: 5.0, y: 62.0),
    ChartDataEntry(x: 6.0, y: 50.0),
]



// make line chart view
public func makeBaseLineChartView() -> LineChartView {
    let chartView = LineChartView()
    chartView.backgroundColor = .clear
    chartView.rightAxis.enabled = false
    chartView.leftAxis.axisMinimum = 0
    chartView.leftAxis.drawGridLinesEnabled = false
    chartView.leftAxis.labelTextColor = .black
    chartView.leftAxis.enabled = true
    chartView.xAxis.valueFormatter = LineChartXAxisMonthFormatter()
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.granularity = 1
    chartView.xAxis.labelCount = 6
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.labelTextColor = .black
    chartView.legend.enabled = false
    chartView.chartDescription.enabled = false

    return chartView
}

// set data for the bar charts
func setLineChartData(nutritionData: [ChartDataEntry], label: String, unit: String, lineChartView: LineChartView) {
    let set = LineChartDataSet(entries: nutritionData, label: label)
    set.valueFormatter = BarChartYValueUnitValueFormatter(unit: unit)
    set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
    set.valueTextColor = .black
    set.circleColors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
    let data = LineChartData(dataSet: set)
    lineChartView.data = data
}
