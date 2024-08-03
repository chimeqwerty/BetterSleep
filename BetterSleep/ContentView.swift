//
//  ContentView.swift
//  BetterSleep
//
//  Created by Jan Halas on 20.7.2024.
//

import CoreML
import SwiftUI

//sovellus, joka laskee CoreML:ää hyödyntäen paljonko unta tarvitaan.

//Muuttujina käytetään:

// heräämisaika
// nukuttu tuntimäärä
// juotu kahvin määrä (kupit)


struct ContentView: View {
    
    @State private var wakeUp = wakeUpDefaultTime
    @State private var sleepHours = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var wakeUpDefaultTime: Date {
        
        var timeComponents = DateComponents()
        timeComponents.hour = 7
        timeComponents.minute = 0
        
        return Calendar.current.date(from: timeComponents) ?? .now
    }
    
    
    var calculateBedTime: String {
        
        do {
        let config = MLModelConfiguration()
        let model = try SleepModel(configuration: config)
        
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hours = (timeComponents.hour ?? 0) * 60 * 60
        let minutes = (timeComponents.minute ?? 0) * 60
        
        let prediction = try model.prediction(wake: Double(hours+minutes), estimatedSleep: Double(sleepHours), coffee: Double(coffeeAmount))
        
        let sleepTimeEstimate = wakeUp - prediction.actualSleep
        
            return sleepTimeEstimate.formatted(date: .omitted, time: .shortened)
           
        
    } catch {
        
        alertMessage = "Error ocurred when calculating optimal bedtime"
    }
    return alertMessage
 
        
    }

    
    var body: some View {
        
        
        NavigationStack {
            
            Form {
                VStack {
                    Text("When do you want to wake up? ")
                        .font(.headline)
                    
                    DatePicker("Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepHours.formatted()) h", value: $sleepHours, in: 4...12, step: 0.25)
                }
                
                VStack {
                    Text("How many cups of coffee you drink per day?")
                        .font(.headline)
                    
                  //  Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...8)
                    
                 
                    Picker("Select amount", selection: $coffeeAmount) {
                        ForEach(0..<9) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
            }
            Form {
                VStack {
                    Text ("You should go to sleep at")
                        .padding()
                    Text("\(calculateBedTime)")
                        .font(.system(size: 25, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }
            .navigationTitle("BetterSleep")
  /*          .toolbar {
                Button("Calculate", action: calculateBedtime)
                
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
                
            } message: {
                Text(alertMessage)
            } */
        }
    }
/*    func calculateBedtime() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepModel(configuration: config)
            
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hours = (timeComponents.hour ?? 0) * 60 * 60
            let minutes = (timeComponents.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hours+minutes), estimatedSleep: Double(sleepHours), coffee: Double(coffeeAmount))
            
            let sleepTimeEstimate = wakeUp - prediction.actualSleep
            
            alertTitle = "Best bedtime for you is..."
            alertMessage = sleepTimeEstimate.formatted(date: .omitted, time: .shortened)
       
        } catch {
            alertTitle = "Error"
            alertMessage = "Error ocurred when calculating optimal bedtime"
            }
        showingAlert = true
        } */
    }

                       

#Preview {
    ContentView()
}
