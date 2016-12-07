//
//  PhotoCollectionViewCell.swift
//  Pods
//
//  Created by Josh Campion on 15/02/2016.
//
//

import UIKit

import TheDistanceCore
import TDStackView

public let PhotoCollectionViewCellIdentifier = "PhotoCell"
public let MovieCollectionViewCellIdentifier = "MovieCell"

public class PhotoCollectionViewCell: UICollectionViewCell {
    
    public let imageView = UIImageView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        createViews()
    }
    
    public func createViews() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addConstraints(NSLayoutConstraint.constraintsToAlign(view: imageView, to: contentView))
    }
    
}

public class VideoCollectionViewCell: PhotoCollectionViewCell {
    
    public var videoIconView = UIImageView()
    public var timeLabel = UILabel()
    
    private(set) public var footerStack:StackView!
    
    override public func createViews() {
        super.createViews()
        
        let whiteTint = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        
        videoIconView.image = UIImage(named: "ic_videocam_white.png")
        videoIconView.tintColor = whiteTint
        
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        timeLabel.textColor = whiteTint
        
        // configure stack
        footerStack = CreateStackView([videoIconView, timeLabel])
        footerStack.stackDistribution = .EqualSpacing
        
        // add as subview
        footerStack.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(footerStack.view)
        
        // add constraints to align to the bottom
        let footerConstraints = NSLayoutConstraint.constraintsToAlign(view: footerStack.view, to: contentView, withInsets: UIEdgeInsetsMake(0.0, 2.0, 2.0, 4.0))
        contentView.addConstraints(Array(footerConstraints[1...3]))
    }
}
