import UIKit

class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6 // Adjust this value if needed for longer/shorter animations
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let screenWidth = containerView.bounds.width
        let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
        
        // Initial setup for views
        if isPresenting {
            toView.frame = finalFrame.offsetBy(dx: screenWidth, dy: 0)
            toView.alpha = 0
            containerView.addSubview(toView)
            
            // Spring animation
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.6, // Increased bounciness
                           initialSpringVelocity: 1.0, // Faster initial velocity
                           options: .curveEaseInOut,
                           animations: {
                            fromView.frame = fromView.frame.offsetBy(dx: -screenWidth, dy: 0)
                            fromView.alpha = 0
                            toView.frame = finalFrame
                            toView.alpha = 1
                           },
                           completion: { finished in
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        } else {
            toView.frame = finalFrame
            toView.alpha = 1
            containerView.addSubview(toView)
            containerView.bringSubviewToFront(fromView)
            
            // Spring animation
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.6, // Increased bounciness
                           initialSpringVelocity: 1.0, // Faster initial velocity
                           options: .curveEaseInOut,
                           animations: {
                            fromView.frame = fromView.frame.offsetBy(dx: screenWidth, dy: 0)
                            fromView.alpha = 0
                            toView.alpha = 1
                           },
                           completion: { finished in
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        }
    }
}
