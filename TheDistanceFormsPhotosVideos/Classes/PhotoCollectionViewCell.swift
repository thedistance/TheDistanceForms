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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addConstraints(NSLayoutConstraint.constraintsToAlign(view: imageView, to: contentView))
    }
    
}

public class VideoCollectionViewCell: PhotoCollectionViewCell {
    
    public var videoIconView = UIImageView()
    public var timeLabel = UILabel()
    
    private(set) public var footerStack: UIStackView!
    
    override public func createViews() {
        super.createViews()
        
        let whiteTint = UIColor.white.withAlphaComponent(0.87)
        
        videoIconView.image = UIImage(named: "ic_videocam_white.png")
        videoIconView.tintColor = whiteTint
        
        timeLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        timeLabel.textColor = whiteTint
        
        // configure stack
        footerStack = CreateStackView([videoIconView, timeLabel])
        footerStack.distribution = .equalSpacing
        
        // add as subview
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(footerStack)
        
        // add constraints to align to the bottom
        let footerConstraints = NSLayoutConstraint.constraintsToAlign(view: footerStack, to: contentView, withInsets: UIEdgeInsets(top: 0.0, left: 2.0, bottom: 2.0, right: 4.0))
        contentView.addConstraints(Array(footerConstraints[1...3]))
    }
}
