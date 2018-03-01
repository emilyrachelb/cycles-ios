//
//  SettingsViewController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2018-01-18.
//  Copyright © 2018 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Firebase
import Foundation
import HealthKit
import Material
import Motion
import SwiftyPlistManager
import UIKit

class SettingsViewController: UIViewController {
  fileprivate var userInfoCard: Card!
  fileprivate var userInfoCardContentView: UILabel!
  fileprivate var userInfoCardToolbar: Toolbar!
  fileprivate var userInfoCardBottomBar: Bar!
  fileprivate var userInfoCardEditInfoButton: FlatButton!
  
  var window: UIWindow?
  
  //global variables
  let userInfoPlist = "userInfo"
  let plistManager = SwiftyPlistManager.shared
  let cloudstoreRef: DocumentReference? = nil
  let db = Firestore.firestore()
  
  // variables - user profile
  var userId = String()
  var userName = String()
  var userEmail = String()
  var userGender = String()
  var userAge = String()
  var userBirthday = String()
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}

extension SettingsViewController {
  fileprivate func prepareUserInfoCardToolbar() {
    userInfoCardToolbar.title = "Your Profile"
    userInfoCardToolbar.titleLabel.textAlignment = .left
  }
  
  fileprivate func prepareUserInfoCardContentView() {
    userInfoCardContentView = UILabel()
    userInfoCardContentView.numberOfLines = 0
    userInfoCardContentView.text=""
    userInfoCardContentView.font = RobotoFont.regular(with: 12)
  }
  
  fileprivate func prepareUserInfoCardEditInfoButton() {
    let editUserInfoButtonText = "Edit Info"
    
  }
}
