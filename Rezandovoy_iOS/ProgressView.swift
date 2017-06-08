//
//  ProgressView.swift
//  Rezandovoy
//
//  Created by Rodrigo on 17/2/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    // the layer that shows the actual progress
    fileprivate let progressLayer: CAShapeLayer = CAShapeLayer()
    
    fileprivate var progressLabel: UILabel = UILabel()
    fileprivate var sizeProgressLabel : UILabel = UILabel()
    
    // layer to show the dashed circle layer
    fileprivate var dashedLayer: CAShapeLayer = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    fileprivate func setupView() {
        backgroundColor = UIColor.clear
        createProgressLayer()
        createLabel()
    }
    
    func createLabel() {
        progressLabel = UILabel()
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.text = "0 %"
        progressLabel.font = UIFont(name: "Aleo-Regular", size: 40.0)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        // add constraints
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: progressLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: progressLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        // label to show the already downloaded size and the total size of the file
        sizeProgressLabel = UILabel()
        sizeProgressLabel.textColor = .white
        sizeProgressLabel.textAlignment = .center
        sizeProgressLabel.text = "0.0 MB / 0.0 MB"
        sizeProgressLabel.font = UIFont(name: "Aleo-Regular", size: 10.0)
        sizeProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sizeProgressLabel)
        // add constraints
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: sizeProgressLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: progressLabel, attribute: .bottom, relatedBy: .equal, toItem: sizeProgressLabel, attribute: .top, multiplier: 1.0, constant: -10.0))
    }
    
    fileprivate func createProgressLayer() {
        let startAngle = CGFloat(Double.pi / 2)
        let endAngle = CGFloat((Double.pi / 2) * 2 + (Double.pi / 2))
        let centerPoint = CGPoint(x: frame.width/2 , y: frame.height/2)
        
        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: frame.width/2 - 10.0, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.white.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
        let dashedLayer = CAShapeLayer()
        dashedLayer.strokeColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        dashedLayer.fillColor = nil
        dashedLayer.lineDashPattern = [2, 4]
        dashedLayer.lineJoin = "round"
        dashedLayer.lineWidth = 2.0
        dashedLayer.path = progressLayer.path
        layer.insertSublayer(dashedLayer, below: progressLayer)
    }
    
    func animateProgressViewToProgress(_ progress: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(progressLayer.strokeEnd)
        animation.toValue = CGFloat(progress)
        animation.duration = 0.2
        animation.fillMode = kCAFillModeForwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "animation")
    }
    
    func updateProgressViewLabelWithProgress(_ percent: Float) {
        progressLabel.text = NSString(format: "%.0f %@", percent, "%") as String
    }
    
    func updateProgressViewWith(_ totalSent: Float, totalFileSize: Float) {
        sizeProgressLabel.text = NSString(format: "%.1f MB / %.1f MB", convertFileSizeToMegabyte(totalSent), convertFileSizeToMegabyte(totalFileSize)) as String
    }
    
    fileprivate func convertFileSizeToMegabyte(_ size: Float) -> Float {
        return (size / 1024) / 1024
    }
    
    func hideProgressView() {
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
    }
    
    //override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        hideProgressView()
    }
}

