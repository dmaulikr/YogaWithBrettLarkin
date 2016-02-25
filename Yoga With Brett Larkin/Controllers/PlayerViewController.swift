//
//  PlayerViewController.swift
//  tvOSNativePlayer
//
//  Created by Martin Normark on 11/09/15.
//  Copyright © 2015 MilkshakeHQ. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class PlayerViewController: AVPlayerViewController {
    let overlayView = UIView(frame: CGRectMake(50, 50, 200, 200))
    
    let VIMEO_TOKEN = "4903940fd8e7f22dbc797778aaea77a9"
    let BASE_URL = "https://api.vimeo.com/me/"
    
    func loadVideo()
    {
        let unsafeChars = NSMutableCharacterSet ()
        unsafeChars.addCharactersInString("'\"")
        YoutubeManager.sharedInstance.selectedVideo = YoutubeManager.sharedInstance.selectedVideo.componentsSeparatedByCharactersInSet(unsafeChars).joinWithSeparator("")
        print("video/")
        print(YoutubeManager.sharedInstance.selectedVideo)
        print("/video")
        let videos_url = "videos/?query=\(YoutubeManager.sharedInstance.selectedVideo)"
        let s_url = "\(BASE_URL)\(videos_url)"
        let url = NSURL(string: s_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        let request = NSMutableURLRequest(URL: url)
        request.setValue("bearer \(VIMEO_TOKEN)", forHTTPHeaderField: "Authorization")
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
          //      let datastring = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<NSObject, AnyObject>
                print(dict)
                let items: AnyObject! = dict!["data"] as AnyObject!
                
                for item in (items as! Array<AnyObject>)
                {
                    for download in (item["download"] as! Array<AnyObject>)
                    {
                        YoutubeManager.sharedInstance.selectedVideo = download["link"] as! String
                        
                        self.player = AVPlayer(URL: NSURL(string: YoutubeManager.sharedInstance.selectedVideo)!)
                        self.player?.play()
                        
                        break
                    }
                    break;
                }
            } catch
            {
                print("Error gathering data...")
            }
        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 200, 70))
        let image = UIImage(named: "watermark")
        imageView.image = image
        overlayView.addSubview(imageView)
        contentOverlayView?.addSubview(overlayView)
        
        loadVideo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
}