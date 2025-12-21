//
//  Dictionary+Index.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 17.01.25.
//

import Foundation


extension Dictionary {
    subscript(i:Int) -> (key: Key, value: Value) {
        get {
            return self[index(startIndex, offsetBy: i)]
        }
    }
}
