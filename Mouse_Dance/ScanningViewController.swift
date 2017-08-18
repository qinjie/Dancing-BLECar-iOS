//
//  ScanningViewController.swift
//  Mouse_Dance
//
//  Created by Anh Tuan on 7/24/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit
import CoreBluetooth

let timerScanInterval : Int = 2

struct SeriveDefine {
    static let InformationService = "180A"
    static let Service = "FFF0"
}
struct CharacterisTicDefine {
    static let ffe1 = "FFF1"
}



class Peripheral {
    var obj : CBPeripheral
    var data : [String : Any]
    var rssi : Int
    init(obj : CBPeripheral, data : [String:Any], rssi : Int) {
        self.obj = obj
        self.data = data
        self.rssi = rssi
    }
}

class ScanningViewController: UIViewController {
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var tableView : UITableView!
    var peripherals = [Peripheral]()
    var connectingPeripheral : CBPeripheral?
    var centralManager:CBCentralManager!
    var keepScanning :Bool = false
    var state : String = "Nothing"
    var currentcharacteristtic : CBCharacteristic?
    
    var startConnecting = Date()
    
    var timerCheck : Timer? = nil

    var currentTimer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ScanningViewController.refresher), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
        tableView.register(UINib.init(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(rgba: "#1565C0")
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
        
        self.title = "Scanner"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.peripherals.removeAll()
        self.tableView.reloadData()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        if (!self.centralManager.isScanning){
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SeriveDefine.Service)], options: nil)
        }
        
        self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SeriveDefine.Service)], options: nil)
    }
    
    func refresher() {
        
        self.peripherals.removeAll()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
        self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SeriveDefine.Service)], options: nil)
        
    }
    
    func getTimeConnect(){
        let now = Date()
        let seconds = now.seconds(from: self.startConnecting)
        
        if (seconds >= 5){
            if (self.connectingPeripheral != nil){
                self.centralManager.cancelPeripheralConnection(self.connectingPeripheral!)
            }
            
            self.peripherals.removeAll()
            self.tableView.reloadData()
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SeriveDefine.Service)], options: nil)
            
            self.timerCheck?.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func pauseScan(){
        
    }
    
}


extension ScanningViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            keepScanning = true
            
            _ = Timer(timeInterval: TimeInterval(timerScanInterval), target: self, selector: #selector(ScanningViewController.pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: [CBUUID.init(string: SeriveDefine.Service)], options: nil) //search with any Service
        //typical, we should add service for find exactly what you want
        case .poweredOff:
            state = "Bluethooth on this device is currently powered off"
            
            self.peripherals.removeAll()
            self.tableView.reloadData()
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        default:
            break
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var isContain = false
        for item in self.peripherals {
            let obj = item.obj
            if (obj == peripheral) {
                isContain = true
                break
            }
        }
        
        if (isContain == false) {
            self.peripherals.append(Peripheral(obj: peripheral, data: advertisementData, rssi : RSSI as! Int))
            self.tableView.reloadData()
            
        }
    }
}

extension ScanningViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell") as! DeviceTableViewCell
        let peripheral = self.peripherals[indexPath.row]
        cell.setData(periphal: peripheral.obj, rssi: peripheral.rssi)
        //        cell.setData(periphal: peripheral.obj)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NSLog("Try to connect")
        self.startConnecting = Date()
        
        let peripheral = self.peripherals[indexPath.row].obj
        
        self.timerCheck = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getTimeConnect), userInfo: nil, repeats: true)
        
        
        self.connectingPeripheral = peripheral
        
        //self.connectingPeripheral?.delegate = self
        self.centralManager.connect(self.connectingPeripheral!, options: nil)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.timerCheck?.invalidate()
        NSLog("Connecting to device is ready")
        
        
        let uic = ControlViewController(nibName: "ControlViewController", bundle: nil)        
        uic.centralManager = self.centralManager
        uic.connectingPeripheral = peripheral
        self.present(uic, animated: true) {
            
        }
        //        self.navigationController?.pushViewController(displayVC, animated: true)
        //peripheral.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("Connect is fail")
    }
}
extension ScanningViewController : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("Discover_____Services")
        for service in peripheral.services! {
            let thisService = service as CBService
            NSLog("Service-------------- \(thisService.uuid)   -   \(thisService.uuid.uuidString)")
            if (thisService.uuid.uuidString.lowercased().contains(SeriveDefine.Service.lowercased())){ //Temperature
                NSLog("------------------ Find to Discover")
                peripheral.discoverCharacteristics(nil, for: thisService)
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        NSLog("-------------DidDiscoverCharacteris")
        if error != nil {
            NSLog("Error \(error?.localizedDescription)")
            return
        }
        var enableValue = "Ahihi"
        let enableBytes = enableValue.data(using: String.Encoding.utf8)
        
        
        
        for characteristic in service.characteristics! {
            NSLog("Characteristic------------\(characteristic.uuid.uuidString)")
            if (characteristic.uuid.uuidString.lowercased().contains(CharacterisTicDefine.ffe1.lowercased())){
                NSLog("Notify Cener")
                self.currentcharacteristtic = characteristic
                self.connectingPeripheral?.writeValue(enableBytes!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                //self.connectingPeripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            NSLog("\(error.debugDescription)")
        }
        if (characteristic.value != nil){
            let a = String.init(data: characteristic.value!, encoding: String.Encoding.utf8)
            NSLog("\(a)")
        }
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("Update state Notification  \(characteristic.isNotifying)   \(characteristic.uuid.uuidString)")
    }
    
}

