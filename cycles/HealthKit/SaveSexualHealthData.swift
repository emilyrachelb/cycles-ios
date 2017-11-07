//
//  SaveSexualHealthData.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Foundation
import HealthKit
import SwiftyPlistManager
import Firebase

class SaveSexualHealthData {
  
  // global variables
  let firestoreRef: DocumentReference? = nil
  let db = Firestore.firestore()
  let healthKitManager = HealthKitManager.sharedInstance
  
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
  
  let healthStore: HKHealthStore? = {
    if HKHealthStore.isHealthDataAvailable() {
      return HKHealthStore()
    } else {
      return nil
    }
  }()
  
  func saveCervicalMucusQuality(mucusQuality: Int, date: Date) {
//    guard let cervicalMucusQualityType = HKCategoryType.categoryType(forIdentifier: .cervicalMucusQuality) else {
//      fatalError("Cervical Mucus Quality is no longer available in HealthKit")
//    }
//    let cervicalMucusQuality = HKCategoryValue(rawValue: <#T##Int#>)
//    let cervicalMucusQualitySample = HKCategorySample(type: cervicalMucusQualityType, )
//    if let authStatus = healthStore?.authorizationStatus(for: HKCategoryType.categoryType(forIdentifier: .cervicalMucusQuality)!) {
//      switch authStatus {
//      case .notDetermined:
//        healthKitManager.requestHealthKitAuthorization(dataTypesToWrite: dataTypesToWrite, dataTypesToRead: dataTypesToRead)
//      case .sharingDenied:
//        healthKitManager.requestHealthKitAuthorization(dataTypesToWrite: dataTypesToWrite, dataTypesToRead: dataTypesToRead)
//      case .sharingAuthorized:
//        healthStore?.save(mucusQuality, withCompletion: { (success, error) in
//          if let error = error {
//
//          } else {
//
//          }
//        })
//      }
//    }
  }
  
  func saveMenstrualFlow() {
    
  }
  
  func saveIntermenstrualFlow() {
    
  }
  
  func saveOvulationTestResult() {
    
  }
  
  func saveSexualActivity() {
    
  }
  
}
