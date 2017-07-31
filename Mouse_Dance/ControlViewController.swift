//
//  ControlViewController.swift
//  Mouse_Dance
//
//  Created by Anh Tuan on 7/24/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion
import MediaPlayer
import SwiftyJSON

let TIME_INTERVAL = 0.3

class ControlViewController: UIViewController, UITextFieldDelegate {
    var centralManager : CBCentralManager?
    var connectingPeripheral : CBPeripheral?
    var characterictist : CBCharacteristic?
    var service : CBService?
    var motionManager : CMMotionManager!

    var currentSend : String = ""
    
    var currentTarget : UIButton?
    
    //UI
    @IBOutlet weak var tbl : UITableView!
    
    //Button Connect/ Disconnect
    @IBOutlet weak var btnConnect : UIButton!
    @IBOutlet weak var btnDisConnect : UIButton!
    
    //ButtonDirection
    @IBOutlet weak var btnUp : UIButton!
    @IBOutlet weak var btnDown : UIButton!
    @IBOutlet weak var btnLeft : UIButton!
    @IBOutlet weak var btnRight : UIButton!
    
    //Button Music
    @IBOutlet weak var btnPlay : UIButton!
    @IBOutlet weak var btnPrevious : UIButton!
    @IBOutlet weak var btnNext : UIButton!
    @IBOutlet weak var lblStart :  UILabel!
    @IBOutlet weak var lblEnd : UILabel!
    @IBOutlet weak var viewValue : UIView!
    
    @IBOutlet weak var percentLength: NSLayoutConstraint!
    
    @IBOutlet weak var collectView : UICollectionView!
    
    var currentRecordIndex : Int = 0
    
    var timer : Timer?
    //Button Record
    
    var recordingSession: AVAudioSession!
    
    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    
    //Button Add Music
    @IBOutlet weak var btnAddMusic : UIButton!
    
    //---UI
    //Music
    var mediaPicker : MPMediaPickerController?
    var listSongs = [MPMediaItem]()
    var avplayer : AVAudioPlayer?
    var currentSong : MPMediaItem?
    var currentLength : Int = 0
    var currentIndex : Int = 0
    
    var currentTimeTouchUp : Date?
    
    var currentSendCharacter = ""
    
    var currentDescription : UITextField?
    
    var countTime = 0
    
    @IBOutlet weak var lblNameSong : UILabel!
    //Record
    @IBOutlet weak var viewRecordBG : UIView!
    @IBOutlet weak var viewRecord : UIView!
    @IBOutlet weak var btnRecord : UIButton!
    @IBOutlet weak var lblTimeRecord : UILabel!
    @IBOutlet weak var titleRecord : UILabel!
    
    var timerRecord : Timer?
    var currentIndexRecord : Int = -1
    
    var actionToEnable : UIAlertAction?
    
    var listTitleButton = [String]()
    
    var timerDirection : Timer?
    var firstCha : String = ""
    var secondCha : String = ""
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ///-------------------------------------------------------------------------------------------
        
        ///-------------------------------------------------------------------------------------------
        self.setup()
        
        self.timer?.invalidate()
        
        self.btnPlay.isEnabled = false
        
