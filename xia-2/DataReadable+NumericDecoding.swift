//
//  DataReadable+NumericDecoding.swift
//  xia-2
//
//  Created by Ayden Panhuyzen on 2020-10-22.
//

import Foundation

extension DataReadable {
    func read<T: Numeric>(_ type: T.Type, from offset: UInt) -> T? {
        let data = read(range: offset ..< offset + UInt(MemoryLayout<T.Type>.size))
        return data?.withUnsafeBytes { $0.load(as: T.self) }
    }
}
