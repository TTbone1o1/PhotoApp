import UIKit
import Photos

class PhotoLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var photos: [UIImage] = []
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        loadPhotos()
        
        // Add swipe gesture recognizer for navigating back
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    private func loadPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                assets.enumerateObjects { (asset, _, _) in
                    let imageManager = PHImageManager.default()
                    let imageSize = CGSize(width: 300, height: 300)
                    imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, _ in
                        if let image = image {
                            self.photos.append(image)
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = photos[indexPath.item]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 20) / 3
        return CGSize(width: width, height: width)
    }
    
    // Handles swipe right to return to ViewController
    @objc private func didSwipeRight() {
        dismiss(animated: true, completion: nil)
    }
}
