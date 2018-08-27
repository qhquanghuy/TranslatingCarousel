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
 This cell subclass is intended to be used together with ScalingCarouselView
 
 This class adds a method used to scale the cell
 in relation to the cell's position in the top level window.
 
 Collection view cells used with ScalingCarouselView should subclass this type
 */
open class TranslatingCarouselCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    // This property should be connected to the main cell subview
    @IBOutlet public var mainView: UIView!
    
    // MARK: - Overrides
    
    


}
