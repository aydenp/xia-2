//
//  XARFile.swift
//  xia-2
//
//  Created by Ayden Panhuyzen on 2020-10-22.
//

import Foundation
import XMLCoder

struct XARFile {
    private let dr: DataReadable
    private let header: Header, tableOfContents: TableOfContents

    private init?(_ dr: DataReadable) {
        self.dr = dr
        guard let header = Header(dr) else { return nil }
        self.header = header

        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let tocData = dr.read(range: UInt(header.headerSize) ..< UInt(header.headerSize) + UInt(header.tableOfContentsCompressedLength))?.zlibDecompressed,
              tocData.count == header.tableOfContentsLength,
              let tableOfContents = try? decoder.decode(TableOfContentsRoot.self, from: tocData) else { return nil }
        self.tableOfContents = tableOfContents.toc
    }

    init?(data: Data) {
        self.init(data)
    }

    init?(contentsOf url: URL) throws {
        self.init(try FileHandle(forReadingFrom: url))
    }

    var files: [File] {
        return tableOfContents.files
    }

    func readArchivedData(file: File) -> Data? {
        return dr.read(range: file.data.archivedRange)
    }
}

// MARK: File Retrival Convenience

extension XARFile {
    func getFile(id: String) -> File? {
        return files.first { $0.id == id }
    }

    func getFile(named name: String) -> File? {
        return files.first { $0.name == name }
    }
}

// MARK: - File Header

extension XARFile {
    struct Header {
        let headerSize: UInt16, version: UInt16, tableOfContentsCompressedLength: UInt64, tableOfContentsLength: UInt64, checksumAlgorithm: ChecksumAlgorithm

        enum ChecksumAlgorithm: UInt32 {
            case none = 0, sha1, md5, sha256, sha512
        }

        fileprivate init?(_ dr: DataReadable) {
            guard let size = dr.read(UInt16.self, from: 4)?.bigEndian,
                  let version = dr.read(UInt16.self, from: 6)?.bigEndian,
                  let comTocLength = dr.read(UInt64.self, from: 8)?.bigEndian,
                  let tocLength = dr.read(UInt64.self, from: 16)?.bigEndian,
                  let checksumAlgorithm = dr.read(ChecksumAlgorithm.RawValue.self, from: 24)
                        .flatMap({ ChecksumAlgorithm(rawValue: $0.bigEndian) }) else { return nil }
            self.headerSize = size
            self.version = version
            self.tableOfContentsCompressedLength = comTocLength
            self.tableOfContentsLength = tocLength
            self.checksumAlgorithm = checksumAlgorithm
        }
    }
}

// MARK: - Table of Contents

extension XARFile {
    fileprivate struct TableOfContentsRoot: Decodable {
        let toc: TableOfContents
    }

    fileprivate struct TableOfContents: Decodable {
        let files: [File]

        enum CodingKeys: String, CodingKey {
            case files = "file"
        }
    }

    struct File: Decodable {
        let id: String
        let name: String
        let type: FileType
        let gid: Int, uid: Int
        let user: String, group: String
        let mode: String
        let creationDate: Date, modificationDate: Date, addDate: Date
        let data: FileData
        let containedFiles: [File]

        enum FileType: String, Decodable {
            case file, directory
        }

        struct FileData: Decodable {
            /// The full size of the file
            let size: UInt
            /// The archived length of this file's data inside the XAR
            let length: UInt
            /// The offset that this file starts at inside the XAR.
            let offset: UInt

            var archivedRange: Range<UInt> {
                return offset ..< offset + length
            }

            let encoding: Encoding

            struct Encoding: Decodable {
                let style: String
            }
        }

        enum CodingKeys: String, CodingKey {
            case id, name, type, gid, uid, user, group, mode, data
            case creationDate = "ctime", modificationDate = "mtime", addDate = "atime"
            case containedFiles = "file"
        }
    }
}
