//
//  Created by Pete Smith
//  http://www.petethedeveloper.com
//
//
//  License
//  Copyright © 2017-present Pete Smith
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

/*
 ScalingCarouselLayout is used together with SPBCarouselView to
 provide a carousel-style collection view.
 */
open class TranslatingCarouselLayout: UICollectionViewFlowLayout {
    
    open var inset: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    var translationY: CGFloat = 8
    
    /// Initialize a new carousel-style layout
    ///
    /// - parameter inset: The carousel inset
    ///
    /// - returns: A new carousel layout instance
    convenience init(withCarouselInset inset: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)) {
        self.init()
        self.inset = inset
        self.translationY = inset.top
    }
    
    override open func prepare() {
        
        guard let collectionViewSize = collectionView?.frame.size else { return }
        
        // Set itemSize based on total width and inset
        itemSize = collectionViewSize
        itemSize.width = itemSize.width - (inset.left + inset.right)
        
        // Set scrollDirection and paging
        scrollDirection = .horizontal
        collectionView?.isPagingEnabled = true
        
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0
        
        sectionInset = self.inset
        footerReferenceSize = CGSize.zero
        headerReferenceSize = CGSize.zero
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }
        return attributes.map(self.translationYLayoutAttributes)
    }
    fileprivate func translationYLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }

        let collectionCenter = collectionView.frame.size.width/2
        let offset = collectionView.contentOffset.x
        let normalizedCenter = attributes.center.x - offset
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter  - self.inset.left), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance

        attributes.zIndex = Int(ratio * 10)

        attributes.frame.origin.y -= ratio * translationY
        
        return attributes
    }
}