        self.initRecord(hidden: true)
    }
    
    func dismissRecord(){
        self.initRecord(hidden: true)
    }
    
    func initRecord(hidden : Bool){
        if ( hidden == true) {
            self.lblTimeRecord.text = "00:00"
            self.btnRecord.isEnabled = true
            self.collectView.reloadData()
        }
        
        UIView.animate(withDuration: 2) {
            self.viewRecord.isHidden = hidden
            self.viewRecordBG.isHidden = hidden
        }
        
        self.btnRecord.setBackgroundImage(#imageLiteral(resourceName: "StartRecord"), for: .normal)
    }
    
    func setupRecorder(){
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission({ (allowed) in
                DispatchQueue.main.async {
                    if (allowed) {
                        self.loadRecordingUI()
                    } else {
                        NSLog("Not permission")
                    }
            }
        })
            
        } catch {
                    
        }
    }
    
    func loadRecordingUI(){
        
//        self.btnRecord.setTitle("Tap to Record", for: UIControlState.normal)
        self.btnRecord.addTarget(self, action: #selector(self.recordTapped), for: UIControlEvents.touchUpInside)
    }
    
    func timerRecordRun(){
        let now = Date()
        self.lblTimeRecord.text = "\(now.seconds(from: self.currentTimeTouchUp!))".convertTime()
    }
    
    func startRecording(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(self.currentRecordIndex).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            self.btnRecord.setBackgroundImage(#imageLiteral(resourceName: "PauseRecord-1"), for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    @IBAction func closeRecord(){
        self.initRecord(hidden: true)
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            self.currentTimeTouchUp = Date()
            self.timerRecord = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerRecordRun), userInfo: nil, repeats: true)
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        self.timerRecord?.invalidate()
        if success {
            self.btnRecord.isEnabled = false
            
            
            self.currentDescription = nil
            let alert = UIAlertController(title: "Set Title", message: "Set Title for Record Button ( less than 10 characters )", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter Title"
                self.currentDescription = textField
                self.currentDescription?.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            })
            
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                let text = self.currentDescription?.text ?? ""
                
                self.initRecord(hidden: true)
                if (self.currentRecordIndex != -1){
                    self.listTitleButton[self.currentRecordIndex] = text
                    //
                    self.saveData()
                    //
                    self.currentRecordIndex = -1
                } else {
                    NSLog("Not available")
                }
            })
            
            self.actionToEnable = actionOK
            actionOK.isEnabled = false
            
            alert.addAction(actionOK)
            
            self.present(alert, animated: true, completion: {
                
            })
            
        } else {
            //self.btnRecord.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            try self.recordingSession.setActive(true)
        } catch {
            
        }
        
    }
    
    func saveData(){
        let dataText = self.convertDataToJSON()
        UserDefaults.standard.set(dataText, forKey: "TitleForRecord")
    }
    
    func convertBtnToJSON(item : String) -> String {
        return "{ \"Title\" : \"\(item)\"}"
    }
    
    func convertDataToJSON() -> String{
        var i = 0
        var result = "["
        for item in self.listTitleButton {
            let str = self.convertBtnToJSON(item: item)
            if (i != self.listTitleButton.count - 1) {
                result = result + str + ","
            } else {
                result = result + str + "]"
            }
            i = i + 1
        }
        return result
    }

    
    func textChanged(sender : UITextField){
        let text = sender.text ?? ""
        if ((text.characters.count > 0) && (text.characters.count <= 10)){
            actionToEnable?.isEnabled = true
            self.currentDescription?.textColor = UIColor.black
        } else {
            actionToEnable?.isEnabled = false
            self.currentDescription?.textColor = UIColor.red
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func updateTimer(){
        if (self.avplayer != nil){
            self.lblStart.text = "\(self.avplayer!.currentTime)".convertTime()
            let percent = Double(self.avplayer!.currentTime) / Double(self.currentLength)
            
            self.percentLength = self.percentLength.setMultiplier(multiplier: CGFloat(percent))
            
            self.viewValue.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tbl.reloadData()
    }
    
    func setupInitTitle(){
        let data = UserDefaults.standard.value(forKey: "TitleForRecord") as? String
        NSLog("DataText:  \(data!)")
        let json = JSON.init(parseJSON: data!)
        
        for item in json.array! {
            let title = item["Title"].stringValue
            self.listTitleButton.append(title)
        }
    }
    
    func setup(){
        //self.setupCoreMotion()
        self.setUpBLE()
        self.setupTable()
        
        self.setupInitTitle()
        self.setupRecorder()
        
    }
    //setup
    func setUpBLE(){
        self.centralManager?.delegate = self
        self.connectingPeripheral?.delegate = self
        self.connectingPeripheral?.discoverServices(nil)
    }
    
    func sendStopAfterSecond(){
        self.sendData(str: "S")
    }
    
    func setupCoreMotion(){
        let UPDATE_INTERVAL = 0.1
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = TimeInterval.init(UPDATE_INTERVAL)
        self.motionManager.deviceMotionUpdateInterval = TimeInterval.init(UPDATE_INTERVAL)
        
        self.motionManager.startAccelerometerUpdates()
        self.motionManager.startGyroUpdates()
        
        self.motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            let x = data?.rotationRate.x ?? 0.0
            let y = data?.rotationRate.y ?? 0.0
            let z = data?.rotationRate.z ?? 0.0
            
            let sum = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
            
            if ( sum > 6) {
                if ( z < -5) {
                    //right
                    if( self.currentSendCharacter == "R"){
                        self.changeStatus(nil)
                    } else {
                        NSLog("Right")
                        
                        self.sendData(str: "R")
                        
                        Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                        
                        self.currentSendCharacter = "R"
                        self.changeStatus(self.btnRight)
                    }
                    
                } else if (z > 5) {
                    //Left
                    if ( self.currentSendCharacter == "L"){
                        
                    } else {
                        NSLog("Left")
                        
                        self.sendData(str: "L")
                        
                        Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                        
                        self.currentSendCharacter = "L"
                        self.changeStatus(self.btnLeft)
                    }
                    
                } else {
                    //                        self.sendData(str: "D")
                    let x = self.motionManager.accelerometerData?.acceleration.x ?? 0.0
                    let y = self.motionManager.accelerometerData?.acceleration.y ?? 0.0
                    let z = self.motionManager.accelerometerData?.acceleration.z ?? 0.0
                    
                    
                    let angle = atan2(z, y) * Double(180) / Double.pi
                    
                    if (( y > 0.6) && ( y < 1)) {
                        if ( self.currentSendCharacter == "F"){
                            self.changeStatus(nil)
                        } else {
                            self.sendData(str: "F")
                            Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                            
                            self.currentSendCharacter = "F"
                            self.changeStatus(self.btnUp)
                        }
                    } else if ( (y < -0.6) && ( y > -1)) {
                        if (self.currentSendCharacter == "B"){
                            self.changeStatus(nil)
                        } else {
                            self.sendData(str: "B")
                            Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                            
                            self.currentSendCharacter = "B"
                            self.changeStatus(self.btnDown)
                        }
                    }
                }
            } else {
                let x = self.motionManager.accelerometerData?.acceleration.x ?? 0.0
                let y = self.motionManager.accelerometerData?.acceleration.y ?? 0.0
                let z = self.motionManager.accelerometerData?.acceleration.z ?? 0.0
                
                let angle = atan2(z, y) * Double(180) / Double.pi
                
                if (( y > 0.60) && ( y < 1.1)) {
                    if ( self.currentSendCharacter == "F"){
                        self.changeStatus(nil)
                    } else {
                        self.sendData(str: "F")
                        Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                        
                        self.currentSendCharacter = "F"
                        self.changeStatus(self.btnUp)
                    }
                } else if ( (y < -0.60) && ( y > -1.1)) {
                    if (self.currentSendCharacter == "B"){
                        self.changeStatus(nil)
                    } else {
                        self.sendData(str: "B")
                        Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                        
                        self.currentSendCharacter = "B"
                        self.changeStatus(self.btnDown)
                    }
                } else {
                    self.changeStatus(nil)
                    self.currentSendCharacter = "S"
                }
            }
        }
 
        /*
        self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            let x = data?.acceleration.x ?? 0.0
            let y = data?.acceleration.y ?? 0.0
            let z = data?.acceleration.z ?? 0.0
            
            
            
            let angle = atan2(z, y) * Double(180) / Double.pi
            
            if (( y > 0.5) && ( y < 1)) {
                if ( self.currentSendCharacter == "F"){
                    self.changeStatus(nil)
                } else {
                    self.sendData(str: "F")
                    Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                    
                    self.currentSendCharacter = "F"
                    self.changeStatus(self.btnUp)
                }
            } else if ( (y < -0.5) && ( y > -1)) {
                if (self.currentSendCharacter == "B"){
                    self.changeStatus(nil)
                } else {
                    self.sendData(str: "B")
                    Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                    
                    self.currentSendCharacter = "B"
                    self.changeStatus(self.btnDown)
                }
            } else {
                let gravity = self.motionManager.gyroData?.rotationRate
                
                let x = gravity?.x ?? 0.0
                let y = gravity?.y ?? 0.0
                let z = gravity?.z ?? 0.0
                
                
                let sum = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
                
                if ( sum > 8) {
                    if ( z < -7) {
                        //right
                        if( self.currentSendCharacter == "R"){
                            self.changeStatus(nil)
                        } else {
                            NSLog("Right")
                            
                            self.sendData(str: "R")
                            
                            Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                            
                            self.currentSendCharacter = "R"
                            self.changeStatus(self.btnRight)
                        }
                        
                    } else if (z > 7) {
                        //Left
                        if ( self.currentSendCharacter == "L"){
                            
                        } else {
                            NSLog("Left")
                            
                            self.sendData(str: "L")
                            
                            Timer.scheduledTimer(timeInterval: TIME_INTERVAL, target: self, selector: #selector(self.sendStopAfterSecond), userInfo: nil, repeats: false)
                            
                            self.currentSendCharacter = "L"
                            self.changeStatus(self.btnLeft)
                        }
                        
                    } else {
//                        self.sendData(str: "D")
                        
                        self.currentSendCharacter = "S"
                        self.changeStatus(nil)
                    }
                } else {
//                    self.sendData(str: "D")
                    if ( self.currentSendCharacter == "L"){
                        self.currentSendCharacter = "S"
                    } else if (self.currentSendCharacter == "R"){
                        self.currentSendCharacter = "S"
                    }
                    self.changeStatus(nil)
                }
            }
        }
         */
    }
    
    func setupTable(){
        tbl.separatorColor = UIColor.init(rgba: "#F5F5F5")
        tbl.register(UINib.init(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "SongTableViewCell")
        tbl.tableFooterView = UIView.init(frame: CGRect.zero)
        
        self.collectView.register(UINib.init(nibName: "RecordCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecordCollectionViewCell")
        
        if let layout = self.collectView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    //IBACtion 
        //Coonect/ Disconnect
    @IBAction func connectCar(_ sender : UIButton){
        self.sendData(str: "+CONN")
        self.sendData(str: "3")
    }
    
    @IBAction func disconnectCar(_ sender : UIButton){
        self.sendData(str: "+DISC")
    }
    
        //Music Add
    @IBAction func addMusic(_ sender : UIButton){
        self.mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker?.delegate = self
        mediaPicker?.allowsPickingMultipleItems = true
        mediaPicker?.showsCloudItems = false
        mediaPicker?.prompt = "Please Pick a Song"
        
        self.present(self.mediaPicker!, animated: true) { 
            
        }
    }
    
    //Control Music
    @IBAction func playMusic(_ sender : UIButton){
        if ( self.avplayer != nil){
            if ( self.avplayer?.isPlaying)!{
                self.avplayer?.pause()
                sender.setBackgroundImage(#imageLiteral(resourceName: "Play"), for: .normal)
            } else {
                sender.setBackgroundImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.avplayer?.play()
            }
        }
    }
    
    @IBAction func previousMusic(_ sender : UIButton){
        self.currentIndex = (self.currentIndex - 1 + self.listSongs.count) % self.listSongs.count
        self.playAtIndex(index: self.currentIndex)
    }
    
    @IBAction func nextMusic(_ sender : UIButton){
        self.currentIndex = (self.currentIndex + 1) % self.listSongs.count
        self.playAtIndex(index: self.currentIndex)
    }
    
    //Record
    func sendData(str : String) {
        if ((self.currentSend == "L") || (self.currentSend == "R")){
            if (( str == "F") || (str == "B")) {
                return
            }
        }
        
        self.currentSend = str
        
        if (str == "D"){
            
        } else {
            NSLog("Send: \(str)")
        }
        
        let b = str
        
        let data = b.data(using: String.Encoding.utf8)
        if (data != nil){
            if (self.characterictist != nil){
                self.connectingPeripheral?.writeValue(data!, for: self.characterictist!, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectDevice(_ sender : UIButton){
        self.sendData(str: "+CONN")
        self.sendData(str: "q")
    }
    
    //func setup Direction
    
    func sendByTime(){
        var timeStop = 13
        
        if (self.countTime == 0){
            self.sendData(str: self.firstCha)
        } else  if ( self.countTime == 6){
            self.sendData(str: self.secondCha)
        } else if (( self.countTime == 3) || (self.countTime == 10)){
           self.sendData(str: "S")
        }
        self.countTime = self.countTime + 1
        self.countTime = (self.countTime) % timeStop
    }
    
    func sendByInterval(first : String, right : String){
        self.firstCha = first
        self.secondCha = right
        self.timerDirection = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.sendByTime), userInfo: nil, repeats: true)
    }
    
    func sendByTimeDown(){
        var timeStop = 13
        
        if (self.countTime == 0){
            self.sendData(str: self.firstCha)
        } else  if ( self.countTime == 7){
            self.sendData(str: self.secondCha)
        } else if (( self.countTime == 4) || (self.countTime == 10)){
            self.sendData(str: "S")
        }
        self.countTime = self.countTime + 1
        self.countTime = (self.countTime) % timeStop
    }
    
    func sendDownByInterval(first :String, right : String){
        self.firstCha = first
        self.secondCha = right
        self.timerDirection = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.sendByTimeDown), userInfo: nil, repeats: true)
    }
    
    
    func sendLeftRight(){
        var timeStop = 17
        
        if (self.countTime == 0){
            self.sendData(str: self.firstCha)
        } else  if ( self.countTime == 8){
            self.sendData(str: self.secondCha)
        } else if (( self.countTime == 5) || (self.countTime == 14)){
            self.sendData(str: "S")
        }
        self.countTime = self.countTime + 1
        self.countTime = (self.countTime) % timeStop
    }
    
    func sendLeftInterval(first : String, right : String){
        self.firstCha = first
        self.secondCha = right
        
        self.timerDirection = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.sendLeftRight), userInfo: nil, repeats: true)
    
    }
    
    func sendRightLeft(){
        var timeStop = 17
        
        if (self.countTime == 0){
            self.sendData(str: self.firstCha)
        } else  if ( self.countTime == 9){
            self.sendData(str: self.secondCha)
        } else if (( self.countTime == 5) || (self.countTime == 14)){
            self.sendData(str: "S")
        }
        self.countTime = self.countTime + 1
        self.countTime = (self.countTime) % timeStop
    }
    
    func sendRightInterval(first : String, right : String){
        self.firstCha = first
        self.secondCha = right
        
        self.timerDirection = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.sendRightLeft), userInfo: nil, repeats: true)
    }
    
    @IBAction func pressDirection(_ sender : UIButton){
        self.countTime = 0
        switch sender {
        case btnUp:
            //self.sendData(str: "F")
            self.sendByInterval(first: "F", right: "B")
        case btnDown:
            //self.sendData(str: "B")
            self.sendDownByInterval(first: "B", right: "F")
            //self.sendByInterval(first: "B", right: "F")
            NSLog("Down")
        case btnLeft:
            //self.sendData(str: "J")
            //self.sendData(str: "L")
            self.sendLeftInterval(first: "L", right: "H")
            NSLog("Left")
        case btnRight:
            self.sendRightInterval(first: "R", right: "J")
            //self.sendLeftInterval(first: "R", right: "J")
            //self.sendData(str: "H")
//            self.sendByInterval(first: "R", right: "L")
            NSLog("Right")
        default:
            break
        }
    }
    
    @IBAction func touchUpInsde(_  sender : UIButton){
        self.sendData(str: "D")
        self.timerDirection?.invalidate()
    }
    
    func changeStatus(_ sender : UIButton?){
        if ( self.currentTarget != nil){
            self.currentTarget?.backgroundColor = UIColor.clear
        }
        if ( sender == nil) {
            return
        }
        sender?.backgroundColor = UIColor.init(rgba: "#FFCC80")
        self.currentTarget = sender
    }
}

extension ControlViewController : CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if (error != nil) {
            let alertVC = UIAlertController(title: "Warning", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
                self.centralManager?.cancelPeripheralConnection(self.connectingPeripheral!)
            }
            alertVC.addAction(alertAction)
            self.show(alertVC, sender: nil)
        }
        
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let uuid = CBUUID.init(string: CharacterisTicDefine.ffe1)
        if (central.retrieveConnectedPeripherals(withServices: [uuid])).count == 0 {
            
            let alertVC = UIAlertController(title: "Warning", message: "Disconnected", preferredStyle: UIAlertControllerStyle.alert)
            self.show(alertVC, sender: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
}

extension ControlViewController : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            NSLog("Services: \(service.uuid.uuidString)")
            let thisService = service as CBService
            if (thisService.uuid.uuidString.lowercased().contains(SeriveDefine.Service.lowercased())){
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            NSLog("Error \(error?.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics! {
            NSLog("Characteristic of (\(service.uuid.uuidString))" + characteristic.uuid.uuidString)
            if (characteristic.uuid.uuidString.lowercased().contains(CharacterisTicDefine.ffe1.lowercased())){
                NSLog("Notify Cener")
                self.connectingPeripheral?.setNotifyValue(true, for: characteristic)
                self.characterictist = characteristic
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("Update state Notification  \(characteristic.isNotifying)   \(characteristic.uuid.uuidString)")
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let a = String.init(data: characteristic.value!, encoding: String.Encoding.ascii)
    }
}

extension ControlViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell") as! SongTableViewCell
        let obj = self.listSongs[indexPath.row]
        cell.setData(song: obj)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.playAtIndex(index: indexPath.row)
        
    }
    
    func playAtIndex(index : Int){
        self.btnPlay.isEnabled = true
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        let obj = self.listSongs[index]
        self.currentSong = obj
        self.lblEnd.text = "\(obj.playbackDuration)".convertTime()
        self.currentLength = ("\(obj.playbackDuration)"as NSString).integerValue
        
        let urlAsset = AVURLAsset.init(url: obj.assetURL!)
        
        self.currentIndex = index
        
        do {
            self.avplayer = try AVAudioPlayer.init(contentsOf: obj.assetURL!)
            self.avplayer?.delegate = self
        } catch {
            
        }
        
        self.setUpPlaySong()
    
    }
    
    func setUpPlaySong(){
        AudioPlayerManager.shared.pause()
        self.avplayer?.play()
        self.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        self.lblNameSong.text = self.currentSong?.title
        self.lblStart.text = "00:00"
    }
}

extension ControlViewController : MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        NSLog("Pick Item")
        for item in mediaItemCollection.items {
            print("Add \(item.title ?? "") to a playlist, prep the player, etc")
            self.listSongs.append(item)
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        self.tbl.reloadData()
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        NSLog("Cancel")
    }
}

