//
//  StringExtensions.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import Foundation

extension String {
    
    /**
     * Converts YouTube-formatted duration string into a more human-readable string.
     */
    func convertYoutubeDuration() -> String {
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
    }
    
    /**
     * Reformats a date string of a specific format into a more human-readable string.
     */
    func reformatDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let newDate = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        if let goodDate = newDate {
            let tmpDate = dateFormatter.string(from: goodDate)
            return tmpDate
        }
        else {
            return nil
        }
    }
}

