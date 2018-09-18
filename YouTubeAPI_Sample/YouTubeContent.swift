//
//  YouTubeContent.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import Foundation

class YouTubeContent: NSObject {
    var kind: YouTubeContentType
    var kindId: String
    
    var etag: String
    
    // Snippet info
    var publishedAt: String      // On cell
    var channelId: String   // Any content type has a channelId
    var title: String      // On cell
    var desc: String
    var thumbnailUrl: String     // On cell

    var channelTitle: String   // On cell  - // Any content type has a channelTitle
    
    var duration: String?     // On cell
    
    init(kind:YouTubeContentType, kindId:String, etag:String,  publishedAt:String, channelId:String, title:String, desc:String, thumbnailUrl:String, channelTitle:String ) {
        self.kind = kind
        self.kindId = kindId
        
        self.etag = etag
        
        self.publishedAt = publishedAt
        self.channelId = channelId
        self.title = title
        self.desc = desc
        self.thumbnailUrl = thumbnailUrl
        self.channelTitle = channelTitle
    }
}

