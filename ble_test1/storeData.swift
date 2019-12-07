//
//  storeData.swift
//  BLE Scale
//
//  Created by Rudi Krämer on 07.12.19.
//  Copyright © 2019 Rudi Krämer. All rights reserved.
//

import HealthKit

class storeData {

    class func saveBodyMassIndexSample(bodyMass: Double, date: Date) {
      
      //1.  Make sure the body mass type exists
      guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
        fatalError("Body Mass  Type is no longer available in HealthKit")
      }
        
      //2.  Use the Count HKUnit to create a body mass quantity
        let bodyMassQuantity = HKQuantity(unit: HKUnit.gram(),
                                        doubleValue: bodyMass)
        
      let bodyMassIndexSample = HKQuantitySample(type: bodyMassType,
                                                 quantity: bodyMassQuantity,
                                                 start: date,
                                                 end: date)
        
      //3.  Save the same to HealthKit
      HKHealthStore().save(bodyMassIndexSample) { (success, error) in
          
        if let error = error {
          print("Error Saving Weight Sample: \(error.localizedDescription)")
        } else {
          print("Successfully saved Weight Sample")
        }
      }
    }

}
