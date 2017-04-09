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

class ViewController: UIViewController, SBrickManagerDelegate, SBrickDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    var manager: SBrickManager!
    
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
    }
    
    func sbrickDisconnected(_ sbrick: SBrick) {
        statusLabel.text = "SBrick disconnected :("
    }
    
    func sbrickReady(_ sbrick: SBrick) {
        
        statusLabel.text = "SBrick ready!"
        
        sbrick.send([0x2C,0x01,0x03,0x05,0x07,0x08,0x09])
        sbrick.send([0x2E,0x01,0x03,0x05,0x07,0x08,0x09])        

    }
    
    func sbrick(_ sbrick: SBrick, didRead data: Data?) {
        
//        guard let data = data else { return }
//        print("sbrick [\(sbrick.name)] did read: \([UInt8](data))")
        
        if sbrick.channelValues.count > 0 {
            let channelValue = sbrick.channelValues[0]
            print("sbrick channel 0 voltage: \(SBrick.voltage(from: channelValue))")
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        sbrick.send(command: .stop(channelId: 0))
    }
    
    @IBAction func halfPowerCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        sbrick.send(command: .drive(channelId: 0, cw: true, power: 0x80))
    }
    
    @IBAction func fullPowerCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        sbrick.send(command: .drive(channelId: 0, cw: true, power: 0xFF))
    }
    
    @IBAction func halfPowerCCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        sbrick.send(command: .drive(channelId: 0, cw: false, power: 0x80))
    }
    
    @IBAction func fullPowerCCW(_ sender: Any) {
        guard let sbrick = manager.sbricks.first else { return }
        sbrick.send(command: .drive(channelId: 0, cw: false, power: 0xFF))
    }
}

