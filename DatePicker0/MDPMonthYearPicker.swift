
import SwiftUI

struct MDPMonthYearPicker: View {
    let months = (0...11).map {$0}
    let years = (2022...2032).map {$0}
    
    var date: Date
    var action: (Int, Int) -> Void
    
    @State private var selectedMonth = 0
    @State private var selectedYear = 2020
    
    
    init(date: Date, action: @escaping (Int, Int) -> Void) {
        self.date = date
        self.action = action
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        self._selectedMonth = State(initialValue: month - 1)
        self._selectedYear = State(initialValue: year)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Picker("", selection: self.$selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text("\(Calendar.current.monthSymbols[month])").tag(month)
                }
            }
            .onChange(of: selectedMonth, perform: { value in
                self.action(value + 1, self.selectedYear)
            })
            .frame(width: 150)
            .clipped()
            
            Picker("", selection: self.$selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(format: "%d", year)).tag(year)
                }
            }
            .onChange(of: selectedYear, perform: { value in
                self.action(self.selectedMonth + 1, value)
            })
            .frame(width: 100)
            .clipped()
        }
    }
}

struct MDPMonthYearPickerButton: View {
    @EnvironmentObject var monthDataModel: MDPModel
    
    @Binding var isPresented: Bool
    
    var body: some View {
        Button( action: {withAnimation { isPresented.toggle()} } ) {
            HStack {
                Text(monthDataModel.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(self.isPresented ? .accentColor : .black)
                Image(systemName: "chevron.right")
                    .rotationEffect(self.isPresented ? .degrees(90) : .degrees(0))
            }
        }
    }
}
