//
//  HomeViewController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import SwiftyPlistManager
import HealthKit

class HomeViewController: UIViewController, GIDSignInUIDelegate {
  
  // global variables
  let userPrefsPlist = "userPrefs"
  let plistManager = SwiftyPlistManager.shared
  var databaseRef: DatabaseReference!
  var firestoreRef: DocumentReference? = nil
  let db = Firestore.firestore()
  
  // variables - "reference" specific
  let userIdRef = "user_id"
  let userNameRef = "user_name"
  let userEmailRef = "user_email"
  let userGenderRef = "user_gender"
  let userAgeRef = "user_age"
  let userBirthdayRef = "user_birthday"
  let firebaseFileIdRef = "firebase_file_id"
  
  // variables - user profile
  var userId = String()
  var userName = String()
  var userEmail = String()
  var userGender = String()
  var userAge = String()
  var userBirthday = String()
  var firebaseFileId = String()
  
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
  @IBAction func goToMain(segue: UIStoryboardSegue) { }
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !(GIDSignIn.sharedInstance().hasAuthInKeychain()) {
      performSegue(withIdentifier: "unwindToLoginVC", sender: self)
    }
    
    databaseRef = Database.database().reference()
    
    // get and store values in variables
    userId = self.plistManager.fetchValue(for: userIdRef, fromPlistWithName: userPrefsPlist) as! String!
    firebaseFileId = self.plistManager.fetchValue(for: firebaseFileIdRef, fromPlistWithName: userPrefsPlist) as! String!
    
    // get user's age, gender and birthday from HealthKit
    let userAgeAndGender = try? updateUserProfile()
    userGender = (userAgeAndGender?.biologicalSex.stringRepresentation)!
    userAge = String(describing: userAgeAndGender?.age)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func saveProfileInfo() {
    databaseRef.child("user_profiles").child(self.userId).child(userAgeRef).setValue(userAge)
    databaseRef.child("user_profiles").child(self.userId).child(userBirthdayRef).setValue(userBirthday)
    databaseRef.child("user_profiles").child(self.userId).child(userGenderRef).setValue(userGender)
    
    
    let firestoreFileRef = db.collection("users/").document(firebaseFileId)
    firestoreFileRef.updateData([
      "user_info.age": self.userAge,
      "user_info.gender": self.userGender,
      "user_info.birthday": self.userBirthday
    ])
  }
}
