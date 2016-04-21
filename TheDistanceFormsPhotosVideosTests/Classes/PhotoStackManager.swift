//
//  PhotoStackManager.swift
//  Pods
//
//  Created by Josh Campion on 15/02/2016.
//
//

import UIKit

import PSOperations
import AdvancedOperationKit
// import ViperKit
import AVFoundation
import CoreMedia
import MobileCoreServices

import TheDistanceCore

public enum PhotosStackAsset: Equatable {
    
    case Photo(UIImage)
    case Movie(AVURLAsset, UIImage?)
    
    init?(pickerResult: UIImagePickerResultType) {
        
        switch (pickerResult) {
        case .Image(let img):
            self = Photo(img)
        case .Movie(let URL):
            
            let asset = AVURLAsset(URL:URL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            let thumbnailImage:UIImage?
            
            if let thumbnail = try? generator.copyCGImageAtTime(CMTimeMakeWithSeconds(0.5, 4), actualTime: nil) {
                thumbnailImage = UIImage(CGImage: thumbnail).orientationNeutralImage()
            } else {
                thumbnailImage = nil
            }
            self = Movie(asset, thumbnailImage)
        case .None:
            return nil
        }
        
    }
}

public func ==(a1:PhotosStackAsset, a2:PhotosStackAsset) -> Bool {
    
    switch (a1, a2) {
    case (.Photo(let i1), .Photo(let i2)):
        return i1 == i2
    case (.Movie(let av1, _), .Movie(let av2, _)):
        return av1 == av2
    default:
        return false
    }
    
}

public protocol PhotosStackManagerDelegate: class {
    
    func photosStackManager(stack:PhotosStackManager, selectedAsset:PhotosStackAsset)
    func photosStackManagerCancelled(stack:PhotosStackManager)
}

public class PhotosStackManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public weak var delegate:PhotosStackManagerDelegate?
    
    public var mediaDataSource = [PhotosStackAsset]()
    
    public let context:UIViewController
    public let collectionView:UICollectionView
    public let operationQueue:OperationQueue
    
    public init(collectionView:UICollectionView, context:UIViewController, operationQueue:OperationQueue) {
        
        self.context = context
        self.collectionView = collectionView
        self.operationQueue = operationQueue
        
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCellIdentifier)
        collectionView.registerClass(VideoCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCellIdentifier)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaDataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let media = mediaDataSource[indexPath.row]
        
        switch (media) {
        case .Photo(let image):
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCellIdentifier, forIndexPath: indexPath)
            if let photoCell = cell as? PhotoCollectionViewCell {
                photoCell.imageView.image = image
            }
            
            return cell
            
        case .Movie(let asset, let thumbnail):
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MovieCollectionViewCellIdentifier, forIndexPath: indexPath)
            
            if let videoCell = cell as? VideoCollectionViewCell {
                let duration = CMTimeGetSeconds(asset.duration)
                
                let seconds = Int(duration) % 60
                let minutes = Int(duration / 60.0) % 60
                let hours = Int(duration / 3600.0)
                
                let timeString:String
                if hours > 0 {
                    timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                } else {
                    timeString = String(format: "%02d:%02d", minutes, seconds)
                }
                videoCell.timeLabel.text = timeString
                
                if let thumb = thumbnail {
                    videoCell.imageView.image = thumb
                }
            }
            
            return cell
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // show detail to allow deleting
    }
    
    public func newAssetFromSource(source:AdvancedOperationKit.UIPopoverSourceType) {
        
        guard let op = imageSelectionOperation(source) else { return }
        operationQueue.addOperation(op)
        
    }
    
    public func imageSelectionOperation(source:AdvancedOperationKit.UIPopoverSourceType) -> ImageSelectionOperation? {
        
        let types = [UIImagePickerTypeImage, UIImagePickerTypeMovie]
        
        let operation = ImageSelectionOperation(sourceViewController: context,
            sourceItem: source,
            mediaTypes: types,
            allowsEditing: false,
            tint: nil)
        
        operation.completion = { (media, info) in
            
            var chosenMedia = self.mediaDataSource
            
            switch (media) {
            case .Image(_), .Movie(_):
                if let asset = PhotosStackAsset(pickerResult: media) {
                    chosenMedia.insert(asset, atIndex: 0)
                    self.mediaDataSource = chosenMedia
                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
                    
                    self.delegate?.photosStackManager(self, selectedAsset: asset)
                }
                
            case .None:
                let _ = "Cancelled Media selection"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.photosStackManagerCancelled(self)
                })
                // print(str)
            }
        }
        
        return operation
    }
}
