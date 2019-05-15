//
//  SwipeAnimator.swift
//  CustomViewControllerTransition
//
//  Created by Christian Vershkov on 4/23/19.
//  Copyright © 2019 Christian Vershkov. All rights reserved.
//

import UIKit

enum Direction {
    case left, right, none
}

class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private struct Constants {
        static let defaultDuration: Double = 0.3
        static let childViewPadding: CGFloat = 16
    }
    
    private var duration: Double
    private var direction: Direction
    private var propertyAnimator: UIViewPropertyAnimator?
    
    init(duration: Double = Constants.defaultDuration, direction: Direction) {
        self.duration = duration
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                fatalError()
        }
        
        let travelDistance = transitionContext.containerView.bounds.width + Constants.childViewPadding
        let travel = CGAffineTransform(translationX: direction == .right ? travelDistance : -travelDistance, y: 0)
        transitionContext.containerView.addSubview(toView)
        toView.alpha = 0
        toView.transform = travel.inverted()
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeIn) {
            fromView.transform = travel
            fromView.alpha = 0
            toView.transform = .identity
            toView.alpha = 1
        }
        
        animator.addCompletion { _ in
            if transitionContext.transitionWasCancelled {
                transitionContext.completeTransition(false)
            } else {
                transitionContext.completeTransition(true)
            }
            
            // reset views after animation for being reused in the future
            toView.transform = .identity
            fromView.transform = .identity
        }
        propertyAnimator = animator
        return animator
    }
}
