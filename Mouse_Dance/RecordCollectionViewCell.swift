//
//  RecordCollectionViewCell.swift
//  Mouse_Dance
//
//  Created by Anh Tuan on 7/25/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit

protocol delegateRecord {
    func touchUpPlay(cell : RecordCollectionViewCell)
    func holdButton(cell : RecordCollectionViewCell)
}

class RecordCollectionViewCell: UICollectionViewCell {
    var delegate : delegateRecord?
    @IBOutlet weak var btn : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        longGesture.minimumPressDuration = 1
        btn.addGestureRecognizer(longGesture)
        
        // Initialization code
    }
    
    func setData(title: String, isExisted : Bool){
        self.btn.setTitle(title, for: .normal)
        
        if ( isExisted){
            self.btn.backgroundColor = UIColor.init(rgba: "#FE9700")
            self.btn.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.btn.backgroundColor = UIColor.white
            self.btn.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    func longPress(){
        if (delegate != nil){
            self.holdButton(self)
        }
    }
    
    @IBAction func holdButton(_ sender: Any) {
        if (delegate != nil){
            delegate?.holdButton(cell: self)
        }
    }

    @IBAction func releaseTouch(_ sender: Any) {
        if (delegate != nil){
            delegate?.touchUpPlay(cell: self)
        }
    }
}
