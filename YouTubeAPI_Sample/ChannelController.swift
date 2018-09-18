//
//  ChannelController.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import UIKit

///  View controller that displays a list of YouTube videos.
class ChannelController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var fetchedContent: [YouTubeContent] = [] {
        didSet {
            if let goodTableView = tableView {
                goodTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "VideoCell1", bundle: Bundle.main), forCellReuseIdentifier: "VideoCell1")
        print("ChannelController viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableFooterView = UIView()   // Removes the irrelevant separator lines below the cells
        
        DispatchQueue.global().async {
            for tmpRow in self.fetchedContent {
                if tmpRow.kind == YouTubeContentType.video {
                    APIUtilities.shared.fetchVideoDuration(videoId: tmpRow.kindId, completion: { (videoDuration, status) in
                        guard status != 0 else {
                            print("error fetching duration")
                            return
                        }
                        
                        tmpRow.duration = videoDuration
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()    // Future work: Maybe just do this on the last row
                        }
                        
                    })
                }
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell1", for: indexPath) as! VideoCell1
        
        let tmpVideo = fetchedContent[indexPath.row]
        
        cell.primaryTitle.text = tmpVideo.title
        cell.subTitle.text = tmpVideo.channelTitle
        
        cell.publishDate.text = "Published " + tmpVideo.publishedAt
        
        cell.videoImage.sd_setImage(with: URL(string: tmpVideo.thumbnailUrl), placeholderImage: #imageLiteral(resourceName: "vidPlaceholder") )
        
        if let duration = tmpVideo.duration {
            cell.duration.isHidden = false
            cell.duration.text = duration
        }
        else {
            cell.duration.isHidden = true
        }
        
        cell.videoTypeIndicator.image = #imageLiteral(resourceName: "typeVideo")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return videoRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tmpRow = fetchedContent[indexPath.row]
        
        let newVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayerController") as! VideoPlayerController
        newVc.title = ""
        newVc.videoInfo = tmpRow
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Videos", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
}

