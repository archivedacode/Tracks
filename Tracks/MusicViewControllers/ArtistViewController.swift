//
//  ArtistViewController.swift
//  Tracks
//
//  Created by David Ross on 17/06/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistViewController: BaseMusicViewController {
    
    var artists = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchArtists()
        self.tableView.reloadData()
    }
    
    // MARK: - Functions
    
    func fetchArtists() -> Void {
        let query = MPMediaQuery.artists()
        query.addFilterPredicate(predNoCloud)
        query.addFilterPredicate(predNoDRM)
        query.groupingType = MPMediaGrouping.artist
        
        if let artistCollections: [MPMediaItemCollection] = query.collections {
            for artist in artistCollections {
                let artistItem = artist.representativeItem
                artists.add(artistItem!)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaItem = artists[indexPath.row] as! MPMediaItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
        cell.textLabel?.text = mediaItem.artist
        cell.imageView?.image = mediaItem.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
        return cell
    }
}
