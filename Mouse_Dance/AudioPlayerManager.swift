//
//  AudioPlayerManager.swift
//  AudioRecorder
//
//  Created by Anh Tuan on 7/24/17.
//  Copyright © 2017 Jad Habal. All rights reserved.
//

import Foundation
import AVFoundation

extension Notification.Name {
    static let AudioPlayerDidFInishPlayingAudioFile = Notification.Name("AudioPlayerDidFInishPlayingAudioFile")
}

class AudioPlayerManager : NSObject {
    static let shared = AudioPlayerManager()
    
    override init() {
        super.init()
        
        do {            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category PlayBakc OK")
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAduioSession is Active")
            } catch {
                print("Error activating Session", error.localizedDescription)
            }
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    var isPlaying = false
    var isFinished = false
    
    var lastPath : String?
    
    private var currentPlayer : AVAudioPlayer?
    
    func play(path: String){
        let url = URL.init(string: path)
        
        if lastPath == path && isFinished == false {
            self.currentPlayer?.play()
            return
        }
        
        do {
            self.currentPlayer = try AVAudioPlayer(contentsOf: url!)
            self.currentPlayer?.delegate = self
            self.currentPlayer?.play()
            isPlaying = true
            self.isFinished = false
            self.lastPath = url?.path
            
        } catch {
            print("Error loading file", error.localizedDescription)
        }
    }
    
    func pause(){
        isPlaying = false
        self.currentPlayer?.pause()
    }
    
    func audioFIleInUserDocuments(fileName : String) -> String {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return url.appendingPathComponent(fileName+".m4a").path
    }
}

extension AudioPlayerManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isFinished = true
        isPlaying = false
        
        NotificationCenter.default.post(name: NSNotification.Name.AudioPlayerDidFInishPlayingAudioFile, object: nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        NSLog("\(error?.localizedDescription)")
    }
}
