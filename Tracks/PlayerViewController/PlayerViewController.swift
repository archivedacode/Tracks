//
//  PlayerViewController.swift
//  Tracks
//
//  Created by David Ross on 04/07/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController, AudioPlayerDelegate {
    
    static let shared = PlayerViewController()
    
    let player = AudioPlayer()
    
    var loop = Bool(false)
    var trackPosition = Int(0)
    var tracks = NSMutableArray()
    var refreshItems = Bool(false)
    
    // MARK: - Outlets
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnLoop: UIButton!
    @IBOutlet weak var sliderSeek: UISlider!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sliderGain: UISlider!

    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = [];
        self.player.delegate = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.refreshItems) {
            self.playItem(at: self.trackPosition)
            self.refreshItems = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func back(sender: UIButton?) {
        trackPosition -= 1;
        if (trackPosition < 0) {
            trackPosition = tracks.count-1;
        }
        self.playItem(at: trackPosition)
    }
    
    @IBAction func play(sender: UIButton?) {
        if (self.player.isPlaying()) {
            self.player.pause()
            self.btnPlay.isSelected = false
        }
        else {
            self.player.play()
            self.btnPlay.isSelected = true
        }
    }
    
    @IBAction func next(sender: UIButton?) {
        trackPosition += 1;
        
        if (loop) {
            if (trackPosition > tracks.count-1) {
                trackPosition = 0;
            }
            
            self.playItem(at: trackPosition)
        }
        else {
            if (trackPosition > tracks.count-1) {
                trackPosition = trackPosition-1
            }
            else {
                self.playItem(at: trackPosition)
            }
        }
    }
    
    @IBAction func seekChanged(sender: UISlider) {
        self.player.seek(toTime: CGFloat((self.sliderSeek?.value)!))
    }
    
    @IBAction func loop(sender: UIButton?) {
        self.btnLoop.isSelected = !self.btnLoop.isSelected
        self.loop = self.btnLoop.isSelected
    }
    
    @IBAction func changeGain(sender: UISlider) {
        self.player.gain = CGFloat(self.sliderGain.value)
    }
    
    // MARK: - Functions
    
    func updateItems(mediaItems: NSMutableArray, with position: Int) -> Void {
        self.tracks.removeAllObjects()
        self.tracks.addObjects(from: mediaItems as! [Any])
        self.refreshItems = true
        self.trackPosition = position
    }
    
    func playItem(at position: Int) -> Void {
        let mediaItem: MPMediaItem = self.tracks.object(at: position) as! MPMediaItem
        self.updateView(with: mediaItem)
        self.player.mediaItem = mediaItem;
        self.player.play()
        self.btnPlay.isSelected = true
    }
    
    func updateView(with mediaItem: MPMediaItem) -> Void {
        let width = self.imageView?.frame.size.width
        let height = self.imageView?.frame.size.height
        self.imageView.image = mediaItem.artwork?.image(at: CGSize(width: width!, height: height!))
        self.lblDuration.text = Utilities().formatTime(time: mediaItem.playbackDuration)
        
        self.sliderSeek.value = 0.0
        self.sliderSeek.minimumValue = 0.0
        self.sliderSeek.maximumValue = Float(mediaItem.playbackDuration)
        
        self.title = String(format: "%d of %d", trackPosition+1, self.tracks.count)
    }
    
    // MARK: - Protocols
    
    func playerItemStopped() {
        self.btnPlay.isSelected = false
    }
    
    func playerItemReachedEnd() {
        self.next(sender: nil)
    }
    
    func playerItemTimeChanged(_ time: CMTime) {
        self.sliderSeek.value = Float(CMTimeGetSeconds(time))
        self.lblTime.text = Utilities().formatTime(time: time)
    }
}
