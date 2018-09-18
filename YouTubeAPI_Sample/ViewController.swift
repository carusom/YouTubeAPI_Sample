//
//  ViewController.swift
//  YouTubeAPI_Sample
//
//  Created by Michael Caruso on 9/18/18.
//  Copyright © 2018 Michael Caruso. All rights reserved.
//

import UIKit
import SDWebImage

///  Initial view controller that presents a search bar, and displays a list of
///  YouTube Channels, Playlists and Videos based on the search string results.
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var searchBar: UISearchBar!
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
        
        self.navigationItem.title = "My YouTube"
        
        searchVideos(searchString: "Palawan")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableFooterView = UIView()   // Removes the irrelevant separator lines below the cells
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
        
        if tmpVideo.kind == YouTubeContentType.video {
            cell.videoTypeIndicator.image = #imageLiteral(resourceName: "typeVideo")
            cell.subTitle.isHidden = false
        }
        else if tmpVideo.kind == YouTubeContentType.channel {
            cell.videoTypeIndicator.image = #imageLiteral(resourceName: "typeChannel")
            cell.subTitle.isHidden = true
        }
        else {
            cell.videoTypeIndicator.image = #imageLiteral(resourceName: "typePlaylist")
            cell.subTitle.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return videoRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tmpRow = fetchedContent[indexPath.row]
        
        if tmpRow.kind == YouTubeContentType.video {
            let newVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayerController") as! VideoPlayerController
            newVc.title = ""
            newVc.videoInfo = tmpRow
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Videos", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(newVc, animated: true)
        }
        else if tmpRow.kind == YouTubeContentType.channel {
            // open a ChannelController
            APIUtilities.shared.fetchVideoContentForChannel(channelId: tmpRow.kindId) { (newVideoSearchResults, status) in
                guard status != 0 else {
                    print("error fetching videos for channel")
                    // Can display something to the user here
                    return
                }
                
                guard let newContentList = newVideoSearchResults else {
                    print("newVideoSearchResults is nil")
                    return
                }
                
                let newVc = self.storyboard?.instantiateViewController(withIdentifier: "ChannelController") as! ChannelController
                newVc.title = ""
                newVc.fetchedContent = newContentList
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Videos for Channel", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(newVc, animated: true)
                
                /*
                 for tmpRow in newContentList {
                 //  print("title: \(tmpRow.title)  duration: \(tmpRow.duration ?? "NOT FOUND")")
                 print("CHANNEL VIDEO ---> title: \(tmpRow.title)  duration: \(tmpRow.duration ?? "nf")  ")
                 }
                 */
            }
        }
        else {
            // Display message that the video type is not implemented
            let alert = UIAlertController(title: "Playlists", message: "Displaying playlist videos is not yet implemented", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    private func searchVideos(searchString:String) {
        print("searchVideos...")
        
        if !searchString.isEmpty {
            APIUtilities.shared.fetchVideoContentWithString(searchString: searchString)  { (newVideoSearchResults, status) in
                guard status != 0 else {
                    print("error fetching videos")
                    // Can display something to the user here
                    return
                }
                
                guard let newContentList = newVideoSearchResults else {
                    print("newVideoSearchResults is nil")
                    return
                }
                
                self.fetchedContent = newContentList
                
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
                
                /*
                 for tmpRow in self.fetchedContent{
                 //  print("title: \(tmpRow.title)  duration: \(tmpRow.duration ?? "NOT FOUND")")
                 print("0title: \(tmpRow.title)  duration: \(tmpRow.duration ?? "nf")  ")
                 }
                 */
            }
        }
        else {
            print("searchString is empty")
        }
    }     // searchVideos
}

// MARK: - UISearchBarDelegate
extension ViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        
        guard let goodString = searchBar.text else {
            return
        }
        
        let cleanedString = goodString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cleanedString.count > 0 {
            print("cleanedString>\(cleanedString)<")
            searchBar.text = cleanedString
            searchVideos(searchString: cleanedString)
            searchBar.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        searchBar.text  = ""
        searchBar.endEditing(true)
    }
}
