//
//  ContentView.swift
//  BetterRest
//
//  Created by Radu Petrisel on 08.07.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    private static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    @State private var wakeUpTime = Self.defaultWakeUpTime
    @State private var desiredSleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    private var estimatedBedtime: Date? {
        calculateBedtime()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time:", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("When do you want to wake up?")
                }
                
                Section {
                    Stepper("\(desiredSleepAmount.formatted()) hours", value: $desiredSleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("How much do you want to sleep?")
                }
                
                Section {
                    Picker("Select # cups for today", selection: $coffeeAmount) {
                        ForEach(1..<21, id: \.self) { number in
                            Text(number == 1 ? "1 cup" : "\(number) cups")
                        }
                    }
                } header: {
                    Text("How much coffee do you drink?")
                }
                
                Section {
                    Text(estimatedBedtime?.formatted(date: .omitted, time: .shortened) ?? "???")
                } header: {
                    Text("Your ideal bedtime is...")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    private func calculateBedtime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let sleepCalculator = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try sleepCalculator.prediction(wake: Double(hour + minute), estimatedSleep: desiredSleepAmount, coffee: Double(coffeeAmount))
            return wakeUpTime - prediction.actualSleep
        } catch {
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
