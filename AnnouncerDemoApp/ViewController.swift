//
//  ViewController.swift
//  AnnouncerDemoApp
//
//  Created by Sommer Panage on 9/11/15.
//  Copyright © 2015 Sommer Panage. All rights reserved.
//

import UIKit
import AccessibilityAnnouncer

class ViewController: UIViewController {
    
    private let announcer = AccessibilityAnnouncer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapShortAnnouncement(sender: UIButton) {
        announcer.announce("Short.")
    }
    
    @IBAction func didTapLongAnnouncement(sender: UIButton) {
        announcer.announce("This is a long announcement with a lot to say.")
    }
}

