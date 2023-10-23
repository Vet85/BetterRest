//
//  ContentView.swift
//  BetterRest
//
//  Created by Vitaliy Novichenko on 06.09.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var allertTitle = ""
    @State private var allertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 14
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                Section {
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                   /* Picker("Desired amount of sleep", selection: $sleepAmount) {
                        ForEach(4..<13) {
                            Text("\($0) hours")
                        }
                    }
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)*/
                }
                Section {
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...10)
                    //(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...10)
                } header: {
                    Text("Dayly coffee intake")
                        .font(.headline)
                }
                Section {
                    
                } header: {
                    Text("Your ideal bedtime is \(calculate.formatted(date: .omitted, time: .shortened))")
                        .font(.title3)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(allertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(allertMessage)
            }
        }
    }
    func calculateBedtime () {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            allertTitle = "Your ideal bedtime is ..."
            allertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            allertTitle = "Error"
            allertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
    var calculate: Date {
        var amount = Date.now
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            //return sleepTime
            amount = sleepTime
        } catch {
            
        }
        return amount
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
