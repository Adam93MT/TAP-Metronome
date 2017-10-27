//
//  BeatGroupsContainerViewController.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-26.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class BeatGroupsContainerViewController: UIViewController {
    
    @IBOutlet weak var BeatGroupsLabel: UILabel!
    
    let buttonSize: CGFloat = 64
    var allButtons: beatGroupButtons!
    
    
    struct beatGroupButtons {
        var two: BeatGroupButton!
        var three: BeatGroupButton!
        var four: BeatGroupButton!
        var six: BeatGroupButton!
        
        init(size: CGFloat) {
            two = BeatGroupButton(size: size, val: 2)
            three = BeatGroupButton(size: size, val: 3)
            four = BeatGroupButton(size: size, val: 4)
            six = BeatGroupButton(size: size, val: 6)
        }
        
        func forEach(_ fn: (UIView) -> ()) {
            fn(two)
            fn(three)
            fn(four)
            fn(six)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        
        allButtons = beatGroupButtons(size: self.buttonSize)
        allButtons.forEach(self.view.addSubview)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutButtons() {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
