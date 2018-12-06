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
    
    case photo(UIImage)
    case movie(AVURLAsset, UIImage?)
    
    init?(pickerResult: UIImagePickerResultType) {
        
        switch (pickerResult) {
        case .image(let img):
            self = .photo(img)
        case .movie(let URL):
            
            let asset = AVURLAsset(url:URL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            let thumbnailImage:UIImage?
            
            if let thumbnail = try? generator.copyCGImage(at: CMTimeMakeWithSeconds(0.5, preferredTimescale: 4), actualTime: nil) {
                thumbnailImage = UIImage(cgImage: thumbnail).orientationNeutralImage()
            } else {
                thumbnailImage = nil
            }
            self = .movie(asset, thumbnailImage)
        case .none:
            return nil
        }
        
    }
}

public func ==(a1:PhotosStackAsset, a2:PhotosStackAsset) -> Bool {
    
    switch (a1, a2) {
    case (.photo(let i1), .photo(let i2)):
        return i1 == i2
    case (.movie(let av1, _), .movie(let av2, _)):
        return av1 == av2
    default:
        return false
    }
    
}

public protocol PhotosStackManagerDelegate: class {
    
    func photosStackManager(stack:PhotosStackManager, selectedAsset:PhotosStackAsset)
    func photosStackManagerCancelled(stack:PhotosStackManager)
}

open class PhotosStackManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public weak var delegate:PhotosStackManagerDelegate?
    
    public var mediaDataSource = [PhotosStackAsset]()
    
    public var context:UIViewController
    public let collectionView:UICollectionView
    public let operationQueue:PSOperationQueue
    
    public init(collectionView:UICollectionView, context:UIViewController, operationQueue:PSOperationQueue) {
        
        self.context = context
        self.collectionView = collectionView
        self.operationQueue = operationQueue
        
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCellIdentifier)
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCellIdentifier)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let media = mediaDataSource[indexPath.row]
        
        switch (media) {
        case .photo(let image):
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCellIdentifier, for: indexPath as IndexPath)
            if let photoCell = cell as? PhotoCollectionViewCell {
                photoCell.imageView.image = image
            }
            
            return cell
            
        case .movie(let asset, let thumbnail):
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCellIdentifier, for: indexPath as IndexPath)
            
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
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show detail to allow deleting
    }
    
    public func newAssetFromSource(source:AdvancedOperationKit.UIPopoverSourceType) {
        
        guard let op = imageSelectionOperation(source: source) else { return }
        operationQueue.addOperation(op)
        
    }
    
    open func imageSelectionOperation(source:AdvancedOperationKit.UIPopoverSourceType) -> ImageSelectionOperation? {
        
        let types = [UIImagePickerTypeImage, UIImagePickerTypeMovie]
        
        let operation = ImageSelectionOperation(sourceViewController: context,
            sourceItem: source,
            mediaTypes: types,
            allowsEditing: false,
            tint: nil)
        
        operation.completion = { (media, info) in
            
            var chosenMedia = self.mediaDataSource
            
            switch (media) {
            case .image(_), .movie(_):
                if let asset = PhotosStackAsset(pickerResult: media) {
                    chosenMedia.insert(asset, at: 0)
                    self.mediaDataSource = chosenMedia
                    self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                    
                    self.delegate?.photosStackManager(stack: self, selectedAsset: asset)
                }
                
            case .none:
                let _ = "Cancelled Media selection"
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.photosStackManagerCancelled(stack: self)
                })
                // print(str)
            }
        }
        
        return operation
    }
}
