//
//  Existen.swift
//  Biu
//
//  Created by whoami on 2024/3/7.
//

import Foundation
import SwiftUI

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
