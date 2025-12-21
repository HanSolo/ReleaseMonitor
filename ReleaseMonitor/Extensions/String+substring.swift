//
//  String+substring.swift
//  JavaUpdater
//
//  Created by Gerrit Grunwald on 20.02.24.
//

import Foundation


extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex : Index = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex : Index = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex : Index = index(from: r.lowerBound)
        let endIndex   : Index = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }

    func substring(with r: Range<Index>) -> String {
        return String(self[r.lowerBound..<r.upperBound])
    }
    
    func indexOf(with: Character) -> Int {
        if let i = self.firstIndex(of: with) {
            return self.distance(from: self.startIndex, to: i)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(with: Character) -> Int {        
        if let i = self.lastIndex(of: with) {
            return self.distance(from: self.startIndex, to: i)
        } else {
            return -1
        }            
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    
    public func replaceFirst(of pattern:String, with replacement:String) -> String {
        if let range = self.range(of: pattern) {
            return self.replacingCharacters(in: range, with: replacement)
        } else {
            return self
        }
    }
      
    public func replaceAll(of pattern:String, with replacement:String, options: NSRegularExpression.Options = []) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(0..<self.utf16.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
        } catch {
            NSLog("replaceAll error: \(error)")
            return self
        }
    }
}
