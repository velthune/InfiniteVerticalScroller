//
//  InfiniteVerticalScroller.swift
//  InfiniteVerticalScroller
//
//  Created by Luca Davanzo on 03/08/15.
//  Copyright (c) 2015 Luca Davanzo. All rights reserved.
//


import Foundation
import UIKit

class InfiniteVerticalScroller: UIScrollView, UIScrollViewDelegate {
    
    static var labelSize: CGFloat = 0.0
    static var labelPerPage: Int = 9
    
    var strings: [String] = []
    var visibleLabels: [UILabel] = []
    var labelContainerView = UIView()
    var currentIndexTop = 0
    var currentIndexBottom = 0
    var originOffset: CGFloat = 0.0
    
    // MARK: - Constructors -
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupScrollView()
    }
    
    init(frame: CGRect, array: [String]) {
        super.init(frame: frame)
        strings = array
        self.setupScrollView()
    }
    
    func setupScrollView() {
        InfiniteVerticalScroller.labelSize = (self.frame.height) / CGFloat(InfiniteVerticalScroller.labelPerPage)
        self.contentSize = CGSizeMake(self.frame.width, InfiniteVerticalScroller.labelSize * 48)
        labelContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)
        self.addSubview(labelContainerView)
        labelContainerView.userInteractionEnabled = false
        labelContainerView.backgroundColor = UIColor.clearColor()
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = self
    }
    
    // MARK: - Layout management -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.recenterIfNecessary()
        // tile content in visible bounds
        let visibleBounds = self.convertRect(self.bounds, toView:self.labelContainerView)
        let minimumVisibleY = CGRectGetMinY(visibleBounds)
        let maximumVisibleY = CGRectGetMaxY(visibleBounds)
        self.tileLabels(fromMinY: minimumVisibleY, toMaxY: maximumVisibleY)
    }
    
    var firstTime: Bool = true
    
    // recenter content periodically to achieve impression of infinite
    func recenterIfNecessary() {
        /* TODO update indexes */
        if firstTime == false {
            if (self.contentOffset.y) % InfiniteVerticalScroller.labelSize != 0 {
                return
            }
        }
        firstTime = false
        let currentOffset = self.contentOffset
        let contentHeight = self.contentSize.height
        var centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0
        let offMin: CGFloat = CGFloat(Int(centerOffsetY / InfiniteVerticalScroller.labelSize)) * InfiniteVerticalScroller.labelSize
        let offMax: CGFloat = offMin + InfiniteVerticalScroller.labelSize
        
        centerOffsetY = min(abs(centerOffsetY - offMin), abs(centerOffsetY - offMax)) == abs(centerOffsetY - offMax) ? offMax : offMin
        let distanceFromCenter = fabs(currentOffset.y - centerOffsetY)
        
        if (distanceFromCenter > (contentHeight / 4.0)) {
            self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY)
            // move content by the same amount so it appears to stay still
            for label in visibleLabels {
                var center = labelContainerView.convertPoint(label.center, toView:self)
                center.y += (centerOffsetY - currentOffset.y)
                label.center = self.convertPoint(center, toView: labelContainerView)
            }
        }
    }
    
    // MARK: - Scroll view delegates -
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let targetContentOffsetY = targetContentOffset.memory.y
//        
//        let offMin: CGFloat = CGFloat(Int(targetContentOffsetY / InfiniteVerticalScroller.labelSize)) * InfiniteVerticalScroller.labelSize
//        let offMax: CGFloat = offMin + InfiniteVerticalScroller.labelSize
//        
//        let newTarget = min(abs(targetContentOffsetY - offMin), abs(targetContentOffsetY - offMax)) == abs(targetContentOffsetY - offMax) ? offMax : offMin
//        
//        targetContentOffset.memory.y = newTarget
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let currentContentOffsetY = scrollView.contentOffset.y
//        if currentContentOffsetY % InfiniteVerticalScroller.labelSize != 0 {
//            let offMin: CGFloat = CGFloat(Int(currentContentOffsetY / InfiniteVerticalScroller.labelSize)) * InfiniteVerticalScroller.labelSize
//            let offMax: CGFloat = offMin + InfiniteVerticalScroller.labelSize
//            let newTarget = min(abs(currentContentOffsetY - offMin), abs(currentContentOffsetY - offMax)) == abs(currentContentOffsetY - offMax) ? offMax : offMin
//            scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, newTarget), animated: true)
//        }
    }
    
    // MARK: - Scroll view subviews management -
    
    func insertLabel(currentIndex: Int) -> UILabel {
        let labelWidth = self.frame.width
        let label = UILabel(frame: CGRectMake(0, 0, labelWidth, InfiniteVerticalScroller.labelSize))
        label.text = strings[currentIndex]
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.whiteColor()
        labelContainerView.addSubview(label)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.clearColor().CGColor
        return label
    }
    
    func placeNewElementOnTop(topEdge: CGFloat) -> CGFloat {
        let label = self.insertLabel(currentIndexTop)
        self.updateIndexForTopInserting()
        visibleLabels.insert(label, atIndex: 0)
        var frame = label.frame
        frame.origin.x = 0
        frame.origin.y = topEdge - frame.size.height
        label.frame = frame
        return CGRectGetMinY(frame)
    }
    
    func placeNewElementOnBottom(bottomEdge: CGFloat) -> CGFloat {
        var label = self.insertLabel(currentIndexBottom)
        self.updateIndexForBottomInserting()
        visibleLabels.append(label)
        var frame = label.frame
        frame.origin.x = 0
        frame.origin.y = bottomEdge
        label.frame = frame
        return CGRectGetMaxY(frame)
    }
    
    func tileLabels(fromMinY minimumVisibleY: CGFloat, toMaxY maximumVisibleY: CGFloat) {
        
        if visibleLabels.count == 0 {
            self.placeNewElementOnTop(minimumVisibleY)
        }
        
        var lastLabel = visibleLabels.last
        var bottomEdge = CGRectGetMaxY(lastLabel!.frame)
        
        while bottomEdge < maximumVisibleY {
            bottomEdge = self.placeNewElementOnBottom(bottomEdge)
        }
        
        // add labels that are missing on top side
        var firstLabel = visibleLabels.first
        var topEdge = CGRectGetMinY(firstLabel!.frame)
        
        while topEdge > minimumVisibleY {
            topEdge = self.placeNewElementOnTop(topEdge)
        }
        
        // remove labels that have fallen off bottom edge
        lastLabel = visibleLabels.last
        
        while lastLabel?.frame.origin.y > maximumVisibleY {
            lastLabel?.removeFromSuperview()
            visibleLabels.removeLast()
            self.updateIndexForBottomRemoving()
            lastLabel = visibleLabels.last
        }
        
        // remove labels that have fallen off top edge
        
        firstLabel = visibleLabels.first
        while CGRectGetMaxY(firstLabel!.frame) < minimumVisibleY {
            firstLabel?.removeFromSuperview()
            visibleLabels.removeAtIndex(0)
            self.updateIndexForTopRemoving()
            firstLabel = visibleLabels.first
        }
    }
    
    // MARK: - Index management -
    
    func updateIndexForTopInserting() {
        if currentIndexTop == 0 {
            currentIndexTop = strings.count - 1
        } else {
            currentIndexTop--
        }
    }
    
    func updateIndexForBottomInserting() {
        if currentIndexBottom < strings.count - 1 {
            currentIndexBottom++
        } else {
            currentIndexBottom = 0
        }
    }
    
    func updateIndexForTopRemoving() {
        currentIndexTop++
        if currentIndexTop > strings.count - 1 {
            currentIndexTop = 0
        }
    }
    
    func updateIndexForBottomRemoving() {
        currentIndexBottom--
        if currentIndexBottom < 0 {
            currentIndexBottom = strings.count - 1
        }
    }
    
}