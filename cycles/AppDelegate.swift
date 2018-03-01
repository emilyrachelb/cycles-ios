//
//  AppDelegate.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import Sentry
import SwiftyPlistManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
  var window: UIWindow?
  
  // plist variables
  let localUserInfo = "userInfo"
  let appPreferences = "appPreferences"
  let plistManager = SwiftyPlistManager.shared
  
  // user info reference variables
  let cloudstoreFile = "cloudstore_profile"
  let userId = "user_id"
  let userEmail = "user_email"
  let userFirstName = "user_first_name"
  let userFullName = "user_full_name"
  let userPhotoUrl = "gUser_photo_url"
  
  // new realtime database reference
  var databaseRef: DatabaseReference!
  
  // new cloudstore reference
  var cloudstoreRef: DocumentReference? = nil
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // initialize firebase
    FirebaseApp.configure()
    
    // start plistManager
    plistManager.start(plistNames: [localUserInfo], logging: true)
    
    // google signin manager
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    
    do {
      Client.shared = try Client(dsn: "https://a235b473014c4ecb8aa1a47cbadbd159:160b6c121c124d94826fb94227f84559@sentry.io/255032")
      try Client.shared?.startCrashHandler()
    } catch let error {
      print("\(error)")
    }
    
    return true
  }
  
  @available(iOS 11.0, *)
  func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
  }
  
  
  // sign-in handler
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    if (error != nil) { return }
    
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
    
    // get google user's info
    let googleUserId: String = user.userID
    let googleUserName: String = user.profile.name
    let googleUserEmail: String = user.profile.email
    let googleUserPhotoUrl: String = "\(String(describing: user.profile.imageURL(withDimension: 100 * UInt(UIScreen.main.scale))!))"
    
    // get just the user's first name
    let delimiter = " "
    var token = googleUserName.components(separatedBy: delimiter)
    let userFirstName = token[0]
    //save user info to the local plist file
    self.plistManager.save(googleUserId, forKey: self.userId, toPlistWithName: self.localUserInfo) { (err) in
      if (err == nil) { return }
    }
    
    self.plistManager.save(googleUserName, forKey: self.userFullName, toPlistWithName: self.localUserInfo) { (err) in
      if (err == nil) { return }
    }
    
    self.plistManager.save(googleUserEmail, forKey: self.userEmail, toPlistWithName: self.localUserInfo) { (err) in
      if (err == nil) { return }
    }
    
    self.plistManager.save(googleUserPhotoUrl, forKey: self.userPhotoUrl, toPlistWithName: self.localUserInfo) { (err) in
      if (err == nil) { return }
    }
    
    self.plistManager.save(userFirstName, forKey: self.userFirstName, toPlistWithName: self.localUserInfo) { (err) in
      if (err == nil) { return }
    }
    
    // store to the database
    let db = Firestore.firestore()
    
    // check if the user already has an account
    self.databaseRef = Database.database().reference().child("user_profiles").child(String(googleUserId))
    self.databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
      let snapshot = snapshot.value as? NSDictionary
      
      // if the user doesn't exist, create a profile for them
      if (snapshot == nil) {
        self.cloudstoreRef = db.collection("users/").addDocument(data: [
          "user_info": [
            "user_id": googleUserId,
            "user_name": googleUserName,
            "user_email": googleUserEmail,
            "user_age": "not set",
            "user_gender": "not set",
            "user_pronouns": "not set",
            "health_info": [
              "cycle_state": "not set",
              "user_height": "not set",
              "user_weight": "not set",
            ],
            "phone_info": [
              "phone_number": "not set",
              "number_verified": "not set",
            ],
            "registration_state": "incomplete",
          ],
          ]) { (err) in
            if let err = err {
              print("There was an error when trying to add the document: \(err)")
            } else {
              print("Document was added with the id: \(self.cloudstoreRef!.documentID)")
              self.plistManager.save("\(self.cloudstoreRef!.documentID)", forKey: self.cloudstoreFile, toPlistWithName: self.localUserInfo) { (err) in
                if (err == nil) { return }
            }
            self.databaseRef.child("profile_id").setValue("\(self.cloudstoreRef!.documentID)")
          }
        }
      }
    })
    
    Auth.auth().signIn(with: credential) { (user, error) in
      if (error != nil) { return }
    }
    return
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "locate")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
