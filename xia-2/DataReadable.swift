//
//  DataReadable.swift
//  xia-2
//
//  Created by Ayden Panhuyzen on 2020-10-22.
//

import Foundation

protocol DataReadable {
    func read(range: Range<UInt>) -> Data?
}

extension Data: DataReadable {
    func read(range: Range<UInt>) -> Data? {
        return self[range]
    }
}

extension FileHandle: DataReadable {
    func read(range: Range<UInt>) -> Data? {
        do {
            try seek(toOffset: UInt64(range.lowerBound))
            return readData(ofLength: Int(range.upperBound - range.lowerBound))
        } catch {
            return nil
        }
    }
}
