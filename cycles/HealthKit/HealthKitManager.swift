//
//  HealthKitManager.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
  class var sharedInstance: HealthKitManager {
    struct Singleton {
      static let instance = HealthKitManager()
    }
    return Singleton.instance
  }
  
  var healthStore: HKHealthStore? = {
    if HKHealthStore.isHealthDataAvailable() {
      return HKHealthStore()
    } else {
      return nil
    }
  }()
  
  // HealthKit Datatypes
  
  // identifying information
  let dateOfBirthCharacteristic = HKCharacteristicType.characteristicType(forIdentifier: .dateOfBirth)
  let biologicalSexCharacteristic = HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)
  
  // basic health data
  let systolicPressure = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)
  let diastolicPressure = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)
  let bodyFatPercentage = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)
  let weight = HKQuantityType.quantityType(forIdentifier: .bodyMass)
  let height = HKQuantityType.quantityType(forIdentifier: .height)
  let bodyMassIndex = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)
  let basalBodyTemperature = HKQuantityType.quantityType(forIdentifier: .basalBodyTemperature)
  
  // activity
  let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)
  
  // sexual health
  let cervicalMucusQuality = HKCategoryType.categoryType(forIdentifier: .cervicalMucusQuality)
  let menstruation = HKCategoryType.categoryType(forIdentifier: .menstrualFlow)
  let intermenstrualFlow = HKCategoryType.categoryType(forIdentifier: .intermenstrualBleeding)
  let ovulationTestResult = HKCategoryType.categoryType(forIdentifier: .ovulationTestResult)
  let sexualActivity = HKCategoryType.categoryType(forIdentifier: .sexualActivity)
  
  // get date of birth
  var dateOfBirth: String? {
    if let dateOfBirth = try? healthStore?.dateOfBirthComponents() {
      let birthdateDateFormatter = DateFormatter()
      birthdateDateFormatter.dateStyle = .long
      let preferredDateFormat = Calendar.current.date(from: dateOfBirth!)!
      let birthdate = birthdateDateFormatter.string(from: preferredDateFormat)
      return birthdate
    }
    return nil
  }
  
  var biologicalSex: String? {
    if let biologicalSex = try? healthStore?.biologicalSex() {
      switch biologicalSex!.biologicalSex {
      case .female:
        return "female"
      case .male:
        return "male"
      case .other:
        return "other"
      case .notSet:
        return "not_set"
      }
    }
    return nil
  }
  
  var healthKitAuthorized: Bool? {
    return nil
  }
  
  func requestHealthKitAuthorization(dataTypesToWrite: NSSet?, dataTypesToRead: NSSet?) {
    healthStore?.requestAuthorization(toShare: dataTypesToWrite as? Set<HKSampleType>, read: dataTypesToRead as? Set<HKObjectType>, completion: {(success, error) -> Void in
      if success {
        print("successfully authorized healthkit")
      } else {
        print(error?.localizedDescription)
      }
    })
  }
  
  class func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
    // use hkquery to load the most recent samples
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let limit = 1
    
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
      DispatchQueue.main.async {
        guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
          completion(nil, error)
          return
        }
        completion(mostRecentSample, nil)
      }
    }
    HKHealthStore().execute(sampleQuery)
  }
}
