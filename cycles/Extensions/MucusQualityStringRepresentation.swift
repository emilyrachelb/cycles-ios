//
//  MucusQualityStringRepresentation.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import HealthKit

extension HKCategoryValueCervicalMucusQuality {
  var stringRepresentation: String {
    switch self {
    case .dry:
      return "dry"
    case .sticky:
      return "sticky"
    case .creamy:
      return "creamy"
    case .watery:
      return "watery"
    case .eggWhite:
      return "egg whites"
    }
  }
}
