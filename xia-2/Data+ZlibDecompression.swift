//
//  ZlibDecompress.swift
//  xia-2
//
//  Created by Ayden Panhuyzen on 2020-10-22.
//

import Foundation
import Compression

/// Credit: https://stackoverflow.com/questions/39648121/native-zlib-inflate-deflate-for-swift3-on-ios
extension Data {
    var zlibDecompressed: Data {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = subdata(in: 2 ..< count).withUnsafeBytes {
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count:read)
        } as Data
        buffer.deallocate()
        return result
    }
}
