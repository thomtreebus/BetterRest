//
//  ContentView.swift
//  BetterRest
//
//  Created by Thom Treebus on 14/06/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date { // static so it belongs to ContentView struct, not any specific instance
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("Daily coffee intake", selection: $coffeeAmount) {
                        ForEach(1..<21) { number in
                            Text("\(number) cups")
                        }
                    }
//                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .padding()
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration() // config to enable different options (don't need to touch)
            let model = try SleepCalculator(configuration: config) // can fail, hence use do/catch
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60  // optional, (default to midnight) and convert from seconds to hours
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep // calculate actual time to go to sleep
            alertTitle = "Your ideal bedtinme is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
