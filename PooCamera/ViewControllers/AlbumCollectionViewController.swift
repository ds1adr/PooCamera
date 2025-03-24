//
//  AlbumCollectionViewController.swift
//  PooCamera
//
//  Created by Won Tai Ki on 9/5/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import Photos
import UIKit

class AlbumCollectionViewController: UIViewController {
    var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset>?
    var collectionView: UICollectionView!
    
    var selectedImage: UIImage?
    var isFresh: Bool = false
//    var assets: [PHAsset] = []
//    var faces: [CIFeature]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Album"
        view.backgroundColor = .systemBackground
        
        makeViews()
        makeDataSource()
        
        PhotoAlbumManager.manager.delegate = self
        PhotoAlbumManager.manager.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func makeViews() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0/3.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
    }
    
    private func makeDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<Int, PHAsset>(collectionView: collectionView) { collectionView, indexPath, phAsset in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
            cell.configure(asset: phAsset)
            return cell
        }
        
        self.dataSource = dataSource
        collectionView.dataSource = dataSource
    }
    
    private func snapshot(assets: [PHAsset]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
        snapshot.appendSections([0])
        snapshot.appendItems(assets)
        dataSource?.apply(snapshot)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "presentCameraView":
                if let vc = segue.destination as? CameraViewController {
                    vc.delegate = self
                }
            case "pushPictureView":
                if let vc = segue.destination as? PictureViewController {
                    vc.originalImage = self.selectedImage
                    vc.isFresh = isFresh
//                    vc.faces = self.faces
                    vc.retakeHandler = { [weak self] in
                        self?.performSegue(withIdentifier: "presentCameraView", sender: self)
                    }
                    self.isFresh = false
                }
            default:
                break
            }
        }
    }
    

    @IBAction func addButtonPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_: UIAlertAction) in
            self.performSegue(withIdentifier: "presentCameraView", sender: self)
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (_: UIAlertAction) in
            let vc = UIImagePickerController()
            
            vc.allowsEditing = false
            vc.sourceType = .photoLibrary
            vc.delegate = self
            
            self.present(vc, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AlbumCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { 
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage,
            let faces = FaceDetector.detectFace(withImage: image) {
            self.selectedImage = image
//            self.faces = faces
            
            self.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "pushPictureView", sender: self)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AlbumCollectionViewController: CameraViewControllerDelegate {
    func take(withImage image: UIImage) {
//        if let faces = FaceDetector.detectFace(withImage: image) {
            self.selectedImage = image
            self.isFresh = true
//            self.faces = faces
            
            self.performSegue(withIdentifier: "pushPictureView", sender: self)
//        }
    }
    
    func cancel() {
        
    }
}

extension AlbumCollectionViewController: PhotoAlbumManagerDelegate {
    func fetchResultUpdated() {
        guard let fetchResult = PhotoAlbumManager.manager.fetchResult else { return }
        let assets = fetchResult.objects(at: IndexSet(0 ..< fetchResult.count))
        snapshot(assets: assets)
    }
}

extension AlbumCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { [weak self] image, dict in
            self?.selectedImage = image
            self?.isFresh = false
            
            self?.performSegue(withIdentifier: "pushPictureView", sender: self)
        }
    }
}
