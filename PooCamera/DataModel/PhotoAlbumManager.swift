//
//  PhotoAlbumManager.swift
//  PooCamera
//
//  Created by KiWontai on 9/5/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit
import Photos

protocol PhotoAlbumManagerDelegate: AnyObject {
    func fetchResultUpdated()
}

class PhotoAlbumManager {
    static let albumName = "EmotionCam"
    static let manager = PhotoAlbumManager()
    weak var delegate: PhotoAlbumManagerDelegate? {
        didSet {
            if fetchResult != nil {
                delegate?.fetchResultUpdated()
            }
        }
    }
    
    var assetCollection: PHAssetCollection?
    var fetchResult: PHFetchResult<PHAsset>?
    
    init() {
        
    }
    
    func setup() {
        checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            assetCollection = fetchAssetCollectionForAlbum()
            fetchAssets()
            createAlbum()
        case .denied, .restricted :
            delegate?.fetchResultUpdated()
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { [weak self] status in
                switch status {
                case .authorized:
                    self?.assetCollection = self?.fetchAssetCollectionForAlbum()
                    self?.fetchAssets()
                    self?.createAlbum()
                case .denied, .restricted:
                // as above
                    self?.delegate?.fetchResultUpdated()
                    break
                case .notDetermined:
                    break
                default:
                    break
                }
            }
        default:
            break
        }
        
    }
    
    func createAlbum() {
        if assetCollection == nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbumManager.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    self.fetchAssets()
                } else {
                    print("error \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbumManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func fetchAssets() {
        guard let assetCollection else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        delegate?.fetchResultUpdated()
    }
    
    func save(image: UIImage , completion : @escaping () -> ()) {
        guard let assetCollection else { return }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            
            if assetCollection.estimatedAssetCount == 0
            {
                albumChangeRequest!.addAssets(enumeration)
            }
            else {
                albumChangeRequest!.insertAssets(enumeration, at: [0])
            }
            
        }, completionHandler: { status , errror in
            completion( )
        })
    }
}
