//
//  AppDelegate.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import UIKit
import Firebase
import HealthKit
import GoogleSignIn
import SwiftyPlistManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate  {

  //global variables
  let userPrefsPlist = "userPrefs"
  let plistManager = SwiftyPlistManager.shared
  
  // user variables
  let userIdRef = "user_id"
  let userNameRef = "user_name"
  let userEmailRef = "user_email"
  let userPhotoRef = "user_photo_url"
  
  // user basic health info variables
  var userWeight = String()
  var userHeight = String()
  
  // new firebase database reference
  var databaseRef: DatabaseReference!
  
  // new firebase cloudstore reference
  var firestoreRef: DocumentReference? = nil
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // initialize firebase
    FirebaseApp.configure()
    
    // start plist manager
    plistManager.start(plistNames: [userPrefsPlist], logging: true)
    
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    return true
  }
  
  @available(iOS 9.0, *)
  func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation:  [:])
  }
  
  // start sign-in handler
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    if (error != nil) { return }
    
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
    
    // retrieve user info from the google user's account and store it
    // in the database and local plist
    
    let googleUserId: String = user.userID
    let googleUserName: String = user.profile.name
    let googleUserEmail: String = user.profile.email
    let googleUserPhoto: String = "\(String(describing: user.profile.imageURL(withDimension: 100 * UInt(UIScreen.main.scale))!))"
    
    let db = Firestore.firestore()
    
    // write google user data to database
    self.databaseRef = Database.database().reference().child("user_profiles").child(googleUserId).child("profile")
    self.databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
      let snapshot = snapshot.value as? NSDictionary
      
      // if data doesn't exist in the database for the specified user
      // write it to the database. otherwise update the value
      if (snapshot == nil) {
        self.databaseRef.child("user_id").setValue(googleUserId)
        self.databaseRef.child("user_name").setValue(googleUserName)
        self.databaseRef.child("user_email").setValue(googleUserEmail)
        self.databaseRef.child("user_image_url").setValue(googleUserPhoto)
        
        // write to plist
        self.plistManager.save(googleUserId as String!, forKey: self.userIdRef, toPlistWithName: self.userPrefsPlist) { (err) in
          if (err == nil) { return }
        }
        self.plistManager.save(googleUserName as String!, forKey: self.userNameRef, toPlistWithName: self.userPrefsPlist) { (err) in
          if (err == nil) { return }
        }
        self.plistManager.save(googleUserEmail as String!, forKey: self.userEmailRef, toPlistWithName: self.userPrefsPlist) { (err) in
          if (err == nil) { return }
        }
        self.plistManager.save(googleUserPhoto as String!, forKey: self.userPhotoRef, toPlistWithName: self.userPrefsPlist) { (err) in
          if (err == nil) { return }
        }
        
        self.firestoreRef = db.collection("users/").addDocument(data: [
          "user_info": [
            "user_id": googleUserId,
            "name": googleUserName,
            "email": googleUserEmail],
        ]) { err in
          if let err = err {
            print("error adding document: \(err)")
          } else {
            print("document added with id: \(self.firestoreRef!.documentID)")
            self.databaseRef.child("firebase_file_id").setValue("\(self.firestoreRef!.documentID)")
            self.plistManager.save("\(self.firestoreRef!.documentID)", forKey: "firebase_file_id", toPlistWithName: self.userPrefsPlist) { (err) in
              if (err == nil) { return }
            }
          }
        }
        
      } else {
        // only update the name, email and image url.
        // id doesn't need to be updated because it never changes
        self.databaseRef.child("user_name").setValue(googleUserName)
        self.databaseRef.child("user_email").setValue(googleUserEmail)
        self.databaseRef.child("user_image_url").setValue(googleUserPhoto)
        
        let firestoreFileIdRef = Database.database().reference().child("user_profiles").child(googleUserId)
        firestoreFileIdRef.observeSingleEvent(of: .value, with: {snapshot in
          if !snapshot.exists() { return }
          let getData = snapshot.value as? [String:Any]
          if let fileReference = getData!["firebase_file_id"] as? String {
            let firestoreFileRef = db.collection("users/").document(fileReference)
            firestoreFileRef.updateData([
              "user_info.name": googleUserName,
              "user_info.email": googleUserEmail
            ])
          }
        })
      }
    })
    
    
    Auth.auth().signIn(with: credential) { (user, error) in
      if (error != nil) { return }
    }
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
  }


}

