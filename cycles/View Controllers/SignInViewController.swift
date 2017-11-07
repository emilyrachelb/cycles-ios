//
//  SignInViewController.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import Firebase
import GoogleSignIn
import SwiftyPlistManager

class SignInViewController: UIViewController,  GIDSignInUIDelegate {
  
  // MARK: Properties
  @IBOutlet weak var googleSignInButton: GIDSignInButton!
  @IBAction func unwindToHomeVC(segue:UIStoryboardSegue) {}
  
  // set healthkit read properties
  private let dataTypesToRead: NSSet = {
    let healthKitManager = HealthKitManager.sharedInstance
    return NSSet(objects:
                 healthKitManager.biologicalSexCharacteristic,
                 healthKitManager.dateOfBirthCharacteristic,
                 healthKitManager.bodyFatPercentage,
                 healthKitManager.weight,
                 healthKitManager.height,
                 healthKitManager.bodyMassIndex,
                 healthKitManager.stepCount)
  }()
  
  // set healthkit write properties
  private let dataTypesToWrite: NSSet = {
    let healthKitManager = HealthKitManager.sharedInstance
    return NSSet(objects:
                 healthKitManager.basalBodyTemperature,
                 healthKitManager.cervicalMucusQuality,
                 healthKitManager.menstruation,
                 healthKitManager.intermenstrualFlow,
                 healthKitManager.ovulationTestResult,
                 healthKitManager.sexualActivity,
                 healthKitManager.systolicPressure,
                 healthKitManager.diastolicPressure,
                 healthKitManager.weight,
                 healthKitManager.height,
                 healthKitManager.stepCount)
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // google sign-in stuff
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signInSilently()
    
    // configure google sign-in button
    googleSignInButton.style = GIDSignInButtonStyle.wide
    
    // authorize healthkit
    HealthKitManager.sharedInstance.requestHealthKitAuthorization(dataTypesToWrite: dataTypesToWrite, dataTypesToRead: dataTypesToRead)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if (GIDSignIn.sharedInstance().hasAuthInKeychain()) {
      print("user already signed in")
      self.performSegue(withIdentifier: "goToHome", sender: nil)
    } else {
      print("user not signed in")
    }
  }
}
