//
//  PlaylistViewController.swift
//  movies
//
//  Created by Ramon on 07/10/2015.
//  Copyright © 2015 mon. All rights reserved.
//

import UIKit

class PlaylistViewController: UICollectionViewController
{    
    let BASE_URL = "https://www.googleapis.com/youtube/v3/"
    let API_KEY = "AIzaSyCYdOimprNiKNVWcOgWJu-OD8gug1YqRyI"
    
    var videosNext : String?
    var items = [YoutubeItem]()
    
    func downloadVideosData(playlistId: String, videosNext: String)
    {
        
        let channel_url = "playlistItems?part=snippet&maxResults=50&playlistId=\(playlistId)&pageToken=\(videosNext)"
        let s_url = "\(BASE_URL)\(channel_url)&key=\(API_KEY)"
        let url = NSURL(string: s_url)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) ->
            Void in
            
            if error != nil
            {
                print(error.debugDescription)
                return
            }
            
            do
            {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<NSObject, AnyObject>
                let items: AnyObject! = dict!["items"] as AnyObject!
                
                
                if let nextPageToken = dict!["nextPageToken"] {
                    self.videosNext = nextPageToken as? String
                }
                else
                {
                    self.videosNext = nil;
                }
                
                for item in (items as! Array<AnyObject>)
                {
                    let snippet = item["snippet"] as! Dictionary<NSObject, AnyObject>
                    let ytItem = YoutubeItem(item: snippet)
                    self.items.append(ytItem)
                    
                    /*
                    print("Name: \(ytItem.title)")
                    print("Thumbnail: \(ytItem.thumbnailUrl)")
                    print("URL: \(ytItem.createVideoUrl())")
                    print("\n")
                    */
                }
                
                if self.videosNext != nil
                {
                    self.downloadVideosData(playlistId, videosNext: self.videosNext!)
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView!.reloadData()
                    }
                }
                
            } catch
            {
                print("Error gathering data...")
            }
        }
        
        task.resume()
    }
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else { return }
        
        /*
        Add a gradient mask to the collection view. This will fade out the
        contents of the collection view as it scrolls beneath the transparent
        navigation bar.
        */
        collectionView.maskView = GradientMaskView(frame: CGRect(origin: CGPoint.zero, size: collectionView.bounds.size))
        
        self.downloadVideosData(YoutubeManager.sharedInstance.selectedPlaylist, videosNext: "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let collectionView = collectionView, maskView = collectionView.maskView as? GradientMaskView else { return }
        
        /*
        Update the mask view to have fully faded out any collection view
        content above the navigation bar's label.
        */
        maskView.maskPosition.end = topLayoutGuide.length * 0.8
        
        /*
        Update the position from where the collection view's content should
        start to fade out. The size of the fade increases as the collection
        view scrolls to a maximum of half the navigation bar's height.
        */
        let maximumMaskStart = maskView.maskPosition.end + (topLayoutGuide.length * 0.5)
        let verticalScrollPosition = max(0, collectionView.contentOffset.y + collectionView.contentInset.top)
        maskView.maskPosition.start = min(maximumMaskStart, maskView.maskPosition.end + verticalScrollPosition)
        
        /*
        Position the mask view so that it is always fills the visible area of
        the collection view.
        */
        maskView.frame = CGRect(origin: CGPoint(x: 0, y: collectionView.contentOffset.y), size: collectionView.bounds.size)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // The collection view shows all items in a single section.
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    // MARK: UICollectionViewDelegate
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("YoutubeCell", forIndexPath: indexPath) as? YoutubeCell {
            let item = items[indexPath.row]
            
            cell.configureCell(item)
            return cell
        }
        
        return YoutubeCell()
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? YoutubeCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
        let item = items[indexPath.row]
        
        cell.configureCell(item)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        
        YoutubeManager.sharedInstance.selectedVideo = item.title
        self.performSegueWithIdentifier("PlaylistPlayer", sender: self)
    }
}
