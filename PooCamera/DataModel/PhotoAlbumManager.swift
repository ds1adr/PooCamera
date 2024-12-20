//
//  PhotoAlbumManager.swift
//  PooCamera
//
//  Created by KiWontai on 9/5/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumManager {
    static let albumName = "EmotionCam"
    static let manager = PhotoAlbumManager()
    
    var assetCollection: PHAssetCollection!
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
            createAlbum()
        case .denied, .restricted :
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { [unowned self] status in
                switch status {
                case .authorized:
                    self.createAlbum()
                case .denied, .restricted:
                // as above
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
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbumManager.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
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
    
    func save(image: UIImage , completion : @escaping () -> ()) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            
            if self.assetCollection.estimatedAssetCount == 0
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
