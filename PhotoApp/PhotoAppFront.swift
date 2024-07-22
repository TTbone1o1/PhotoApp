import UIKit

class PhotoAppFront: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Go Take A Photo"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func handleSwipe() {
        let viewController = ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