extension ControlViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NSLog("Finish Cmnr")
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension ControlViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordCollectionViewCell", for: indexPath) as! RecordCollectionViewCell
        cell.delegate = self
        //cell.setData(index: indexPath.row + 1, isExisted: self.isExisted(index: indexPath.row))
        let title = self.listTitleButton[indexPath.row]
        cell.setData(title: title, isExisted: self.isExisted(index: indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize.init(width: height, height: height)
    }
    
}

extension ControlViewController : delegateRecord {
    func isExisted(index: Int) -> Bool {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        url = url.appendingPathComponent("recording\(index).m4a")
        if FileManager.default.fileExists(atPath: url.path){
            return true
        } else {
            return false
        }
    }
    func touchUpPlay(cell: RecordCollectionViewCell) {
        let index = self.collectView.indexPath(for: cell)
        
        if (self.avplayer != nil) {
            self.avplayer?.pause()
            self.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
        
        
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        url = url.appendingPathComponent("recording\(index!.row).m4a")
        if FileManager.default.fileExists(atPath: url.path){
            let path = AudioPlayerManager.shared.audioFIleInUserDocuments(fileName: "recording\(index!.row)")
            AudioPlayerManager.shared.play(path: path)
        }
    }
    
    func holdButton(cell: RecordCollectionViewCell) {
        let index = self.collectView.indexPath(for: cell)
        self.currentRecordIndex = (index?.row)!
        if (self.viewRecordBG.isHidden == false){
            return
        }
        self.setupRecorder()
        self.currentRecordIndex = index!.row
        
        let text = self.listTitleButton[self.currentRecordIndex]
        
        self.titleRecord.text = "Button: \(text)"
        self.avplayer?.pause()
        self.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "Play"), for: .normal)
        
        self.initRecord(hidden: false)
    }
}

extension ControlViewController : AVAudioRecorderDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //println("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            self.finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        //   println("Audio Record Encode Error")
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
