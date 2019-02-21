//
//  ResourcesDatasource.swift
//  emerald
//
//  Created by 埜原菽也 on 1/16/31 H.
//  Copyright © 31 Heisei M.A. Eng. All rights reserved.
//

import UIKit

class ResourcesDatasource: NSObject {

  let reuseIdentifier = "ResourcesCollectionViewCell"
  let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  let itemsPerRow: CGFloat = 3
  var resources: [Int] //[BTResource]

  override init() {
    resources = []
  }

//  func add(_ resource: BTResource) {
//    resources.append(resource)
//  }

  func add() {
    resources.append(10)
  }

  func remove(_ index: Int) {
    resources.remove(at: index)
  }

  func count() -> Int {
    return resources.count
  }
  
}

// EXTENSION
extension ResourcesDatasource: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2 + resources.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ResourcesCollectionViewCell
    return cell
  }

}

// MARK: - Collection View Flow Layout Delegate
extension ResourcesDatasource : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = collectionView.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow

    return CGSize(width: widthPerItem, height: widthPerItem)
  }

  //3
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
