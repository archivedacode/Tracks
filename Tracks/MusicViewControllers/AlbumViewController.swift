//
//  AlbumViewController.swift
//  Tracks
//
//  Created by David Ross on 17/06/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: BaseMusicViewController {

    var albums = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAlbums()
        self.tableView.reloadData()
    }
    
    // MARK: - Functions
    
    func fetchAlbums() -> Void {
        let query = MPMediaQuery.albums()
        query.addFilterPredicate(predNoCloud)
        query.addFilterPredicate(predNoDRM)
        query.groupingType = MPMediaGrouping.album
        
        if let albumCollections: [MPMediaItemCollection] = query.collections {
            for album in albumCollections {
                let albumItem = album.representativeItem
                albums.add(albumItem!)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaItem = albums[indexPath.row] as! MPMediaItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
        cell.textLabel?.text = mediaItem.albumTitle
        cell.imageView?.image = mediaItem.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
        return cell
    }
}
