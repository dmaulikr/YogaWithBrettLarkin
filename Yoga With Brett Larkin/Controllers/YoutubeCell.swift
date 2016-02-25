//
//  YoutubeCell.swift
//  movies
//
//  Created by Ramon on 06/10/2015.
//  Copyright © 2015 mon. All rights reserved.
//

import UIKit

class YoutubeCell: UICollectionViewCell
{
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configureCell(item: YoutubeItem)
    {
        label.text = item.title
        if item.thumbnailUrl != nil
        {
            let url = NSURL(string: item.thumbnailUrl)!
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                {
                    let data = NSData(contentsOfURL: url)!
                    dispatch_async(dispatch_get_main_queue())
                        {
                            let img = UIImage(data: data)
                            self.thumbnail.image = img
                            self.thumbnail.contentMode = UIViewContentMode.ScaleAspectFit
                    }
            }
        }
    }
}