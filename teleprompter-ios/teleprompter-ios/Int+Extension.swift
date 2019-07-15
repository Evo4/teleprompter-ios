//
//  Int+Extension.swift
//  teleprompter-ios
//
//  Created by Tymofii Dolenko on 10/13/18.
//  Copyright © 2018 Вячеслав. All rights reserved.
//

import Foundation
extension Int {
    var array: [String] {
        return String(self).compactMap{ String($0) }
    }
}
