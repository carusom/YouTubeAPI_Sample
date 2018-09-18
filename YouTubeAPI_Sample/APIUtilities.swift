//
//  APIUtilities.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

protocol NetworkRequest {
    func performNetworkRequest(
        _ url: URL,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?,
        completion: @escaping (JSON?, Error?) -> Void)
        -> Void
}

///  Collection of utilities for performing HTTP requests.
class APIUtilities {
    static let shared = APIUtilities()
    
    let stdUrl = "https://www.googleapis.com/youtube/v3/search"
    let videoUrl = "https://www.googleapis.com/youtube/v3/videos"
    
    /**
     * Fetches the duration for a specific YouTube video and returns a user-readable version.
     *
     * - parameters:
     *      - videoId: String representing a specific video identifier
     *      - completion: Completion handler with a string describing the video duration and success status (0=error, 1=success)
     */
    func fetchVideoDuration(videoId:String, completion: @escaping (String?, Int)->()) {
        print("fetchVideoDuration for id \(videoId)")
        
        let parameters: [String: Any] = [ "part": "contentDetails",
                                          "id": videoId,
                                          "key": myApiKey ]
        
        guard let baseUrl = URL(string: videoUrl) else {
            print("videoUrl is nil")
            return
        }
        
        performNetworkRequest(baseUrl, method: .get, parameters: parameters, headers: nil) { (jsonPayload, error) in
            guard error == nil else {
                print("performNetworkRequest ERROR")
                completion(nil,0)
                return
            }
            
            guard let goodPayload = jsonPayload else {
                print("performNetworkRequest ERROR - payload nil")
                completion(nil,0)
                return
            }
            
            let rawVideoDuration = goodPayload["items"][0]["contentDetails"]["duration"].stringValue
            
            completion(rawVideoDuration.convertYoutubeDuration(), 1)
        }     // performNetworkRequest
    }     //  fetchVideoDuration
    
    /**
     * Performs a fetch for YouTube content based on a search string.
     * If successful, an array is populated with YouTubeContent objects, else nil.
     *
     * - parameters:
     *      - searchString: String used to search for YouTube content (videos, playlists, channels)
     *      - completion: Completion handler with an array of YouTubeContent objects and success status (0=error, 1=success)
     */
    func fetchVideoContentWithString(searchString:String, completion: @escaping ([YouTubeContent]?, Int)->() ) {
        print("fetchVideoContentWithString \(searchString)")
        
        let parameters: [String: Any] = [ "part": "snippet",
                                          "maxResults": String(maxResults),
                                          "q": searchString,
                                          "key": myApiKey ]
        
        guard let baseUrl = URL(string: stdUrl) else {
            print("stdUrl is nil")
            return
        }
        
        performNetworkRequest(baseUrl, method: .get, parameters: parameters, headers: nil) { (jsonPayload, error) in
            guard error == nil else {
                print("performNetworkRequest ERROR")
                completion(nil,0)
                return
            }
            
            guard let goodPayload = jsonPayload else {
                print("performNetworkRequest ERROR - payload nil")
                completion(nil,0)
                return
            }
            
            if let dataArray = goodPayload["items"].array {
                var fetchedContent = [YouTubeContent]()
                
                for tmpRow in dataArray {
                    let kindString = tmpRow["id"]["kind"].stringValue
                    
                    var kind:YouTubeContentType = YouTubeContentType.playlist
                    var kindId = ""
                    
                    if kindString == YouTubeContentType.video.rawValue {
                        kind = YouTubeContentType.video
                        kindId = tmpRow["id"]["videoId"].stringValue
                    }
                    else if kindString == YouTubeContentType.channel.rawValue {
                        kind = YouTubeContentType.channel
                        kindId = tmpRow["id"]["channelId"].stringValue
                    }
                    else {
                        kindId = tmpRow["id"]["playlistId"].stringValue
                    }
                    
                    let newVideo = YouTubeContent.init(kind: kind,
                                                       kindId: kindId,
                                                       
                                                       etag: tmpRow["etag"].stringValue,
                                                       
                                                       publishedAt: tmpRow["snippet"]["publishedAt"].stringValue.reformatDate() ?? "",
                                                       channelId: tmpRow["snippet"]["channelId"].stringValue,
                                                       title: tmpRow["snippet"]["title"].stringValue,
                                                       desc: tmpRow["snippet"]["description"].stringValue,
                                                       thumbnailUrl: tmpRow["snippet"]["thumbnails"]["high"]["url"].stringValue,  // Future: Use different quality based on bandwidth and/or device
                        channelTitle: tmpRow["snippet"]["channelTitle"].stringValue)
                    
                    fetchedContent.append(newVideo)
                }
                
                //     for tmpVideo in fetchedContent {
                //        print("fetched Video Content row: \(tmpVideo.title) for id: \(tmpVideo.videoId) and duration: \(tmpVideo.duration ?? "not found")")
                //   }
                
                completion(fetchedContent,1)
            }
        }     // performNetworkRequest
    }     //  fetchVideoContentWithString
    
