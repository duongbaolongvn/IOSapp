//


import UIKit
import Photos
protocol CustomPhotoPickerDelegate: AnyObject {
    func imageDidSelected(_ image: UIImage)
}
class ScreenThreeViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var albumMenu: UIButton!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    
    let numberItemsPerRow = 3
    let fetchOptions = PHFetchOptions()
    var listAlbums: [String] = []
    var listCollections = PHFetchResult<PHAssetCollection>()
    var currentAssetAlbum = PHFetchResult<PHAsset>()
    
    weak var delegate: CustomPhotoPickerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryCollectionView.allowsMultipleSelection = true
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchAlbum {
            DispatchQueue.main.async {
                self.galleryCollectionView.reloadData()
                self.setAlbumTitles()
            }
        }
    }
    func getAssetThumbnailOrFullImage(asset: PHAsset, isFullSize: Bool? = false) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail: UIImage?
        option.isSynchronous = true
        let targetSize = (isFullSize ?? false) ? PHImageManagerMaximumSize : CGSize(width: 200, height: 200)
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option) { result, info in
            thumbnail = result
        }
        return thumbnail
    }
    
    func albumIndexDidChange(_ index: Int, completion: (String)-> Void) {
        if index == 0 {
            currentAssetAlbum = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        } else {
            currentAssetAlbum = PHAsset.fetchAssets(in: listCollections[index], options: fetchOptions)
        }
        completion(listAlbums[index])
        
    }
    
    func setAlbumTitles() {
        if #available(iOS 14.0, *) {
            let listElement : [UIMenuElement] = listAlbums.map { (string) in
                UIAction(title: string) { _ in
                    let index = self.listAlbums.firstIndex(of: string)
                    self.albumIndexDidChange(index!) { name in
                        DispatchQueue.main.async {
                            self.albumMenu.setTitle(name, for: .normal)
                            self.galleryCollectionView.reloadData()
                        }
                    }
                }
            }
            albumMenu.showsMenuAsPrimaryAction = true
            albumMenu.menu = UIMenu(title: "List album", options: .displayInline, children: listElement)
        }
    }
    func alertOnPermissionDenied() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Allow access", message: "Please allow acess to photo so we can add new photo for you", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else {
                          assertionFailure("Unable to open app setting")
                          return
                      }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: false)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func fetchAlbum(completion: @escaping ()-> Void) {
        let access = PHPhotoLibrary.authorizationStatus()
        if access != .authorized {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == .authorized) {
                    self.fetchPhotoOnAuthorized(completion: completion)
                } else if (newStatus == .denied){
                    self.alertOnPermissionDenied()
                }
            })
        } else if access == .denied {
            self.alertOnPermissionDenied()
        } else {
            fetchPhotoOnAuthorized(completion: completion)
        }
    }
    
    
    func fetchPhotoOnAuthorized(completion: @escaping ()-> Void) {
        let recents = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        listAlbums.append("Recent's Photo")
        currentAssetAlbum = recents
        listCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0..<listCollections.count {
            if let name = listCollections[i].localizedTitle {
                listAlbums.append(name)
            }
        }
        setAlbumTitles()
        completion()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoButton(_ sender: UIButton) {
        if let indexSelectItem = galleryCollectionView.indexPathsForSelectedItems {
            for im in indexSelectItem {
                let asset = currentAssetAlbum.object(at: im.row)
                   guard let fullImage = getAssetThumbnailOrFullImage(asset: asset, isFullSize: true)
                else {continue}
                self.delegate!.imageDidSelected(fullImage)
//                print("hello")
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension ScreenThreeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAssetAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenThreeViewControllerCell", for: indexPath) as? ScreenThreeViewControllerCell else { return UICollectionViewCell() }
        if let image = getAssetThumbnailOrFullImage(asset: currentAssetAlbum.object(at: indexPath.row)) {
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // custome cell in three colloms
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero}
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing*CGFloat(numberItemsPerRow - 1)
        let size = (collectionView.bounds.width - totalSpace)/CGFloat(numberItemsPerRow)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        checkAddButtonEnabled()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        checkAddButtonEnabled()
    }
    
    func checkAddButtonEnabled() {
        if let listIndexPath = galleryCollectionView.indexPathsForSelectedItems {
            addButton.isEnabled = listIndexPath.count > 0
        }
    }
    
    
}
