//
//  CommonFlexViewController.swift
//  FlexImageCropViewDemo
//
//  Created by Martin Rehder on 28.07.2019.
//  Copyright © 2019 Rehsco. All rights reserved.
//

import UIKit
import MJRFlexStyleComponents

open class CommonFlexViewController: UIViewController {
    public var defaultHeaderSize:CGFloat = 42
    public var defaultExtendedHeaderSize:CGFloat = 65
    
    open var leftViewMenu: CommonIconViewMenu?
    open var rightViewMenu: CommonIconViewMenu?
    
    open var contentView: FlexView?
    
    open var headerText: String?
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.refreshView()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
            self.whenTransition(to: size)
        }, completion: { context in
        })
    }
    
    open func whenTransition(to size: CGSize) {
    }
    
    open func setupView() {
        self.setupDefaultViewStyling()
    }
    
    open func refreshView() {
        self.contentView?.headerText = self.headerText
    }
    
    open func setupDefaultViewStyling() {
        self.automaticallyAdjustsScrollViewInsets = false
        // This also sets the status bar background color
        self.view.backgroundColor = .black
    }
    
    // MARK: - Styling
    
    open func applyViewDefaultStyling(flexView: FlexView) {
        flexView.header.caption.labelTextAlignment = .center
        flexView.header.caption.labelFont = UIFont.systemFont(ofSize: 22, weight: .light)
        flexView.header.caption.labelTextColor = .white
        flexView.headerSize = self.defaultHeaderSize
        flexView.header.styleColor = .gray
        flexView.styleColor = .lightGray
    }
    
    // MARK: - View logic
    
    open func closeView() {
        if self.isModal() {
            self.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    open func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }

}
