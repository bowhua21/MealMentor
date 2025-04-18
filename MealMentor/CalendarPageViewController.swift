import UIKit

class CalendarPageViewController: UIViewController, UICalendarSelectionSingleDateDelegate {
    
    let calendarViewColor = UIColor(red: 0.776, green: 0.878, blue: 0.745, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
    }
    
    private func setupCalendar() {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendarView.layer.cornerRadius = 12
        calendarView.backgroundColor = calendarViewColor
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                      didSelectDate dateComponents: DateComponents?) {
        guard let date = dateComponents?.date else { return }
        showLogHistory(for: date)
    }
    
    private func showLogHistory(for date: Date) {
        let logHistoryVC = LogHistoryViewController()
        logHistoryVC.selectedDate = date
        present(logHistoryVC, animated: true)
    }
}
