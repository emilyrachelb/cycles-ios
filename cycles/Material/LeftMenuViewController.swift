//
//  LeftViewController.swift
//  locate
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-12-15.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import UIKit
import Material
import SwiftyPlistManager
import Alamofire
import AlamofireImage

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
  
  var userName: String?
  var userEmail: String?
  var imageUrl: URL!
  var userPhoto: UIImageView!
  
  fileprivate var transitionButton: FlatButton!
  
  // plist stuff
  let userInfo = "userInfo"
  let plistManager = SwiftyPlistManager.shared
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Color.red.lighten1
    
    userName = plistManager.fetchValue(for: "user_first_name", fromPlistWithName: "userInfo") as! String!
    userEmail = plistManager.fetchValue(for: "user_email", fromPlistWithName: "userInfo") as! String!
    imageUrl = URL(string: plistManager.fetchValue(for: "photo_url", fromPlistWithName: "userInfo") as! String!)
    
    
    //prepareAvatarButton()
    //prepareNameButton()
    prepareProfileButton()
  }
}

extension LeftMenuViewController {
  
  fileprivate func prepareProfileButton() {
    // create the button that will hold the user's name and greeting
    
    let profileButtonText = "Hi, \(userName!)!"
    let profileButton = FlatButton(title: profileButtonText, titleColor: .white)
    profileButton.titleLabel?.minimumScaleFactor = 0.5
    profileButton.titleLabel?.numberOfLines = 1
    profileButton.titleLabel?.adjustsFontSizeToFitWidth = true
    profileButton.pulseColor = .white
    profileButton.addTarget(self, action: #selector(handleProfileButton), for: .touchUpInside)
    
    view.layout(profileButton)
      .width(ButtonLayout.ProfileButton.width)
      .height(ButtonLayout.ProfileButton.height)
      .center(offsetY: ButtonLayout.ProfileButton.offsetY)
  }
  
  fileprivate func prepareAvatarButton() {
    // create the user avatar button
    
    let avatarButton = FlatButton()
    
    // get the user's photo
    Alamofire.request(imageUrl).responseImage { response in
      debugPrint(response)
      
      print(response.request)
      print(response.response)
      debugPrint(response.result)
      
      if let image = response.result.value {
        print("image downloaded: \(image)")
        let photoSize = CGSize(width: self.userPhoto.frame.width, height: self.userPhoto.frame.height)
        let scaledToFit = image.af_imageAspectScaled(toFit: photoSize)
        let circleAvatar = scaledToFit.af_imageRoundedIntoCircle()
        self.userPhoto.image = circleAvatar
        
        let userAvatarButton: UIButton = UIButton(type: UIButtonType.custom)
        userAvatarButton.setImage(circleAvatar, for: UIControlState.normal)
        userAvatarButton.addTarget(self, action: #selector(LeftMenuViewController.handleAvatarButton), for: UIControlEvents.touchUpInside)
        
        self.view.layout(avatarButton)
          .width(ButtonLayout.AvatarButton.width)
          .height(ButtonLayout.AvatarButton.height)
          .center(offsetY: ButtonLayout.AvatarButton.offsetY)
      }
    }
  }
}

extension LeftMenuViewController {
  
  @objc
  fileprivate func handleProfileButton() {
    
  }
  
  @objc
  fileprivate func handleAvatarButton() {
    
  }
  
  fileprivate func closeNavigationDrawer(result: Bool) {
    navigationDrawerController?.closeLeftView()
  }
}

