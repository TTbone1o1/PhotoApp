import UIKit

class PhotoAppFront: UIViewController {

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Go Take A Photo"
        label.textColor = .black // Ensure the text color contrasts with the background
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false // Enable auto layout
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(instructionLabel)
        
        // Set up constraints to center the label in the view
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add a swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }

    @objc private func didSwipeRight() {
        let viewController = ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
