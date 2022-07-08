// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension UICollectionView {
    func registerHeader<T: UICollectionReusableView>(_: T.Type) {
        self.register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: T.identifier
        )
    }

    func registerCell<T: UICollectionViewCell>(_: T.Type) {
        self.register(
            T.self,
            forCellWithReuseIdentifier: T.identifier
        )
    }
}
