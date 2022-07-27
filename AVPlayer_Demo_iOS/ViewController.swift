//
//  ViewController.swift
//  AVPlayer_Demo_iOS
//
//  Created by Naveen Kunisetty on 7/27/22.
//

import UIKit
import AVKit

extension String {
    static let videoURL = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
}

class ViewController: UIViewController {
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var playerStatusObserver: Any?
    var timeObserverToken: Any?
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupAVPlayer()
        setupObservers()
    }
    
    deinit {
        playerStatusObserver = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nc.removeObserver(UIApplication.willEnterForegroundNotification)
        nc.removeObserver(UIApplication.didEnterBackgroundNotification)
    }
}

/// AVPlayer Setup Methods
extension ViewController {
    
    func setupAVPlayer() {
        self.player = AVPlayer()
        setupAVPlayerLayer()
        let videoURL = URL(string: .videoURL)
        playerItem = AVPlayerItem(url: videoURL!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func setupAVPlayerLayer() {
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = .resizeAspect
        self.view.layer.addSublayer(playerLayer)
    }
    
    func setupObservers() {
        addPlayerEndedObserver()
        addPeriodicTimeObserver()
        addPlayerStatusObserver()
        addAppLifecyCleObservers()
    }
    
    func addAppLifecyCleObservers() {
        nc.addObserver(self, selector: #selector(appEnteredForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(appEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appEnteredForeground() {
        if player.timeControlStatus == .paused {
            setupAVPlayerLayer()
            player.play()
            print("************************ AVPlayer Video Playback RESUMED ************************")
        }
    }
    
    @objc func appEnteredBackground() {
        self.player.pause()
        playerLayer = nil
        print("************************ AVPlayer Video Playback PAUSED ************************")
    }
    
    func addPlayerEndedObserver() {
        nc.addObserver(self, selector: #selector(didPlayerEnded), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func addPlayerStatusObserver() {
        playerStatusObserver = playerItem?.observe(\AVPlayerItem.status, changeHandler: { observedPlayerItem, change in
            if (observedPlayerItem.status == AVPlayerItem.Status.readyToPlay) {
                print("************************ AVPlayer Video Playback STARTED ************************")
            } else if (observedPlayerItem.status == AVPlayerItem.Status.failed) {
                print("************************ AVPlayer Video Playback FAILED ************************")
            }
        })
    }
    
    /// Utility method to format time interval in hh:mm:ss
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

/// AVPlayer Status Observers
extension ViewController {
    
    @objc func didPlayerEnded() {
        print("************************ AVPlayer Video Playback STOPPED ************************")
    }
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player!.addPeriodicTimeObserver(forInterval: time,
                                                            queue: .main) { time in
            print("Current Playhead Position is \(self.stringFromTimeInterval(interval: CMTimeGetSeconds(time)))")
        }
    }
}


