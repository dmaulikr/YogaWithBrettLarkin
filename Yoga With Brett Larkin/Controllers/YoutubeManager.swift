//
//  YoutubeManager.swift
//  movies
//
//  Created by Ramon on 07/10/2015.
//  Copyright © 2015 mon. All rights reserved.
//

import Foundation

class YoutubeManager
{
    static let sharedInstance = YoutubeManager()
    
    var selectedPlaylist : String!
    var channel : String!
    var selectedVideo : String!
}