//
//  SettingsViewController.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var currentOrientation: String = "portrait"

    let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: Globals.dimensions.minPadding,
                                           bottom: 0,
                                           right: Globals.dimensions.minPadding)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    var colorButtonSize:CGFloat!
    
    
    @IBOutlet weak var GroupsLabel: UILabel!
    
    @IBOutlet weak var twoBeats: BeatGroupButton!
    @IBOutlet weak var threeBeats: BeatGroupButton!
    @IBOutlet weak var fourBeats: BeatGroupButton!
    @IBOutlet weak var sixBeats: BeatGroupButton!
    var BeatGroupButtonsArray = [BeatGroupButton]()
    
    @IBOutlet weak var ColorsLabel: UILabel!
    @IBOutlet weak var colorCollectionContainerView: UIView!
    
    var lastSelectedIndex: Int = globalColors.getIndexOfColorOption(Globals.colors.currentTheme.Name!)
    let borderWidth:CGFloat = 2
    let borderColor = UIColor.white.cgColor
    let gradientLayer = GradientView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSettingsPage = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = Globals.colors.currentTheme.Light
        // Do any additional setup after loading the view.
        
        // Beats Buttons
        BeatGroupButtonsArray = [twoBeats, threeBeats, fourBeats, sixBeats]

        twoBeats.setValue(val: 2)
        threeBeats.setValue(val: 3)
        fourBeats.setValue(val: 4)
        sixBeats.setValue(val: 6)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleDeviceRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        // Color Buttons
        colorButtonSize = min(
            self.view.frame.width / 6 - (Globals.dimensions.minPadding),
            Globals.dimensions.buttonHeight)
        setupColorCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsPage = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: VIEW SETUP
    
    func setupColorCollectionView() {
        
        colorCollectionView.frame = colorCollectionContainerView.bounds
        colorCollectionContainerView.addSubview(colorCollectionView)
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "Color")
    }
    
    func updateUIColor() {
        self.view.backgroundColor = Globals.colors.currentTheme.Light
        self.gradientLayer.gl.removeFromSuperlayer()
        self.createGradientLayer()
    }
    
    func createGradientLayer() {
        // Set up the background colors
        self.gradientLayer.setColors(startColor: Globals.colors.currentTheme.Light, endColor: Globals.colors.currentTheme.Dark)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }
    
    // MARK : UI Interaction
    @IBAction func pressedGroupButton(_ sender: BeatGroupButton) {
        for button in BeatGroupButtonsArray {
            button.isPicked = false
        }
        sender.isPicked = true
    }

    func addColor() {
        let alert = UIAlertController(title: "Coming Soon!", message: "More backgrounds coming soon.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeviceRotation() {
        if UIDevice.current.orientation.isPortrait {
            self.currentOrientation = "portrait"
        } else if UIDevice.current.orientation.isLandscape {
            self.currentOrientation = "landscape"
        }
        print("Rotated to \(self.currentOrientation)")
        self.gradientLayer.gl.frame = self.view.bounds
    }
}

//
extension SettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return globalColors.colorOptions.count + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: "Color", for: indexPath) as! ColorCollectionViewCell
        
        if (indexPath.item < globalColors.colorOptions.count){
            cell.setColorStringValue(globalColors.getColorName(withID: indexPath.item))
        } else {
            cell.setColorStringValue("add")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(indexPath)")
        
        // if the index is out of range, reset the selection
        if (indexPath.item >= globalColors.colorOptions.count) {
            print("pressed Add More")
            collectionView.cellForItem(at: indexPath)?.isSelected = false
            collectionView.cellForItem(at: [0,lastSelectedIndex])?.isSelected = true
            addColor()
            
        // otherwise, make sure the last index is deselected
        } else {
            collectionView.cellForItem(at: [0, lastSelectedIndex])?.isSelected = false
            self.updateUIColor()
            lastSelectedIndex = indexPath.item
        }
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.colorButtonSize, height: self.colorButtonSize)
    }
}
