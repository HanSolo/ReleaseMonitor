//
//  Date+DayBeforeAfter.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 13.01.25.
//

import Foundation


extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow : Date { return Date().dayAfter }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func isEpochSecondInDate(_ epochSecond: Double) -> Bool {
        let startOfDay : Double = Calendar.current.startOfDay(for: self).timeIntervalSince1970
        let endOfDay   : Double = startOfDay + Constants.SECONDS_PER_DAY
        return (epochSecond >= startOfDay) && (epochSecond < endOfDay)
    }
}
