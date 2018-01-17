//
//  AppToolbarController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2018-01-16.
//  Copyright © 2018 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import UIKit
import Material

class AppToolbarController: ToolbarController {
  fileprivate var menuButton: IconButton!
  
  override func prepare() {
    super.prepare()
    prepareMenuButton()
    prepareStatusBar()
    prepareToolbar()
  }
}

extension AppToolbarController {
  fileprivate func prepareMenuButton() {
    menuButton = IconButton(image: Icon.cm.menu)
    menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
  }
  
  fileprivate func prepareStatusBar() {
    statusBarStyle = .lightContent
  }
  
  fileprivate func prepareToolbar() {
    toolbar.leftViews = [menuButton]
  }
}

extension AppToolbarController {
  @objc
  fileprivate func handleMenuButton() {
    navigationDrawerController?.toggleLeftView()
  }
}
