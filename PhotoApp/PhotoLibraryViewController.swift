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
    
    private var expandedImageView: UIImageView?
    private var isImageExpanded = false
    private var originalIndexPath: IndexPath?
    
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
        
        // Remove existing subviews to avoid overlapping
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = photos[indexPath.item]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10 // Adjust corner radius as needed
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isImageExpanded {
            return view.bounds.size
        } else {
            let width = (view.bounds.width - 20) / 3
            return CGSize(width: width, height: width)
        }
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let tappedIndexPath = collectionView.indexPath(for: collectionView.visibleCells.first(where: { ($0.contentView.subviews.first as? UIImageView) == tappedImageView })!)

        if isImageExpanded {
            UIView.animate(withDuration: 0.3, animations: {
                self.expandedImageView?.frame = self.originalIndexPath.flatMap { indexPath in
                    self.collectionView.cellForItem(at: indexPath)?.contentView.bounds
                } ?? .zero
                self.view.backgroundColor = .black
                self.collectionView.alpha = 1
            }) { _ in
                self.expandedImageView?.removeFromSuperview()
                self.isImageExpanded = false
            }
        } else {
            let expandedImageView = UIImageView(frame: collectionView.convert(tappedImageView.frame, from: tappedImageView.superview))
            expandedImageView.image = tappedImageView.image
            expandedImageView.contentMode = .scaleAspectFit
            expandedImageView.backgroundColor = .black
            expandedImageView.isUserInteractionEnabled = true
            expandedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:))))
            
            view.addSubview(expandedImageView)
            self.expandedImageView = expandedImageView
            self.originalIndexPath = tappedIndexPath
            
            UIView.animate(withDuration: 0.3) {
                expandedImageView.frame = self.view.bounds
                self.view.backgroundColor = .black
                self.collectionView.alpha = 0
            }
            isImageExpanded = true
        }
    }

    
    // Handles swipe right to return to ViewController
    @objc private func didSwipeRight() {
        dismiss(animated: true, completion: nil)
    }
}
