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
  fileprivate var settingsButton: IconButton!
  
  override func prepare() {
    super.prepare()
    prepareMenuButton()
    prepareSettingsButton()
    prepareStatusBar()
    prepareToolbar()
  }
}

extension AppToolbarController {
  fileprivate func prepareMenuButton() {
    menuButton = IconButton(image: Icon.cm.menu, tintColor: Color.red.base)
    menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
  }
  
  fileprivate func prepareSettingsButton() {
    settingsButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.red.base)
    settingsButton.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
  }
  
  fileprivate func prepareStatusBar() {
    statusBarStyle = .lightContent
  }
  
  fileprivate func prepareToolbar() {
    toolbar.leftViews = [menuButton]
    toolbar.rightViews = [settingsButton]
  }
}

extension AppToolbarController {
  @objc
  fileprivate func handleMenuButton() {
    navigationDrawerController?.toggleLeftView()
  }
  
  @objc
  fileprivate func handleSettingsButton() {
    
  }
}
