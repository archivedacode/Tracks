//
//  SongViewController.swift
//  Tracks
//
//  Created by David Ross on 17/06/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit
import MediaPlayer

class SongViewController: BaseMusicViewController {
    
    var songs = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchSongs()
        self.tableView.reloadData()
    }
    
    // MARK: - Functions
    
    func fetchSongs() -> Void {
        
        let query = MPMediaQuery.songs()
        query.addFilterPredicate(predNoCloud)
        query.addFilterPredicate(predNoDRM)
        query.groupingType = MPMediaGrouping.title
        
        if let songItems: [MPMediaItem] = query.items {
            songs.addObjects(from: songItems)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaItem = songs[indexPath.row] as! MPMediaItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        cell.textLabel?.text = mediaItem.title
        cell.detailTextLabel?.text = mediaItem.artist
        cell.imageView?.image = mediaItem.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pvc = PlayerViewController.shared
        pvc.updateItems(mediaItems: songs, with: indexPath.row)
        self.navigationController?.pushViewController(pvc, animated: true)
    }
    
}
