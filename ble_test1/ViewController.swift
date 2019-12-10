//
//  ViewController.swift
//  ble_test1
//
//  Created by Rudi Krämer on 06.12.19.
//  Copyright © 2019 Rudi Krämer. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    let particleLEDServiceUUID = CBUUID.init(string: "181B")
    
    var weightMeasure: Double = 0
    var weightMeasureGrams: Double = 0
    
    func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBAction func buttonAuthorize(_ sender: Any) {
        authorizeHealthKit()
    }
    
    @IBAction func buttonSendHealthKit(_ sender: Any) {
        if weightMeasureGrams == 0 {
            print("LEEEEEER")
        } else {
            saveBodyMassIndexToHealthKit()
        }
        
        
    }
    
    @IBAction func buttonOpenHealth(_ sender: Any) {
        openUrl(urlString: "x-apple-health://")

    }
    
    
    func saveBodyMassIndexToHealthKit() {
        storeData.saveBodyMassIndexSample(bodyMass: weightMeasureGrams,
                                          date: Date())
        
    }
    
    
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private let authorizeHealthKitSection = 2
    
    private func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
    }
    
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: [particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            //                centralManager.scanForPeripherals(withServices: nil, options: nil)
            
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("\nName   : \(peripheral.name ?? "(No name)")")
        
        print("RSSI   : \(RSSI)")
        for ad in advertisementData {
            print("AD Data: \(ad)")
        }
        
        
        //We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to MiScale")
            peripheral.discoverServices([particleLEDServiceUUID])
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                
                if service.uuid == particleLEDServiceUUID {
                    print("Service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics(nil, for: service)
                    return
                }
                print("Service Data: \(service)")
                
                
            }
        }
    }
    
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                
                switch characteristic.uuid.uuidString{
                    
                case "2A9C":
                    // Set notification on heart rate measurement
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Characteristic: \(characteristic)")
                    peripheral.readValue(for: characteristic)
                    
                    
                default:
                    print("")
                }
                
                
                
                //                    peripheral.readValue(for: characteristic)
                //
                //                    print("Characteristic: \(characteristic)")
                
                //print("Char.Value: \(String(describing: characteristic.value))")
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let scaleData = characteristic.value
            else { print("missing updated value"); return }
                

        let weightData = scaleData as NSData
//                print(weightData)
        
        let lastHex = weightData.last!
//                print("Weight: ",lastHex)
        let multiplierHex = weightData[11]
//                print("Multiplier: ",multiplierHex)
        
        
        let weightStringValue = lastHex.description
        let weightValue = Int(weightStringValue)!
                print("IntValue: \(weightValue)")

        let multiplierStringValue = multiplierHex.description
        let mulitplierValue = Int(multiplierStringValue)!
                print("MulitplierValue: \(mulitplierValue)")
        
        weightMeasure = (((Double(weightValue) * 256) + Double(mulitplierValue)) * 0.005)
        weightMeasureGrams = weightMeasure * 1000
//                print(weightMeasure)
        self.weightLabel.text = String(describing: self.weightMeasure) + " Kg"
        
    }
    
    


}

