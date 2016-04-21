//
//  PhotosStack.swift
//  Pods
//
//  Created by Josh Campion on 15/02/2016.
//
//

import UIKit

import AdvancedOperationKit
import StackView
import TheDistanceCore
import TheDistanceForms

public class PhotosStack: ErrorStack, ValueElement, PhotosStackManagerDelegate {
    
    public let mediaManager:PhotosStackManager
    
    public let mediaCollectionView:UICollectionView
    public let mediaCollectionViewHeightConstraint:NSLayoutConstraint
    
    public let addButton:UIButton
    private(set) public var addTarget:ObjectTarget<UIButton>?
    
    public let textField:UITextField
    
    public let contentStack:StackView
    
    public var validation:Validation<[PhotosStackAsset]>?
    
    public init(collectionView: UICollectionView,
                manager:PhotosStackManager,
                addButton: UIButton = UIButton(type: .System),
                textField:UITextField = UITextField(),
                errorLabel: UILabel = UILabel(),
                errorImageView: UIImageView = UIImageView(),
                iconImageView: UIImageView = UIImageView()) {
    
        mediaCollectionView = collectionView
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        mediaCollectionViewHeightConstraint = NSLayoutConstraint(item: mediaCollectionView,
                                                                 attribute: .Height,
                                                                 relatedBy: .Equal,
                                                                 toItem: nil,
                                                                 attribute: .NotAnAttribute,
                                                                 multiplier: 0.0,
                                                                 constant: 75.0)
        mediaCollectionView.addConstraint(mediaCollectionViewHeightConstraint)
        
        self.addButton = addButton
        self.textField = textField
        
        addButton.setTitle("Add Photo or Video", forState: .Normal)
        textField.hidden = true
        
        mediaManager = manager
        contentStack = CreateStackView([mediaCollectionView, addButton, textField])
        contentStack.axis = .Vertical
        contentStack.spacing = 8.0
        
        super.init(centerComponent: contentStack.view,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
        
        mediaManager.delegate = self
        
        addTarget = ObjectTarget<UIButton>(control: addButton, forControlEvents: .TouchUpInside, completion: addTapped)
    }
    
    public func addTapped(sender:UIButton) {
        mediaManager.newAssetFromSource(.View(sender))
    }
    
    public func photosStackManager(stack: PhotosStackManager, selectedAsset: PhotosStackAsset) {
        updateMediaCollectionViewHeight()
    }
    
    public func photosStackManagerCancelled(stack: PhotosStackManager) { }
    
    public func updateMediaCollectionViewHeight() {
        let contentSize = mediaCollectionView.collectionViewLayout.collectionViewContentSize()
        if contentSize.height != mediaCollectionViewHeightConstraint.constant {
            mediaCollectionViewHeightConstraint.constant = contentSize.height
        }
    }
    
    public func getValue() -> Any? {
        return mediaManager.mediaDataSource[0]
    }
    
    public func setValue<T>(value: T?) -> Bool {
        
        guard let mediaObjects = value as? [PhotosStackAsset] else { return false }
        
        mediaManager.mediaDataSource = mediaObjects
        mediaManager.collectionView.reloadData()
        return true
    }
    
    public func validateValue() -> ValidationResult {
        
        let value = getValue() as? [PhotosStackAsset]
        let result = validation?.validate(value: value) ?? .Valid
        
        if case .Invalid(let message) = result {
            errorText = message
        } else {
            errorText = nil
        }
        
        return result
    }
}