//
//  PhotosStack.swift
//  Pods
//
//  Created by Josh Campion on 15/02/2016.
//
//

import UIKit

import AdvancedOperationKit
import TDStackView
import TheDistanceCore


open class PhotosStack: ErrorStack, ValueElement, PhotosStackManagerDelegate {
    
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
                addButton: UIButton = UIButton(type: .system),
                textField:UITextField = UITextField(),
                errorLabel: UILabel = UILabel(),
                errorImageView: UIImageView = UIImageView(),
                iconImageView: UIImageView = UIImageView()) {
    
        mediaCollectionView = collectionView
        mediaCollectionView.backgroundColor = UIColor.clear
        mediaCollectionViewHeightConstraint = NSLayoutConstraint(item: mediaCollectionView,
                                                                 attribute: .height,
                                                                 relatedBy: .equal,
                                                                 toItem: nil,
                                                                 attribute: .notAnAttribute,
                                                                 multiplier: 0.0,
                                                                 constant: 75.0)
        mediaCollectionView.addConstraint(mediaCollectionViewHeightConstraint)
        
        self.addButton = addButton
        self.textField = textField
        
        addButton.setTitle("Add Photo or Video", for: .normal)
        textField.isHidden = true
        
        mediaManager = manager
        contentStack = CreateStackView([mediaCollectionView, addButton, textField])
        contentStack.axis = .vertical
        contentStack.spacing = 8.0
        
        super.init(centerComponent: contentStack.view,
                   errorLabel: errorLabel,
                   errorImageView: errorImageView,
                   iconImageView: iconImageView)
        
        mediaManager.delegate = self
        
        addTarget = ObjectTarget<UIButton>(control: addButton, forControlEvents: .touchUpInside, completion: addTapped)
    }
    
    open func addTapped(sender:UIButton) {
        mediaManager.newAssetFromSource(source: .view(sender))
    }
    
    open func photosStackManager(stack: PhotosStackManager, selectedAsset: PhotosStackAsset) {
        updateMediaCollectionViewHeight()
    }
    
    open func photosStackManagerCancelled(stack: PhotosStackManager) { }
    
    public func updateMediaCollectionViewHeight() {
        let contentSize = mediaCollectionView.collectionViewLayout.collectionViewContentSize
        if contentSize.height != mediaCollectionViewHeightConstraint.constant {
            mediaCollectionViewHeightConstraint.constant = contentSize.height
        }
    }
    
    public func getValue() -> Any? {
        return mediaManager.mediaDataSource
    }
    
    public func setValue<T>(_ value: T?) -> Bool {
        
        guard let mediaObjects = value as? [PhotosStackAsset] else { return false }
        
        mediaManager.mediaDataSource = mediaObjects
        mediaManager.collectionView.reloadData()
        return true
    }
    
    public func validateValue() -> ValidationResult {
        
        let value = getValue() as? [PhotosStackAsset]
        let result = validation?.validate(value) ?? .valid
        
        if case .invalid(let message) = result {
            errorText = message
        } else {
            errorText = nil
        }
        
        return result
    }
}
