//
//  TransitionOperator.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

//This class will manage the animation going on during the transition.
//This class derives from UIViewControllerAnimatedTransitioning & UIViewControllerTransitioningDelegate to handle the methods necessary
class TransitionOperator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    //show a snapshot of current view controller during the animatin
    var snapshot: UIView!
    var isPresenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            presentNavigation(transitionContext)
        } else {
            dismissNavigation(transitionContext)
        }
    }
    
    func presentNavigation(_ transitionContext: UIViewControllerContextTransitioning) {
        //get the views from the context
        let container = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewController(forKey: .to)
        let toView = toViewController!.view
        
        //create a transform object by translating & reverse-scaling the item to be pushed
        let size = toView?.frame.size
        var offSetTransform = CGAffineTransform(translationX: (size?.width)! - 120, y: 0)
        offSetTransform = offSetTransform.scaledBy(x: 0.9, y: 0.9)
        
        //create a snapshot, to display in the context container
        snapshot = fromView?.snapshotView(afterScreenUpdates: true)
        
        //add the snapshot & the toView to the container context & then perform animations
        container.addSubview(toView!)
        container.addSubview(snapshot)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [], animations: {
            self.snapshot.transform = offSetTransform
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
    
    //animate the snapshot back to the main screen where it was.
    func dismissNavigation(_ transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [], animations: {
            self.snapshot.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(true)
            self.snapshot.removeFromSuperview()
        })
    }
    
    //specifies our new TransitionOperator class & the controller responsible for the animations
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
}
