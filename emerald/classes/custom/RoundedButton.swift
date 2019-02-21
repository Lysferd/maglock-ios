//
//  RoundedButton.swift
//  emerald
//
//  Created by 埜原菽也 on 1/15/31 H.
//  Copyright © 31 Heisei M.A. Eng. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

  func centerVertically(padding: CGFloat = 6.0) {
    guard
      let imageViewSize = self.imageView?.frame.size,
      let titleLabelSize = self.titleLabel?.frame.size else {
        return
    }

    let totalHeight = imageViewSize.height + titleLabelSize.height + padding

    self.imageEdgeInsets = UIEdgeInsets(
      top: -(totalHeight - imageViewSize.height),
      left: 0.0,
      bottom: 0.0,
      right: -titleLabelSize.width
    )

    self.titleEdgeInsets = UIEdgeInsets(
      top: 0.0,
      left: -imageViewSize.width,
      bottom: -(totalHeight - titleLabelSize.height),
      right: 0.0
    )

    self.contentEdgeInsets = UIEdgeInsets(
      top: 0.0,
      left: 0.0,
      bottom: titleLabelSize.height,
      right: 0.0
    )
  }

  override func draw(_ rect: CGRect) {
    self.layer.cornerRadius = 0.5 * self.bounds.size.width
    self.layer.borderWidth = 1
    self.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    self.layer.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    self.clipsToBounds = true
  }


}
