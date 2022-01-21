

import SwiftUI

struct MDPDayOfMonth {
    var index = 0
    var day = 0
    var date: Date? = nil
    var isSelectable = false
    var isToday = false
}

class MDPModel: NSObject, ObservableObject {
    
    public var controlDate: Date = Date() {
        didSet {
            buildDays()
        }
    }

    @Published var days = [MDPDayOfMonth]()
    @Published var title = ""
    @Published var selections = [Date]()
    
    let dayNames = Calendar.current.shortWeekdaySymbols
    private var dateRangeWrapper: Binding<ClosedRange<Date>?>?
    private var minDate: Date? = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    private var maxDate: Date? = Calendar.current.date(byAdding: .day, value: 3, to: Date())
    private var pickerType: MultiDatePicker.PickerType = .dateRange
    private var selectionType: MultiDatePicker.DateSelectionChoices = .allDays
    private var numDays = 0
    
    // MARK: - INIT
    
    convenience init(dateRange: Binding<ClosedRange<Date>?>,
                     includeDays: MultiDatePicker.DateSelectionChoices,
                     minDate: Date?,
                     maxDate: Date?) {
        self.init()
        self.dateRangeWrapper = dateRange
        self.selectionType = includeDays
        self.minDate = minDate
        self.maxDate = maxDate
        setSelection(dateRange.wrappedValue)
        if let dateRange = dateRange.wrappedValue {
            controlDate = dateRange.lowerBound
        }
        buildDays()
    }
    
    // MARK: - PUBLIC
    
    func dayOfMonth(byDay: Int) -> MDPDayOfMonth? {
        guard 1 <= byDay && byDay <= 31 else { return nil }
        for dom in days {
            if dom.day == byDay {
                return dom
            }
        }
        return nil
    }
    
    func selectDay(_ day: MDPDayOfMonth) {
        guard day.isSelectable else { return }
        guard let date = day.date else { return }
        
        switch pickerType {
        default:
            if selections.count != 1 {
                selections = [date]
            } else {
                selections.append(date)
            }
            selections.sort()
            if selections.count == 2 {
                dateRangeWrapper?.wrappedValue = selections[0]...selections[1]
            } else {
                dateRangeWrapper?.wrappedValue = nil
            }
        }
    }
    
    func isSelected(_ day: MDPDayOfMonth) -> Bool {
        guard day.isSelectable else { return false }
        guard let date = day.date else { return false }
        
        if selections.count == 0 {
            
            
            return false
            
        } else if selections.count == 1 {
            return isSameDay(date1: selections[0], date2: date)
            
        } else {
            
            if selections[1] == selections[0] {
                return false
            }
            
            let range14day = selections[0]...(Calendar.current.date(byAdding: .day, value: 14, to: selections[0]) ?? selections[0])
            
            if range14day.contains(selections[1]) {
                let range = selections[0]...selections[1]
                return range.contains(date)
                
            } else {
                return range14day.contains(date)
            }
        }
    }
    
    func incrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: controlDate) {
            controlDate = newDate
        }
    }
    
    func decrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: controlDate) {
            controlDate = newDate
        }
    }
    
    func show(month: Int, year: Int) {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        if let newDate = calendar.date(from: components) {
            controlDate = newDate
        }
    }
    
}

// MARK: - BUILD DAYS

extension MDPModel {
    
    private func buildDays() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: controlDate)
        let month = calendar.component(.month, from: controlDate)
        
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        let ord = calendar.component(.weekday, from: date)
        var index = 0
        
        let today = Date()
        
        var daysArray = [MDPDayOfMonth]()
        
        for _ in 1..<ord {
            daysArray.append(MDPDayOfMonth(index: index, day: 0))
            index += 1
        }
        
        for i in 0..<numDays {
            let realDate = calendar.date(from: DateComponents(year: year, month: month, day: i+1))
            var dom = MDPDayOfMonth(index: index, day: i+1, date: realDate)
            dom.isToday = isSameDay(date1: today, date2: realDate)
            dom.isSelectable = isEligible(date: realDate)
            daysArray.append(dom)
            index += 1
        }
        
        let total = daysArray.count
        var remainder = 42 - total
        if remainder < 0 {
            remainder = 42 - total
        }
        
        for _ in 0..<remainder {
            daysArray.append(MDPDayOfMonth(index: index, day: 0))
            index += 1
        }
        
        self.numDays = numDays
        self.title = "\(calendar.monthSymbols[month-1]) \(year)"
        self.days = daysArray
    }
}

// MARK: - UTILITIES

extension MDPModel {
    
    private func setSelection(_ dateRange: ClosedRange<Date>?) {
        pickerType = .dateRange
        if let dateRange = dateRange {
            selections = [dateRange.lowerBound, dateRange.upperBound]
        }
    }
    
    private func isSameDay(date1: Date?, date2: Date?) -> Bool {
        guard let date1 = date1, let date2 = date2 else { return false }
        let day1 = Calendar.current.component(.day, from: date1)
        let day2 = Calendar.current.component(.day, from: date2)
        let year1 = Calendar.current.component(.year, from: date1)
        let year2 = Calendar.current.component(.year, from: date2)
        let month1 = Calendar.current.component(.month, from: date1)
        let month2 = Calendar.current.component(.month, from: date2)
        return (day1 == day2) && (month1 == month2) && (year1 == year2)
    }
    
    private func isEligible(date: Date?) -> Bool {
        guard let date = date else { return true }
        
        if let minDate = minDate, let maxDate = maxDate {
            return (minDate...maxDate).contains(date)
        } else if let minDate = minDate {
            return date >= minDate
        } else if let maxDate = maxDate {
            return date <= maxDate
        }
        
        switch selectionType {
        case .weekendsOnly:
            let ord = Calendar.current.component(.weekday, from: date)
            return ord == 1 || ord == 7
        case .weekdaysOnly:
            let ord = Calendar.current.component(.weekday, from: date)
            return 1 < ord && ord < 7
        default:
            return true
        }
    }
}
