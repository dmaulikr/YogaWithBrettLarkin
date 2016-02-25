//
//  YoutubeItem.swift
//  movies
//
//  Created by Ramon on 06/10/2015.
//  Copyright © 2015 mon. All rights reserved.
//

import Foundation

class YoutubeItem
{
    var id : String?
    var title : String!
    var description : String!
    var thumbnailUrl : String!
    
    init(item : Dictionary<NSObject, AnyObject>)
    {
        self.title = item["title"] as! String
        self.description = item["description"] as! String
        if item["thumbnails"] != nil
        {
            
            let thumbnails = item["thumbnails"] as! Dictionary<NSObject, AnyObject>
            let default_thumbnail :Dictionary<NSObject, AnyObject>;
            
            if thumbnails["standard"] != nil
            {
                default_thumbnail = thumbnails["standard"] as! Dictionary<NSObject, AnyObject>
                self.thumbnailUrl = default_thumbnail["url"] as! String
            }
            else
            {
                if thumbnails["default"] != nil
                {
                    default_thumbnail = thumbnails["default"] as! Dictionary<NSObject, AnyObject>
                    self.thumbnailUrl = default_thumbnail["url"] as! String
                }
            }
        }
 
        if let resource = item["resourceId"] as? Dictionary<NSObject, String>
        {
            self.id = resource["videoId"]
        }
    }
    
    func createVideoUrl() -> String
    {
        return "https://www.youtube.com/watch?v=\(self.id)"
    }
}
