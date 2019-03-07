//
//  BaseMusicViewController.swift
//  Tracks
//
//  Created by David Ross on 30/06/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit
import MediaPlayer

class BaseMusicViewController: UITableViewController {
    
    let predNoCloud = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyIsCloudItem)
    let predNoDRM = MPMediaPropertyPredicate(value: NSNumber(value: false), forProperty: MPMediaItemPropertyHasProtectedAsset)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (PlayerViewController.shared.player.alive) {
            let rightButtonItem = UIBarButtonItem.init(
                title: "->",
                style: .plain,
                target: self,
                action: #selector(goToPlayer)
            )
            
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
    }
    
    @objc func goToPlayer() {
        let pvc = PlayerViewController.shared
        self.navigationController?.pushViewController(pvc, animated: true)
    }
}
