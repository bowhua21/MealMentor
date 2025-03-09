//
//  CalendarPageViewController.swift
//  MealMentor
//
//  Created by Yingting Cao on 3/1/25.
//

import UIKit

class CalendarPageViewController: UIViewController {
    let segueToCalendarPageIdentifier = "SegueToCalendarPageIdentifier"
    let calendarViewColor = UIColor(red: 0.2509, green: 0.4588, blue: 0.1764, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        createCalendar()
        // Do any additional setup after loading the view.
    }
    func createCalendar() {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
        calendarView.layer.cornerRadius = 10
        calendarView.backgroundColor = calendarViewColor
        view.addSubview(calendarView)
        NSLayoutConstraint.activate([calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                                     calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     calendarView.heightAnchor.constraint(equalToConstant: 300),
                                     calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                                     calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        
    }
}
extension CalendarPageViewController: UICalendarViewDelegate {
    func calendarView (_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
    }
    
}
