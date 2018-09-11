//
//  ViewController.swift
//  central
//
//  Created by ミップ on 2018/08/29.
//  Copyright © 2018年 ミップ. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,UITextFieldDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    let serviceUUID:CBUUID = CBUUID(string: "135E7F5F-D98B-413C-A0BE-CAC8E3F53280")
    let charactaristicUUID_value:CBUUID = CBUUID(string: "9E21E0B1-6EAA-47B0-916A-23FAF3984207")
    let charactaristicUUID_name:CBUUID = CBUUID(string: "810E2E4E-2E03-46F5-91FB-A238A8E127B5")
    let characteristicUUID_id    = CBUUID(string: "362114A3-CDD5-4A68-812B-C2C63A1E0FA5")
    var devicename:String?
    var deviceid:String?
    var devicevalue:String?
    
    
    
    @IBOutlet var deviceID: UILabel!//ペリフェラルのID表示部分
    @IBOutlet var deviceNAME: UILabel!//ペリヘラルの名前表示部分
    @IBOutlet var value: UILabel!//ペリフェラルから受信した値の表示部分
    @IBOutlet var value01: UITextField!
    @IBOutlet var value02: UITextField!
    @IBOutlet var value03: UITextField!
    @IBOutlet var value04: UITextField!
    @IBOutlet var value05: UITextField!
    @IBOutlet var value06: UITextField!
    var focus_textfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.value01.delegate = self
        self.value02.delegate = self
        self.value03.delegate = self
        self.value04.delegate = self
        self.value05.delegate = self
        self.value06.delegate = self
        
        value.numberOfLines = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.peripheral != nil{
            self.centralManager.cancelPeripheralConnection(self.peripheral)
        }
    }
   

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textfield touch")
        self.focus_textfield = textField
        return true
    }
    
    //centralManagerが更新した時に呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
    }

    @IBAction func scan(_ sender: Any) {
        //周囲のペリフェラルを検出
        //self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
    }
    
    //ペリフェラルを検出した時に呼び出される
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("発見したBLEデバイス:\(peripheral.identifier)")
        let uuid = peripheral.identifier.uuidString
        //if uuid == "090C2471-2BF2-6448-5C28-BA3C2C01645B"{//ミップスタッフのiphone(2) DBに登録されている装置のUUIDに変更
        if uuid == "91B7541E-A6DC-2484-2DB4-57CF8F0A114E"{//テスト用iPad
        self.peripheral = peripheral
            self.centralManager.connect(self.peripheral, options: nil)
        }
    }
    
    //ペリフェラとのコネクトに成功した時に呼び出される
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功")
        peripheral.delegate = self
        //let UUID = CBUUID(string: "135E7F5F-D98B-413C-A0BE-CAC8E3F53280")
        peripheral.discoverServices([self.serviceUUID])
        //peripheral.discoverServices(nil)
    }
    //ペリフェラルのコネクトに失敗した時に呼び出される
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗")
    }
    //ペリフェラルのサービスを検出した時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("サービス検出")
        if error != nil{
            print(error.debugDescription)
            return
        }
        
        //キャラクタリスティック 検索
        peripheral.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
    }
    
    //キャラクタリスティック 検出じに呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics = service.characteristics
        if error != nil{
            print(error.debugDescription)
            return
        }
        print("\(String(describing: service.characteristics?.count))個のキャラクタリスティック を検知")
        
        for obj in characteristics!{
            if let characteristic = obj as? CBCharacteristic{
                
                print(characteristic.uuid)
                switch characteristic.uuid{
                case self.charactaristicUUID_name:
                    print("nameのキャラクタリスティック を検出")
                    peripheral.readValue(for: characteristic)
                case self.charactaristicUUID_value:
                    print("valueのキャラクタリスティック を検出")
                    peripheral.setNotifyValue(true, for: characteristic)
                case self.characteristicUUID_id:
                    print("idのキャラクタリスティック を検出")
                    peripheral.readValue(for: characteristic)
                default:
                    print("指定外のキャラクタリスティック を検出")
                }
            }
        }
        
    }
    
    //readリクエストにレスポンスが返ってきたら呼び出される
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid{
        case self.charactaristicUUID_name:
            self.devicename = String(data: characteristic.value!, encoding: .utf8)
            print(self.devicename)
            self.deviceNAME.text = self.devicename
        case self.characteristicUUID_id:
            self.deviceid = String(data: characteristic.value!, encoding: .utf8)
            print(self.deviceid)
            self.deviceID.text = self.deviceid
        case self.charactaristicUUID_value:
            self.devicevalue = String(data: characteristic.value!, encoding: .utf8)
            print(self.devicevalue)
            self.focus_textfield.text = self.devicevalue
            //self.value.text = ("\(self.value.text!)\n\(self.devicevalue)")
            
            //入力欄移動
            self.focus_textfield.resignFirstResponder()
            let nextTag = self.focus_textfield.tag + 1
            if let nextTextField = self.view.viewWithTag(nextTag){
                nextTextField.becomeFirstResponder()
            }
            
        default:
            print("指定外のキャラクタリスティック のレスポンスを検出")
        }
    }
    
}

