//
//  ViewController.swift
//  SBrick-iOS
//
//  Created by Barak Harel on 04/03/2017.
//  Copyright (c) 2017 Barak Harel. All rights reserved.
//

import UIKit
import SBrick
import CoreBluetooth
import AVFoundation

class ViewController: UIViewController, SBrickManagerDelegate, SBrickDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sensorTypeLabel: UILabel!
    @IBOutlet weak var sensorValueLabel: UILabel!

    
    var manager: SBrickManager!
    var sbrick: SBrick?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SBrickManager(delegate: self)
        
        statusLabel.text = "Discovering..."
        manager.startDiscovery()
    }
    
    func sbrickManager(_ sbrickManager: SBrickManager, didDiscover sbrick: SBrick) {
        
        //stop for now
        sbrickManager.stopDiscovery()
        
        statusLabel.text = "Found: \(sbrick.manufacturerData.deviceIdentifier)"
        
        //connect
        sbrick.delegate = self
        sbrickManager.connect(to: sbrick)
    }
    
    func sbrickManager(_ sbrickManager: SBrickManager, didUpdateBluetoothState bluetoothState: CBManagerState) {
        
    }
    
    func sbrickConnected(_ sbrick: SBrick) {
        statusLabel.text = "SBrick connected!"
        self.sbrick = sbrick
    }
    
    var adcTimer: Timer?
    func testSensor() {
        
        guard let sbrick = self.sbrick else { return }
        sbrick.send(command: .enableSensor(port: .port2))
        
        adcTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] (timer) in
            
            guard let sbrick = self?.sbrick else { return }
                        
            sbrick.send(command: .querySensor(port: .port2)) { [weak self] (bytes) in
                
                if let sensorData = SBrickSensorData(bytes: bytes) {
                    
                    self?.sensorTypeLabel.text = "\(sensorData.sensorType)"
                    self?.sensorValueLabel.text = "\(sensorData.sensorValue)"
                    
                    print("sensor type: \(sensorData.sensorType) value:\(sensorData.sensorValue)")
                }
            }
        })
    }
    
    func sbrickDisconnected(_ sbrick: SBrick) {
        statusLabel.text = "SBrick disconnected :("
        self.sbrick = nil
    }    
    
    func sbrickReady(_ sbrick: SBrick) {
        
        statusLabel.text = "SBrick ready!"
        testSensor()
    }
    
    func sbrick(_ sbrick: SBrick, didRead data: Data?) {
        
        guard let data = data else { return }
        print("sbrick [\(sbrick.name)] did read: \([UInt8](data))")
    }
    
    @IBAction func stop(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        
        //sbrick.send(command: .stop(channelId: 0))
        
        sbrick.port1.stop()
    }
    
    @IBAction func halfPowerCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        
        //sbrick.send(command: .drive(channelId: 0, cw: true, power: 0x80)) { bytes in
        //    print("ok")
        //}
        
        sbrick.port1.drive(power: 0x80, isCW: true)
    }
    
    @IBAction func fullPowerCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        
        //sbrick.send(command: .drive(channelId: 0, cw: true, power: 0xFF)) { bytes in
        //    print("ok")
        //}
        
        sbrick.port1.drive(power: 0xFF, isCW: true)
    }
    
    @IBAction func halfPowerCCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        
        //sbrick.send(command: .drive(channelId: 0, cw: false, power: 0x80)) { bytes in
        //    print("ok")
        //}
        
        sbrick.port1.drive(power: 0x80, isCW: false)
    }
    
    @IBAction func fullPowerCCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        
        //sbrick.send(command: .drive(channelId: 0, cw: false, power: 0xFF)) { bytes in
        //    print("ok")
        //}
        
        sbrick.port1.drive(power: 0xFF, isCW: false)
    }
}


