//
//  VideoCell1.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/13/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import UIKit

class VideoCell1: UITableViewCell {
    @IBOutlet var videoImage: UIImageView!
    
    @IBOutlet var primaryTitle: UILabel!
    
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var publishDate: UILabel!
    
    @IBOutlet var duration: UILabel!
    
    @IBOutlet var videoTypeIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
