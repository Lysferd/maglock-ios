//
//  ViewController.swift
//  emerald
//
//  Created by 埜原菽也 on 10/2/30 H.
//  Copyright © 30 Heisei M.A. Eng. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

  @IBOutlet weak var collection: UICollectionView!
  let hapticSelection = UISelectionFeedbackGenerator()

  var bt: BTDiscovery
  var datasource: ResourcesDatasource

  required init?(coder aDecoder: NSCoder) {
    datasource = ResourcesDatasource()
    bt = BTDiscovery()
    bt.datasource = datasource

    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
//    observer(for: BLENotifyConnected, function: #selector(observe_connected))

    collection.dataSource = datasource

    super.viewDidLoad()
  }

  @IBAction func touchAdd(_ sender: UIButton) {
    datasource.add()
    let index = IndexPath(row: datasource.count(), section: 0)
    collection.insertItems(at: [index])
    NSLog("Adding")
  }

}
