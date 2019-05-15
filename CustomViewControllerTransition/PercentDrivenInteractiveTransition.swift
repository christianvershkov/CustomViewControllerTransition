//
//  PercentDrivenInteractiveTransition.swift
//  CustomViewControllerTransition
//
//  Created by Christian Vershkov on 4/25/19.
//  Copyright © 2019 Christian Vershkov. All rights reserved.
//

import UIKit

class PercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    /// Actual animation
    var animator: UIViewControllerAnimatedTransitioning?
    
    private var transitionContext: UIViewControllerContextTransitioning?
    private var interruptibleAnimator: UIViewImplicitlyAnimating?
    private var duration: TimeInterval {
        guard let transitionContext = transitionContext else {
            return 0
        }
        return animator?.transitionDuration(using: transitionContext) ?? 0
    }
    
    // MARK: - Public
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        interruptibleAnimator = animator?.interruptibleAnimator?(using: transitionContext)
        interruptibleAnimator?.startAnimation()
        interruptibleAnimator?.pauseAnimation()
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        setPercentComplete(percentComplete: (CGFloat(fmaxf(fminf(Float(percentComplete), 0.999), 0.001))))
    }
    
    func cancelInteractiveTransition() {
        transitionContext?.cancelInteractiveTransition()
        completeTransition(position: .start)
    }
    func finishInteractiveTransition() {
        transitionContext?.finishInteractiveTransition()
        completeTransition(position: .end)
    }
}

// MARK: - Private

extension PercentDrivenInteractiveTransition {
    private func setPercentComplete(percentComplete: CGFloat) {
        interruptibleAnimator?.fractionComplete = percentComplete
        transitionContext?.updateInteractiveTransition(percentComplete)
    }
    
    private func completeTransition(position: UIViewAnimatingPosition) {
        guard let animator = interruptibleAnimator else { return }
        
        animator.isReversed = position == .start ? true : false
        let durationFactor = 1 - ((CGFloat(duration) * animator.fractionComplete) / CGFloat(duration))
        animator.continueAnimation?(withTimingParameters: nil, durationFactor: durationFactor)
    }
}
