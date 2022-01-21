

import SwiftUI

struct MultiDatePicker: View {
    
    enum PickerType {
        case dateRange
    }
    
    enum DateSelectionChoices {
        case allDays
        case weekendsOnly
        case weekdaysOnly
    }
    
    @StateObject var monthModel: MDPModel
    
    init(dateRange: Binding<ClosedRange<Date>?>,
         includeDays: DateSelectionChoices = .allDays,
         minDate: Date? = nil,
         maxDate: Date? = nil
    ) {
        _monthModel = StateObject(wrappedValue: MDPModel(dateRange: dateRange, includeDays: includeDays, minDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), maxDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())))
    }
    
    var body: some View {
        MDPMonthView()
            .environmentObject(monthModel)
    }
}

struct MultiDatePicker_Previews: PreviewProvider {
    @State static var dateRange: ClosedRange<Date>? = nil
    
    static var previews: some View {
        ScrollView {
            VStack {
                MultiDatePicker(dateRange: $dateRange)
            }
        }
    }
}

