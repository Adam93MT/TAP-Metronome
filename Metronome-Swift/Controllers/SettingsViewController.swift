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
    
    @IBOutlet weak var settingsCollectionContainerView: UIView!
    
    var timeSignatureButtonSize: CGFloat = 64
    var lastSectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var lastSelectedColorIndex: Int = globalColors.getIndexOfColorOption(Globals.colors.currentTheme.Name!)
    var lastSelectedTimeSignatureIndex: Int = (UIApplication.shared.delegate as! AppDelegate).metronome.possibleTimeSignatures.index(of: (UIApplication.shared.delegate as! AppDelegate).metronome.getTimeSignature())!
    var colorButtonSize:CGFloat!
    
    let headerLineHeight:CGFloat = 56
    let borderWidth:CGFloat = 2
    let borderColor = UIColor.white.cgColor
    let gradientLayer = GradientView()
    
    let settingsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 256, height: 56)
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSettingsPage = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = Globals.colors.currentTheme.Light
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleDeviceRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        // Color Buttons
        colorButtonSize = min(
            self.view.frame.width / 6 - (Globals.dimensions.minButtonSpacing),
            Globals.dimensions.buttonHeight)
        
        setupCollectionView()
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
    func setupCollectionView() {
        settingsCollectionView.frame = settingsCollectionContainerView.bounds
        settingsCollectionContainerView.addSubview(settingsCollectionView)

        settingsCollectionView.dataSource = self
        settingsCollectionView.delegate = self
        settingsCollectionView.allowsSelection = true
        settingsCollectionView.allowsMultipleSelection = true
        
        settingsCollectionView.register(TimeSignatureCollectionViewCell.self, forCellWithReuseIdentifier: "TimeSig")
        settingsCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "Color")
        settingsCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
    
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
    /*
     // section 0 is Time Signatures
     // section 1 is Colors
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return delegate.metronome.possibleTimeSignatures.count
        }
        else if (section == 1) {
            return globalColors.colorOptions.count + 1
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var v : UICollectionReusableView! = nil
        if kind == UICollectionElementKindSectionHeader {
            
            v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
            
            if v.subviews.count == 0 {
                v.addSubview(UILabel(frame:CGRect(x: 0, y: 0, width: settingsCollectionView.bounds.width, height: headerLineHeight)))
            }
            let lab = v.subviews[0] as! UILabel
            
            // Sketchy way to get title. Should refactor this
            lab.text = indexPath.section == 0 ? "GROUPS" : "BACKGROUND"
            lab.font = lab.font.withSize(16)
            lab.textColor = Globals.colors.textColor
            lab.textAlignment = .left
        }
        return v
    }
    
    // Layout & Draw Cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0){
            let cell = settingsCollectionView.dequeueReusableCell(withReuseIdentifier: "TimeSig", for: indexPath) as!
            TimeSignatureCollectionViewCell

            if (indexPath.item < delegate.metronome.possibleTimeSignatures.count) {
                cell.setValue(delegate.metronome.possibleTimeSignatures[indexPath[1]])
            }
            
            if (cell.value == delegate.metronome.getTimeSignature()) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            
            return cell
        }
        else /* if  (collectionView == timeSignatureCollectionView) */{
            let cell = settingsCollectionView.dequeueReusableCell(withReuseIdentifier: "Color", for: indexPath) as! ColorCollectionViewCell

            if (indexPath.item < globalColors.colorOptions.count){
                cell.setColorStringValue(globalColors.getColorName(withID: indexPath.item))
            } else {
                cell.setColorStringValue("add")
            }
            
            if (cell.colorString == Globals.colors.currentTheme.Name) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            return cell
        }
    }
    
    // Selecting Cells
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(indexPath)")
//        print("Last TS \(lastSelectedTimeSignatureIndex)")
//        print("Last Color \(lastSelectedColorIndex)")
        
        var indexPaths = collectionView.indexPathsForVisibleItems
        // Don't deselect our own index path
        while let elementIndex = indexPaths.index(of: indexPath) { indexPaths.remove(at: elementIndex) }
        for otherIndexPath: IndexPath in indexPaths {
            if otherIndexPath.section == indexPath.section {
                collectionView.deselectItem(at: otherIndexPath, animated: true)
            }
            else {
                if (indexPath.section == 0) {
                    if (otherIndexPath.item != lastSelectedColorIndex) {
                        collectionView.deselectItem(at: otherIndexPath, animated: true)
                    }
                }
                else if (indexPath.section == 1) {
                    if (otherIndexPath.item != lastSelectedTimeSignatureIndex) {
                        collectionView.deselectItem(at: otherIndexPath, animated: true)
                    }
                }
            }
        }
        
        if (indexPath.section == 0) {
            lastSelectedTimeSignatureIndex = indexPath.item
        }
        else if (indexPath.section == 1) {
            updateUIColor()
            lastSelectedColorIndex = indexPath.item
        }
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (indexPath.section == 0) {
            return CGSize(width: self.timeSignatureButtonSize, height: self.timeSignatureButtonSize)
        }
        else {
            return CGSize(width: self.colorButtonSize, height: self.colorButtonSize)
        }
    }
}
