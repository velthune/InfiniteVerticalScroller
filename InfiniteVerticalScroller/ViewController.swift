//
//  ViewController.swift
//  InfiniteVerticalScroller
//
//  Created by Luca Davanzo on 03/08/15.
//  Copyright (c) 2015 Luca Davanzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: InfiniteVerticalScroller!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadObjects()
        self.setupScrollView()
        self.view.addSubview(scrollView)
    }
    
    func setupScrollView() {
        scrollView.scrollEnabled = true
        var scrollViewOriginY: CGFloat = 0.0
        if let navigationController = self.navigationController {
            scrollViewOriginY += navigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        let scrollViewHeight = view.frame.height - scrollViewOriginY
        let scrollViewFrame = CGRectMake(0, scrollViewOriginY, view.frame.width, scrollViewHeight)
        scrollView = InfiniteVerticalScroller(frame: scrollViewFrame, array: viewModel.getObjects())
        scrollView.originOffset = scrollViewOriginY
    }
    
}