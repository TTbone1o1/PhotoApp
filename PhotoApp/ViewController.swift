import AVFoundation
import UIKit
import Photos

class ViewController: UIViewController {

    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Array to store captured photos
    var capturedPhotos: [UIImage] = []

    // Shutter button
    private let shutterButton: UIView = {
        let outerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        outerCircle.layer.cornerRadius = 37.5
        outerCircle.layer.borderWidth = 2
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.backgroundColor = .clear
        
        let innerCircle = UIView(frame: CGRect(x: 5, y: 5, width: 65, height: 65))
        innerCircle.layer.cornerRadius = 32.5
        innerCircle.backgroundColor = .white
        
        outerCircle.addSubview(innerCircle)
        return outerCircle
    }()
    
    // ThumbnailView Displays the last captured photo
    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // Image view to display captured photo in full screen
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black // Optional: Set background color for visibility
        imageView.isUserInteractionEnabled = true // Enable user interaction
        return imageView
    }()
    
    // Haptics
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // Sets up the view and adds the preview layer, It also sets up tap gestures for taking photos, viewing images, and handling thumbnail interactions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(thumbnailView) // Add thumbnail view to the view
        checkCameraPermissions()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTakePhoto))
        shutterButton.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer to imageView
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(imageTapGesture)
        
        // Add tap gesture recognizer to thumbnailView
        let thumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThumbnailView))
        thumbnailView.addGestureRecognizer(thumbnailTapGesture)

        // Add swipe gesture recognizer for navigating to photo library screen
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
    }

    // Lays out the subviews. Meant for positioning
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
        
        // Position thumbnail view in the bottom left corner
        thumbnailView.frame = CGRect(x: 20, y: view.frame.size.height - 140, width: 80, height: 80)
        
        // Bring shutter button to front
        view.bringSubviewToFront(shutterButton)
    }

    // Check the camera's permission and sets up if granted
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted, .denied:
            // Handle restricted/denied case
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }

    // Configures the camera session by adding input (camera) and output (photo capture) to the session and starts it
    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }

    // Handles the shutter button tap, generates haptic feedback, and captures a photo. It also includes an animation sequence for the shutter button.
    @objc private func didTapTakePhoto() {
        feedbackGenerator.impactOccurred() // Haptic feedback
        
        // Add enhanced bouncing animation
        UIView.animate(withDuration: 0.1, // Initial scale down duration
                       animations: {
                           self.shutterButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.3, // Bounce up duration
                                          delay: 0,
                                          usingSpringWithDamping: 0.5,
                                          initialSpringVelocity: 1.0,
                                          options: .allowUserInteraction,
                                          animations: {
                                              self.shutterButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                          },
                                          completion: { _ in
                                              UIView.animate(withDuration: 0.2, // Return to normal size duration
                                                             animations: {
                                                                 self.shutterButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                                             },
                                                             completion: { _ in
                                                                 UIView.animate(withDuration: 0.1, // Final return to normal size duration
                                                                                animations: {
                                                                                    self.shutterButton.transform = CGAffineTransform.identity
                                                                                },
                                                                                completion: { _ in
                                                                                    // Bounce-out animation
                                                                                    UIView.animate(withDuration: 0.3, // Bounce-out duration
                                                                                                   animations: {
                                                                                                       self.shutterButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                                                                                                   },
                                                                                                   completion: { _ in
                                                                                                       self.shutterButton.isHidden = true // Hide the shutter button after bounce-out
                                                                                                       self.shutterButton.transform = CGAffineTransform.identity // Reset the transformation
                                                                                                   })
                                                                                })
                                                             })
                                          })
                       })
        
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    // Handles the image view tap to hide the displayed image, restart the camera session, and show the shutter button again.
    @objc private func didTapImageView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.alpha = 0
        }) { _ in
            self.imageView.removeFromSuperview() // Remove the image view
            self.session?.startRunning() // Restart the camera session
            self.shutterButton.isHidden = false // Show the shutter button again
            UIView.animate(withDuration: 0.3) {
                self.shutterButton.alpha = 1
            }
        }
    }
    
    // Handles the thumbnail view tap to show the full-screen image view with an animation.
    @objc private func didTapThumbnailView() {
        feedbackGenerator.impactOccurred()
        
        // Convert frames to view's coordinate space
        let thumbnailInitialFrame = thumbnailView.convert(thumbnailView.bounds, to: view)
        let imageViewFinalFrame = view.convert(imageView.bounds, from: imageView)
        
        // Create a snapshot of the thumbnail view
        let thumbnailSnapshot = UIImageView(frame: thumbnailInitialFrame)
        thumbnailSnapshot.image = thumbnailView.image
        thumbnailSnapshot.contentMode = .scaleAspectFill
        thumbnailSnapshot.clipsToBounds = true
        view.addSubview(thumbnailSnapshot)
        
        // Hide the original thumbnail view
        thumbnailView.isHidden = true
        
        // Set up the image view
        imageView.frame = view.bounds
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.addSubview(imageView)
        
        // Perform the animation with Core Animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            // Animate the snapshot to match the final image view frame
            thumbnailSnapshot.frame = imageViewFinalFrame
            thumbnailSnapshot.alpha = 0
            
            // Animate the image view appearance
            self.imageView.alpha = 1
            self.imageView.transform = .identity
        }, completion: { _ in
            // Cleanup
            thumbnailSnapshot.removeFromSuperview()
            self.thumbnailView.isHidden = false
        })
    }

    // Handles swipe left to show the photo library screen
    @objc private func didSwipeLeft() {
        let photoLibraryVC = PhotoLibraryViewController()
        photoLibraryVC.modalPresentationStyle = .fullScreen
        present(photoLibraryVC, animated: true, completion: nil)
    }

    // Save photo to library
    private func savePhotoToLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        print("Photo saved to library")
                    } else if let error = error {
                        print("Error saving photo: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Photo library access denied")
            }
        }
    }
}

// Captures the photo, processes it, stores it in capturedPhotos, updates the thumbnailView, and displays the captured image in the imageView with an animation.
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        capturedPhotos.append(image)
        savePhotoToLibrary(image) // Save to photo library
        thumbnailView.image = image
        thumbnailView.transform = .identity // Reset thumbnail view transformation
        
        // Optionally: add a brief animation to the thumbnail view
        UIView.animate(withDuration: 0.3) {
            self.thumbnailView.alpha = 1
        }
        
        // Stop camera session and display captured photo
        session?.stopRunning()
        self.imageView.image = image
        self.imageView.frame = self.view.bounds
        self.view.addSubview(self.imageView)
        
        // Animate the image view appearing
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: [.curveEaseInOut], animations: {
            self.imageView.transform = CGAffineTransform.identity
            self.imageView.alpha = 1
        })
    }
}
