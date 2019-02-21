//
//  NSObject.swift
//  emerald
//
//  Created by 埜原菽也 on 1/7/31 H.
//  Copyright © 31 Heisei M.A. Eng. All rights reserved.
//

import UIKit

extension NSObject {
  func observer(for signal: NSNotification.Name, function selector: Selector) {
    NotificationCenter.default.addObserver(self, selector: selector, name: signal, object: nil)
  }

  func releaseObservers() {
    NotificationCenter.default.removeObserver(self)
  }

  func async(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
  }
}
