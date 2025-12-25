//
//  JDKUpdate.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 23.12.25.
//

import Foundation


public struct JDKUpdate : Hashable, Identifiable {
    public let id    : String
    let date         : Date
    let remainingDays: Int
    let type         : Constants.UpdateType
    
    
    init(date: Date, remainingDays: Int, type: Constants.UpdateType) {
        self.id            = UUID().uuidString
        self.date          = date
        self.remainingDays = remainingDays
        self.type          = type
    }
    
    
    public func getRemainingDaysText() -> String {
        let calendar: Calendar = Calendar.current
        if calendar.isDateInToday(self.date) {
            return "today"
        } else if calendar.isDateInTomorrow(self.date) {
            return "tomorrow"
        } else {
            return "in \(self.remainingDays) days"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
