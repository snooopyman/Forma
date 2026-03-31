//
//  Double+Forma.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

extension Double {
    var asWeight: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? formatted(.number.precision(.fractionLength(0)))
            : formatted(.number.precision(.fractionLength(1)))
    }
}
