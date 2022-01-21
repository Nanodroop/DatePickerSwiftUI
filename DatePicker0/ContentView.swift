
import SwiftUI
import UIKit

struct ContentView: View {
    
    
    @State private var showSheet = false
    @State var scaleValue = CGFloat(1)
    @State private var dateRange: ClosedRange<Date>? = nil
    
    var body: some View {
        ZStack{
            
            Button {
                showSheet = true
                
            } label: {
                if let range = dateRange {
                    Text("\(range)")
                } else {
                    let defaultRange = Date()...(Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
                    Text("\(defaultRange)")
                }
            }
            
            ModalView(isShowing: $showSheet)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ModalView: View {
    
    @Binding var isShowing: Bool
    @State private var dateRange: ClosedRange<Date>? = nil
    @State private var curHeight: CGFloat = 400
    let minHeight: CGFloat = 400
    let maxHeight: CGFloat = 700
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            if isShowing {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing = false
                    }
                mainView
                .transition(.move(edge: .bottom))
            }
           
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut)
    }
    
    var mainView: some View {
        VStack {
            ZStack {
                VStack {
                    MultiDatePicker(dateRange: self.$dateRange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 35)
        }
        .frame(height: curHeight)
        .frame(maxWidth: .infinity)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                Rectangle()
                    .frame(height: curHeight / 2)
            }
                .foregroundColor(.white)
        )
    }
}


