import AVFoundation
import UIKit

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
    
    // Thumbnail view to display captured photo
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
    
    // Image view to display captured photo
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black // Optional: Set background color for visibility
        imageView.isUserInteractionEnabled = true // Enable user interaction
        return imageView
    }()
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
        
        // Position thumbnail view in the bottom left corner
        thumbnailView.frame = CGRect(x: 20, y: view.frame.size.height - 140, width: 80, height: 80)
        
        // Bring shutter button to front
        view.bringSubviewToFront(shutterButton)
    }

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
    
    @objc private func didTapThumbnailView() {
        feedbackGenerator.impactOccurred() // Haptic feedback
        
        // Apply the same bouncing animation with less scaling to thumbnailView
        UIView.animate(withDuration: 0.1, // Initial scale down duration
                       animations: {
                           self.thumbnailView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.3, // Bounce up duration
                                          delay: 0,
                                          usingSpringWithDamping: 0.5,
                                          initialSpringVelocity: 1.0,
                                          options: .allowUserInteraction,
                                          animations: {
                                              self.thumbnailView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                                          },
                                          completion: { _ in
                                              UIView.animate(withDuration: 0.2, // Return to normal size duration
                                                             animations: {
                                                                 self.thumbnailView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                                                             },
                                                             completion: { _ in
                                                                 UIView.animate(withDuration: 0.1, // Final return to normal size duration
                                                                                animations: {
                                                                                    self.thumbnailView.transform = CGAffineTransform.identity
                                                                                },
                                                                                completion: { _ in
                                                                                    // Proceed with existing functionality
                                                                                    self.shutterButton.isHidden = true
                                                                                    self.imageView.image = self.thumbnailView.image
                                                                                    self.imageView.frame = self.view.bounds
                                                                                    self.view.addSubview(self.imageView)
                                                                                    
                                                                                    // Animate the image view appearing
                                                                                    self.imageView.alpha = 0
                                                                                    UIView.animate(withDuration: 0.3) {
                                                                                        self.imageView.alpha = 1
                                                                                    }
                                                                                })
                                                             })
                                          })
                       })
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        capturedPhotos.append(image)
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
        self.imageView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.imageView.alpha = 1
        }
    }
}
