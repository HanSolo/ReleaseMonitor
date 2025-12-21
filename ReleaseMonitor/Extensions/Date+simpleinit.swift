//
//  Date+simpleinit.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 12.05.25.
//

import Foundation


extension Date {

    /// Create a date from specified parameters
    ///
    /// - Parameters:
    ///   - day    : The desired day
    ///   - month: The desired month
    ///   - year  : The desired year
    /// - Returns: A `Date` object
    static func from(day: Int, month: Int, year: Int) -> Date? {
        let calendar         = Calendar(identifier: .gregorian)
        var dateComponents   = DateComponents()
        dateComponents.day   = day
        dateComponents.month = month
        dateComponents.year  = year
        return calendar.date(from: dateComponents) ?? nil
    }
}
