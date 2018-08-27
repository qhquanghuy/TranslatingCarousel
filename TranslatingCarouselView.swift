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
 ScalingCarouselView is a subclass of UICollectionView which
 is intended to be used to carousel through cells which don't
 extend to the edges of a screen. The previous and subsequent cells
 are scaled as the carousel scrolls.
 */
open class TranslatingCarouselView: UICollectionView {
    
    // MARK: - Properties (Public)
    
    /// Inset of the main, center cell
    @IBInspectable public var inset: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) {
        didSet {
            /*
             Configure our layout, and add more
             constraints to our invisible UIScrollView
            */
            configureLayout()
        }
    }
    
    fileprivate var _lastXOffset: CGFloat = CGFloat()
    var centerCellIndex: IndexPath = IndexPath.init(row: 0, section: 0)
    
    /// Override of the collection view content size to add an observer
    override open var contentSize: CGSize {
        didSet {
            
            guard let dataSource = dataSource,
                let invisibleScrollView = invisibleScrollView else { return }
            
            let numberSections = dataSource.numberOfSections?(in: self) ?? 1
            
            // Calculate total number of items in collection view
            var numberItems = 0
            
            for i in 0..<numberSections {
                
                let numberSectionItems = dataSource.collectionView(self, numberOfItemsInSection: i)
                numberItems += numberSectionItems
            }
            
            // Set the invisibleScrollView contentSize width based on number of items
            let contentWidth = invisibleScrollView.frame.width * CGFloat(numberItems)
            invisibleScrollView.contentSize = CGSize(width: contentWidth, height: invisibleScrollView.frame.height)
        }
    }
    
    // MARK: - Properties (Private)
    fileprivate var invisibleScrollView: UIScrollView!
    fileprivate var invisibleWidthConstraint: NSLayoutConstraint?
    fileprivate var invisibleLeftConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Convenience initializer allowing setting of the carousel inset
    ///
    /// - Parameters:
    ///   - frame: Frame
    ///   - inset: Inset
    public convenience init(withFrame frame: CGRect, andInset inset: UIEdgeInsets) {
        self.init(frame: frame, collectionViewLayout: TranslatingCarouselLayout(withCarouselInset: inset))
        
        self.inset = inset
    }
    
    // MARK: - Overrides
    
    override open func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        invisibleScrollView.setContentOffset(rect.origin, animated: animated)
    }
    
    override open func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        
        if indexPath == self.centerCellIndex {
            return
        }
        
//        super.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        
        let originX = (CGFloat(indexPath.item) * (frame.size.width - (inset.left + inset.right)))
        let rect = CGRect(x: originX, y: 0, width: frame.size.width - (inset.left + inset.right), height: frame.height)
        scrollRectToVisible(rect, animated: animated)
        self.centerCellIndex = indexPath
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        addInvisibleScrollView(to: superview)
    }
    
    
    func relayout() {
        let inset = self.inset
        self.inset = inset
        
    }
    
    
    // MARK: - Public API
    
    /*
     This method should ALWAYS be called from the ScalingCarousel delegate when
     the UIScrollViewDelegate scrollViewDidScroll(_:) method is called
     
     e.g In the ScalingCarousel delegate, implement:
     
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carousel.didScroll()
     }
    */
//    public func didScroll() {
//        scrollViewDidScroll(self)
//    }
}

private typealias PrivateAPI = TranslatingCarouselView
fileprivate extension PrivateAPI {
    
    fileprivate func addInvisibleScrollView(to superview: UIView?) {
        guard let superview = superview else { return }
        
        /// Add our 'invisible' scrollview
        invisibleScrollView = UIScrollView(frame: bounds)
        invisibleScrollView.translatesAutoresizingMaskIntoConstraints = false
        invisibleScrollView.isPagingEnabled = true
        invisibleScrollView.showsHorizontalScrollIndicator = false
        /*
         Disable user interaction on the 'invisible' scrollview,
         This means touch events will fall through to the underlying UICollectionView
         */
        invisibleScrollView.isUserInteractionEnabled = false
        
        /// Set the scroll delegate to be the ScalingCarouselView
        invisibleScrollView.delegate = self
        
        /*
         Now add the invisible scrollview's pan 
         gesture recognizer to the ScalingCarouselView
         */
        self.removeGestureRecognizer(self.panGestureRecognizer)
        addGestureRecognizer(invisibleScrollView.panGestureRecognizer)
        
        /*
         Finally, add the 'invisible' scrollview as a subview 
         of the ScalingCarousel's superview
        */
        superview.addSubview(invisibleScrollView)
        
        /*
         Add constraints for height and top, relative to the
         ScalingCarouselView
        */
        invisibleScrollView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        invisibleScrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        /*
         Further configure our layout and add more constraints
         for width and left position
        */
        configureLayout()
    }
    
    fileprivate func configureLayout() {
        
        // Create a ScalingCarouselLayout using our inset
        collectionViewLayout = TranslatingCarouselLayout(withCarouselInset: inset)
        
        /*
         Only continue if we have a reference to
         our 'invisible' UIScrollView
        */
        guard let invisibleScrollView = invisibleScrollView else { return }
    
        // Remove constraints if they already exist
        invisibleWidthConstraint?.isActive = false
        invisibleLeftConstraint?.isActive = false
        
        /* 
         Add constrants for width and left postion 
         to our 'invisible' UIScrollView
        */
        invisibleWidthConstraint = invisibleScrollView.widthAnchor.constraint(
            equalTo: widthAnchor, constant: -(inset.left + inset.right))
        invisibleLeftConstraint =  invisibleScrollView.leftAnchor.constraint(
            equalTo: leftAnchor, constant: inset.left)
        
        // Activate the constraints
        invisibleWidthConstraint?.isActive = true
        invisibleLeftConstraint?.isActive = true
    }
}

/*
 Scroll view delegate extension used to respond to scrolling of the invisible scrollView
 */
private typealias InvisibleScrollDelegate = TranslatingCarouselView
extension InvisibleScrollDelegate: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*
         Move the ScalingCarousel base d on the
         contentOffset of the 'invisible' UIScrollView
        */
        updateOffSet()
        self._lastXOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(self)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateOffSet()
        guard let currentIndexPath = self.indexPathForItem(at: CGPoint.init(x: scrollView.contentOffset.x + self.inset.left, y: scrollView.contentOffset.y)) else { return }
        self.centerCellIndex = currentIndexPath
        delegate?.scrollViewDidEndDecelerating?(self)
        
    }
    
    private func updateOffSet() {
        contentOffset = invisibleScrollView.contentOffset
    }
}
