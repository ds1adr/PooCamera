//
//  AlbumCollectionViewController.swift
//  PooCamera
//
//  Created by Won Tai Ki on 9/5/17.
//  Copyright © 2017 KiWontai. All rights reserved.
//

import UIKit

class AlbumCollectionViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedImage: UIImage?
    var faces: [CIFeature]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoAlbumManager.manager.setup()

        self.title = "Album"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    vc.faces = self.faces
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
            self.faces = faces
            
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
        if let faces = FaceDetector.detectFace(withImage: image) {
            self.selectedImage = image
            self.faces = faces
            
            self.performSegue(withIdentifier: "pushPictureView", sender: self)
        }
    }
    
    func cancel() {
        
    }
}
