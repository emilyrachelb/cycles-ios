//
//  HomeViewController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Alamofire
import AlamofireImage
import Firebase
import HealthKit
import GoogleSignIn
import Material
import Motion
import SwiftyPlistManager
import UIKit

class HomeViewController: UIViewController, GIDSignInUIDelegate {
  
  fileprivate var infoCard: Card!
  fileprivate var infoCardContentView: UILabel!
  fileprivate var infoCardToolbar: Toolbar!
  fileprivate var infoCardMoreButton: IconButton!
  fileprivate var infoCardBottomBar: Bar!
  fileprivate var infoCardDateFormatter: DateFormatter!
  fileprivate var currentDateLabel: UILabel!
  fileprivate var dueDateLabel: UILabel!
  
  var window: UIWindow?
  // global variables
  let userPrefsPlist = "userInfo"
  let plistManager = SwiftyPlistManager.shared
  var databaseRef: DatabaseReference!
  var firestoreRef: DocumentReference? = nil
  let db = Firestore.firestore()
  
  // variables - user profile
  var userId = String()
  var userName = String()
  var userEmail = String()
  var userGender = String()
  var userAge = String()
  var userBirthday = String()
  var cloudstoreProfile = String()
  
  // variables - basic health info
  var userHeight = String()
  var userWeight = String()
  var userBloodPressure = String()
  var userBodyMassIndex = String()
  var userBodyFatPercentage = String()
  var userStepCount = Int()
  var userBasalBodyTemp = Int()
  
  // variables - sexual health info
  var cervicalMucusQuality = String()
  var menstrualFlow = String()
  var intermenstrualFlow = String()
  var ovulationTestResult = String()
  var sexualActivity = String()
  
  // MARK: Properties
  @IBAction func goToHome(segue: UIStoryboardSegue) { }
  
  // update the user profile
  func updateUserProfile() throws -> (age: Int, biologicalSex: HKBiologicalSex, birthDate: String){
    let healthKitStore = HKHealthStore()
    do {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US")
      dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")
      
      let birthdayComponents = try healthKitStore.dateOfBirthComponents()
      let biologicalSex = try healthKitStore.biologicalSex()
      
      let today = Date()
      let calendar = Calendar.current
      let currentDateComponents = calendar.dateComponents([.year], from: today)
      
      let thisYear = currentDateComponents.year!
      let age = thisYear - birthdayComponents.year!
      let dateToDisplay = calendar.date(from: birthdayComponents)!
      let birthDate = dateFormatter.string(from: dateToDisplay)
      
      let unwrappedBiologicalSex = biologicalSex.biologicalSex
      
      return (age, unwrappedBiologicalSex, birthDate)
    }
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    if !(GIDSignIn.sharedInstance().hasAuthInKeychain()) {
      performSegue(withIdentifier: "unwindToLoginVC", sender: self)
    }
    
    databaseRef = Database.database().reference()
    
    // get and store values in variables
    userId = self.plistManager.fetchValue(for: "user_id", fromPlistWithName: userPrefsPlist) as! String!
    cloudstoreProfile = self.plistManager.fetchValue(for: "cloudstore_profile", fromPlistWithName: userPrefsPlist) as! String!
    
    // get user's age, gender and birthday from HealthKit
    let userAgeAndGender = try? updateUserProfile()
    userGender = (userAgeAndGender?.biologicalSex.stringRepresentation)!
    userAge = String(describing: userAgeAndGender?.age)
    
    view.backgroundColor = Color.grey.lighten5
    prepareToolbar()
    
    prepareInfoCardDateFormatter()
    prepareCurrentDateLabel()
    prepareDueDateLabel()
    prepareInfoCardMoreButton()
    prepareInfoCardToolbar()
    prepareInfoCardContentView()
    prepareInfoCardBottomBar()
    prepareInfoCard()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func saveProfileInfo() {
    let firestoreFileRef = db.collection("users/").document(cloudstoreProfile)
    firestoreFileRef.updateData([
      "user_info.age": self.userAge,
      "user_info.gender": self.userGender,
      "user_info.birthday": self.userBirthday
    ])
  }
}

extension HomeViewController {
  fileprivate func prepareToolbar() {
    guard let tc = toolbarController else { return }
    
    tc.toolbar.title = "Home"
    tc.toolbar.detail = ""
  }
}

extension HomeViewController {
  fileprivate func prepareInfoCardDateFormatter(){
    infoCardDateFormatter = DateFormatter()
    infoCardDateFormatter.locale = Locale(identifier: "en_US")
    infoCardDateFormatter.setLocalizedDateFormatFromTemplate("MMM-d-yyyy")
  }
  
  fileprivate func prepareCurrentDateLabel() {
    currentDateLabel = UILabel()
    
    // set the font style and font size
    currentDateLabel.font = RobotoFont.regular(with: 12)
    currentDateLabel.textColor = Color.blueGrey.base
    currentDateLabel.text = infoCardDateFormatter.string(from: Date.distantFuture)
  }
  
  fileprivate func prepareInfoCardMoreButton() {
    infoCardMoreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.blueGrey.base)
  }
  
  fileprivate func prepareInfoCardToolbar() {
    infoCardToolbar = Toolbar(rightViews: [infoCardMoreButton])
    
    infoCardToolbar.title = "Test Card"
    infoCardToolbar.titleLabel.textAlignment = .left
  }
  
  fileprivate func prepareDueDateLabel() {
    dueDateLabel = UILabel()
    dueDateLabel.font = RobotoFont.regular(with: 12)
    dueDateLabel.textColor = Color.blueGrey.base
    dueDateLabel.text = "Due date: \(infoCardDateFormatter.string(from:Date.distantFuture))"
  }
  
  fileprivate func prepareInfoCardContentView() {
    infoCardContentView = UILabel()
    infoCardContentView.numberOfLines = 0
    infoCardContentView.text = "Test Card"
    infoCardContentView.font = RobotoFont.regular(with: 14)
  }
 
  fileprivate func prepareInfoCardBottomBar() {
    infoCardBottomBar = Bar()
    infoCardBottomBar.leftViews = [currentDateLabel]
    infoCardBottomBar.rightViews = [dueDateLabel]
  }
  
  fileprivate func prepareInfoCard() {
    infoCard = Card()
    
    infoCard.toolbar = infoCardToolbar
    infoCard.toolbarEdgeInsetsPreset = .square3
    infoCard.toolbarEdgeInsets.bottom = 0
    infoCard.toolbarEdgeInsets.right = 8
    
    infoCard.contentView = infoCardContentView
    infoCard.contentViewEdgeInsetsPreset = .wideRectangle3
    
    infoCard.bottomBar = infoCardBottomBar
    infoCard.bottomBarEdgeInsetsPreset = .wideRectangle2
    
    view.layout(infoCard).horizontally(left: 20, right: 20).top(25)
  }
}