    /**
     * Performs a fetch for YouTube content based on channel id.
     * If successful, an array is populated with YouTubeContent objects (videos only), else nil.
     *
     * - parameters:
     *      - channelId: String representing a specific YouTube channel identifier
     *      - completion: Completion handler with an array of YouTubeContent objects and success status (0=error, 1=success)
     */
    func fetchVideoContentForChannel(channelId:String, completion: @escaping ([YouTubeContent]?, Int)->() ) {
        print("fetchVideoContentForChannel \(channelId)")
        
        let parameters: [String: Any] = [ "part": "snippet",
                                          "maxResults": String(maxResults),
                                          "channelId": channelId,
                                          "key": myApiKey ]
        
        guard let baseUrl = URL(string: stdUrl) else {
            print("stdUrl is nil")
            return
        }
        
        performNetworkRequest(baseUrl, method: .get, parameters: parameters, headers: nil) { (jsonPayload, error) in
            guard error == nil else {
                print("performNetworkRequest ERROR")
                completion(nil,0)
                return
            }
            
            guard let goodPayload = jsonPayload else {
                print("performNetworkRequest ERROR - payload nil")
                completion(nil,0)
                return
            }
            
            if let dataArray = goodPayload["items"].array {
                var fetchedContent = [YouTubeContent]()
                
                for tmpRow in dataArray {
                    
                    let kindString = tmpRow["id"]["kind"].stringValue
                    
                    var kind:YouTubeContentType = YouTubeContentType.playlist
                    var kindId = ""
                    
                    if kindString == YouTubeContentType.video.rawValue {
                        kind = YouTubeContentType.video
                        kindId = tmpRow["id"]["videoId"].stringValue
                        
                        let newVideo = YouTubeContent.init(kind: kind,
                                                           kindId: kindId,
                                                           
                                                           etag: tmpRow["etag"].stringValue,
                                                           
                                                           publishedAt: tmpRow["snippet"]["publishedAt"].stringValue.reformatDate() ?? "",
                                                           channelId: tmpRow["snippet"]["channelId"].stringValue,
                                                           title: tmpRow["snippet"]["title"].stringValue,
                                                           desc: tmpRow["snippet"]["description"].stringValue,
                                                           thumbnailUrl: tmpRow["snippet"]["thumbnails"]["high"]["url"].stringValue,  // Future: Use different quality based on bandwidth and/or device
                            channelTitle: tmpRow["snippet"]["channelTitle"].stringValue)
                        
                        fetchedContent.append(newVideo)
                    }
                }
                
                //     for tmpVideo in fetchedContent {
                //        print("-------------------------------------------")
                //        print("fetched Video Content row: \(tmpVideo.title) for id: \(tmpVideo.videoId) and duration: \(tmpVideo.duration ?? "not found")")
                //   }
                
                completion(fetchedContent,1)
            }
        }     // performNetworkRequest
    }     //  fetchVideoContentForChannel
}

// MARK: - extension NetworkRequest
extension APIUtilities: NetworkRequest {
    func performNetworkRequest(_ url: URL, method: HTTPMethod, parameters: [String : Any]?, headers: [String : String]?, completion: @escaping (JSON?, Error?) -> Void) {
        print("performNetworkRequest")
        Alamofire.request(
            url,
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { (response) in
                //print(">>>> \(response.request)")  // original URL request
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        //  print("result values: \(value)")
                        completion(JSON(value), nil)
                    }
                    else {
                        completion(nil,nil)
                    }
                case .failure(let error):
                    print("Error \(error.localizedDescription)")
                    completion(nil, error)
                }
        }
        
    }    // performNetworkRequest
}
