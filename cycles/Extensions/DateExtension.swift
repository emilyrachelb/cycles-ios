//
//  DateExtension.swift
//  cycles
//
//  Created by Samantha Emily-Rachel Belnavis on 2017-11-06.
//  Copyright © 2017 Samantha Emily-Rachel Belnavis. All rights reserved.
//

import Foundation

extension Date {
  var lastYear: Date {
    return Calendar.current.date(byAdding: .year, value: -1, to: self)!
  }
  
  var lastMonth: Date {
    return Calendar.current.date(byAdding: .month, value: -1, to: self)!
  }
  
  var lastWeek: Date {
    return Calendar.current.date(byAdding: .day, value: -7, to: self)!
  }
  var today: Date {
    return Date()
  }
  var tomorrow: Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: self)!
  }
  
  var nextWeek: Date {
    return Calendar.current.date(byAdding: .day, value: 7, to: self)!
  }
  
  var nextYear: Date {
    return Calendar.current.date(byAdding: .year, value: 1, to: self)!
  }}
