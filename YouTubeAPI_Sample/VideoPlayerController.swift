//
//  VideoPlayerController.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper
import AVFoundation

///  Loads and plays a YouTube video.
class VideoPlayerController: UIViewController {
    @IBOutlet var playerView: YTPlayerView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var videoInfo:YouTubeContent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VideoPlayerController viewDidLoad")
        
        // Allow sound to be heard even if mute button is on
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("Error setting Category for AVAudioSessionCategoryPlayback")
        }
        
        guard let goodVideoInfo = videoInfo else {
            // just exit out of this and back to video list
            print("exiting out")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        // Below type check might be redundant, but leave it in for now
        if goodVideoInfo.kind == YouTubeContentType.video {
            print("valid video")
            loadingIndicator.startAnimating()
            playerView.load(withVideoId: goodVideoInfo.kindId)
        }
        else {
            // exit out of here
            print("exiting out wrong kind")
            self.navigationController?.popViewController(animated: true)
        }
        
        playerView.delegate = self
    }
}

// MARK: - YTPlayerViewDelegate
extension VideoPlayerController:YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("Player View is Ready")
        loadingIndicator.isHidden = true
        playerView.playVideo()
    }
}

