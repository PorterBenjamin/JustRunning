//
//  RunCell.swift
//  Just Running
//
//  Created by Ben Porter on 11/14/17.
//  Copyright © 2017 Ben Porter. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class RunCell: UITableViewCell {
    
    
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPace: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private static let kInnerMargin: CGFloat = 10.0
    private let motionManager = CMMotionManager()
    private weak var shadowView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadow()
    }
    
    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: RunCell.kInnerMargin,
                                              y: RunCell.kInnerMargin,
                                              width: bounds.width - (2 * RunCell.kInnerMargin),
                                              height: bounds.height - (2 * RunCell.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        
        // Roll/Pitch Dynamic Shadow
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = motion.attitude.pitch * 4 // x-axis
                    let roll = motion.attitude.roll * 4 // y-axis
                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
                }
            })
        }
    }
    
    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 6.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.35
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

