//
//  SongTableViewCell.swift
//  Mouse_Dance
//
//  Created by Anh Tuan on 7/25/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit
import MediaPlayer

extension String {
    func convertTime() -> String {
        let value = Int((self as NSString).doubleValue)
        let minutes = value / 60
        let second = value % 60
        
        var minStr = "00"
        if (minutes == 0) {
            
        } else if ( minutes < 10) {
            minStr = "0\(minutes)"
        } else if (minutes >= 10) {
            minStr = "\(minutes)"
        }
        
        var secondStr = "00"
        
        if (second == 0){
            
        } else if (second < 10) {
            secondStr = "0\(second)"
        } else if ( second >= 10){
            secondStr = "\(second)"
        }
        
        return minStr + ":" + secondStr
    }
}

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var imgThumb : UIImageView!
    
    @IBOutlet weak var lblLength : UILabel!
    
    @IBOutlet weak var lblTitle : UILabel!
    
    @IBOutlet weak var lblAuthor : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(song : MPMediaItem){
        self.lblTitle.text = song.title
        self.lblAuthor.text = song.artist
        if (song.artwork == nil){
            self.imgThumb.image = #imageLiteral(resourceName: "PlaceHolder")
        } else {
            self.imgThumb.image = song.artwork?.image(at: CGSize.init(width: 50, height: 50))
        }
        self.lblLength.text = "\(song.playbackDuration)".convertTime()
    }
    
    
    
}
