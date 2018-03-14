//
//  CalendarViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import CVCalendar

protocol CalendarViewControllerDelegate: class {
    func dateWasSelected(_ date: String)
}

class CalendarViewController: UIViewController, CVCalendarViewDelegate, CVCalendarViewAppearanceDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var borderViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var selectedDate: String = ""
    var navBarHeight: CGFloat = 0.0
    var currentCalendar: Calendar?
    
    weak var delegate: CalendarViewControllerDelegate!
    
    //MARK:- Life cycle
    override func awakeFromNib() {
        self.view.backgroundColor = UIColor().hexStringToUIColor(hexString: "#6F6F6F", alpha: 0.6)
        
        let timeZoneBias = 480
        currentCalendar = Calendar.init(identifier: .gregorian)
        if let timeZone = TimeZone.init(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        borderViewTopConstraint.constant = navBarHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.commitCalendarViewUpdate()
    }

    
    func presentationMode() -> CalendarMode {
        return .weekView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func calendar() -> Calendar? {
        return currentCalendar
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldSelectDayView(_ dayView: DayView) -> Bool {
        return true
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        if selectedDate != "" {
            if delegate != nil {
                delegate.dateWasSelected(selectedDate)
                selectedDate = ""
            }
            self.view.removeAnimation()
        }
    }
    
    func shouldScrollOnOutDayViewSelection() -> Bool {
        return false
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        selectedDate = date.commonDescription
    }
    
    func disableScrollingBeforeDate() -> Date {
        return NSCalendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    func earliestSelectableDate() -> Date {
        return NSCalendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    func latestSelectableDate() -> Date {
        return NSCalendar.current.date(byAdding: .year, value: 1, to: Date())!
    }
    
    //MARK:- CVCalendarViewAppearanceDelegate
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        return UIFont(name: "AppleSDGothicNeo-SemiBold", size: 21)!
    }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _):
            return UIColor().themeColor()
        case (_, .disabled, _):
            return UIColor.gray
        default:
            return .white
            
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        return .white
    }
    
    //MARK:- Private
    func showInView(_ aView: UIView!) {
        aView.addSubview(self.view)
        self.view.showAnimation()
    }

}
