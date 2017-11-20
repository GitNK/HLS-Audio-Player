//
//  Data+writeToFile.swift
//  HLS Audio Player
//
//  Created by nk on 11/20/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
