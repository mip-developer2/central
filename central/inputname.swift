//
//  inputname.swift
//  central
//
//  Created by ミップ on 2018/09/10.
//  Copyright © 2018年 ミップ. All rights reserved.
//

import UIKit
import CoreBluetooth

class inputname:  UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,UITextFieldDelegate {
        var centralManager: CBCentralManager!
        var peripheral: CBPeripheral!
        var charactaristic: CBCharacteristic!
        let serviceUUID:CBUUID = CBUUID(string: "135E7F5F-D98B-413C-A0BE-CAC8E3F53280")
        let charactaristicUUID_name:CBUUID = CBUUID(string: "810E2E4E-2E03-46F5-91FB-A238A8E127B5")
        var devicename:String?
    
        var isdone:Bool = false
        
    
        @IBOutlet var name: UITextField!
    
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
            print("start")
            //self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
        }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
    }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    @IBAction func scanbutton(_ sender: Any) {
        self.centralManager.scanForPeripherals(withServices: [self.serviceUUID], options: nil)
    }
    
    
        //画面遷移時に呼ばれる
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if self.peripheral != nil{
                self.centralManager.cancelPeripheralConnection(self.peripheral)
            }
        }
        
        //centralManagerが更新した時に呼ばれる
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            print("state: \(central.state)")
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
            peripheral.discoverServices([self.serviceUUID])
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
                        if self.isdone == false{
                            print("nameのキャラクタリスティック を検出(read)")
                            peripheral.readValue(for: characteristic)
                        }else{
                            print("nameのキャラクタリスティック を検出(write)")
                            let namedata: Data? = name.text?.data(using: .utf8)!
                            self.peripheral.writeValue(namedata!, for: charactaristic, type: CBCharacteristicWriteType.withoutResponse)
                        }
                    default:
                        print("指定外のキャラクタリスティック を検出")
                    }
                    self.charactaristic = characteristic
                }
            }
            
        }
        
        //readリクエストにレスポンスが返ってきたら呼び出される
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            switch characteristic.uuid{
            case self.charactaristicUUID_name:
                self.devicename = String(data: characteristic.value!, encoding: .utf8)
                print(self.devicename)
                //readしたら接続をきる
                self.name.text = self.devicename
                self.centralManager.cancelPeripheralConnection(self.peripheral)
            print("切断")
            default:
                print("指定外のキャラクタリスティック のレスポンスを検出")
            }
        }
    
    //wirteリクエストにレスポンスが返ってきたら呼び出される
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print("Write失敗...error:\(error)")
            return
        }
        
        print("Write成功")
        //writeしたら接続をきる
        self.centralManager.cancelPeripheralConnection(self.peripheral)
        self.isdone = false
        print("切断")
    }
    
    //完了ボタン押す
    @IBAction func done(_ sender: Any) {
        self.isdone = true
        self.centralManager.connect(self.peripheral, options: nil)
    }
    //cancelボタン押す
    @IBAction func cancel(_ sender: Any) {
    }
    
   
    
    
    }

