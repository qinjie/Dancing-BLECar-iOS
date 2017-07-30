//
//  DeviceTableViewCell.swift
//  BLEProject
//
//  Created by Anh Tuan on 6/23/17.
//  Copyright © 2017 Anh Tuan. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblDistance : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(periphal : CBPeripheral , rssi : Int){
        self.lblName.text = periphal.name ?? "N/A"
        self.lblDistance.text = "\(rssi)"
    }
    
}
