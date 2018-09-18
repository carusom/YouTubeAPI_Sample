//
//  YouTubeAPICommon.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import UIKit

///  Constants and enumerations that support the entire application.

let myApiKey = ""    //Put your own YouTube API key here
let maxResults = 10

public enum YouTubeContentType:String {
    case video = "youtube#video"
    case channel = "youtube#channel"
    case playlist = "youtube#playlist"
}

let videoRowHeight:CGFloat = 140.0
