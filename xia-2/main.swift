//
//  main.swift
//  xia-2
//
//  Created by Ayden Panhuyzen on 2020-10-22.
//

import Foundation

let archive = try! XARFile(contentsOf: URL(fileURLWithPath: "/Users/aydenp/Downloads/Xcode_12.1_GM_seed.xip"))!
let firstFile = archive.files.first!
debugPrint(firstFile, archive.readArchivedData(file: firstFile))
