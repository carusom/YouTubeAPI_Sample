# MyYouTubeAPI_Sample

A simple demonstration of using the "search" and "video" YouTube API's.

This small application demonstrates how to fetch YouTube video content based on a search string, and display the first 10 in a table view. For each table view cell, I visually distinguish the kind of content (channels, playlists and videos) with an icon. Upon selecting a table cell representing a video, a player will open and automatically start playing the video. If a channel table cell is selected, the application will fetch up to 10 videos for that channel.

The code is written in Swift 4 and works in portait and landscape mode. The application utilizes the YouTube "search" and "videos" APIs. It uses Pods for integrating some 3rd party libraries:
	•	Alamofire: For performing the GET requests.
	•	SDWebImage: For fetching and caching the youtube video image thumbnails.
	•	SwiftyJSON: To more easily convert the JSON data.
	•	youtube-ios-player-helper: Written in Objective-C, this loads and plays the video - has UI controls and delegates for monitoring the video progress.
    
Here is a brief description of components created for the application:
	•	Main.storyboard: I define the layout for all the screens via this storyboard. All layout is done via the storyboard. Size classes are also used.
	•	ViewController: Is the initial view controller and houses a search bar and a table view showing video content based on a search string.
	•	YouTubeAPICommon: Constants and enumerations needed throughout the application. You will need to assign "myApiKey" to your specific YouTube API key.
	•	VideoPlayerController: Houses the 3rd party YouTube player.
	•	ChannelController: Table view that lists out videos for a specific channel.
	•	APIUtilities: Singleton that provides any view controller with common fetching functions.
	•	VideoCell1: Nib and Swift file representing a table cell. A separate nib (vs a table cell layout in a storyboard) is more easily reusable throughout the app.
	•	StringExtensions: Has two functions to convert and reformat date/time strings.
