//
//  SelectImageVC.swift
//  InstagramCloe
//
//  Created by Apple on 8.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase
import Photos

private let reuseIdentifier  = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    var images = [UIImage]()
    var assests = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell classes
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    
        collectionView?.backgroundColor = .white
        
        //configure nav controllers
        configureNavigationButtons()
        
        //fetch photos
        fetchPhotos()
    
    
    }
    
    
    
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        if let selectedImage = self.selectedImage{
            
            //index selected image
            if let index = self.images.index(of: selectedImage) {
                
            //asset associated with selected iamge
            let selectedAsset = self.assests[index]
            
            let imageManager = PHImageManager.default()
            let targetSize = CGSize(width: 600, height: 600)
            
            //reguest image
            imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                //set header's image as selected image
                header.photoImageView.image = image
                
                }
                
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        
        //we want our collection scroll back up to the top
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        let uploadPostVC = UploadPostVC()
        uploadPostVC.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(uploadPostVC, animated: true)
        
    }
    
    // MARK: - Handlers
    
    func configureNavigationButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
 
    func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()

        //fetch limit
        options.fetchLimit = 30
        
        //sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        //set sort descriptor for options
        options.sortDescriptors = [sortDescriptor]
        
        //return options
        return options
    }
    
    func fetchPhotos() {
        
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        //fetch images on background thread, asyncrinst backgroun thread where we gonna fetch the photos we have from our phc asset fetch result
        //a-synchronously means we want things to be fetched out of order
        DispatchQueue.global(qos: .background).async {
            //enumeratedobjects will execute the specified block using each object in the fetch result,starting with the first object and continuing in order to last object
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                
                //is synchronous means we want things to be fetched in order
                options.isSynchronous = true
                
                //regust image represantation for specified asses
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    if let image = image {
                        
                        //append images to datasource
                        self.images.append(image)
                        
                        //append asset to datasource
                        self.assests.append(asset)
                        
                        //set selected image
                        if self.selectedImage == nil {
                            self.selectedImage = image
                    }
                        //reload collection view with images once count has completed
                        if count == allPhotos.count - 1{
                            //reload collection view on main thread
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                    }
                }
            }
        }
    }
}
}
