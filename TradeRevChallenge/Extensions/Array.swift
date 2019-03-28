//
//  Array.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 27/03/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
