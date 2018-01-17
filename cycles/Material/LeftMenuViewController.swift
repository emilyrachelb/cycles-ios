//
//  LeftMenuViewController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2018-01-16.
//  Copyright © 2018 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import UIKit
import Material
import SwiftyPlistManager

struct ButtonLayout {
  struct AvatarButton {
    static let width: CGFloat = 60
    static let height: CGFloat = 60
    static let offsetX: CGFloat = -97.5
    static let offsetY: CGFloat = -329
  }
  
  struct NameButton {
    static let width: CGFloat = 240
    static let height: CGFloat = 20
    static let offsetX: CGFloat = 12.5
    static let offsetY: CGFloat = -334
  }
  
  struct ProfileButton {
    static let width: CGFloat = 220
    static let height: CGFloat = 20
    static let offsetX: CGFloat = -12.5
    static let offsetY: CGFloat = -334
  }
}

class LeftMenuViewController: UIViewController {
  fileprivate var transitionButton: FlatButton!
  
  // plist stuff
  let userInfo = "userInfo"
  let plistManager = SwiftyPlistManager.shared
  
  var userName: String?
  var userEmail: String?
  
  open override func viewDidLoad() {
    super .viewDidLoad()
    view.backgroundColor = Color.red.lighten1
    
    
  }
}
