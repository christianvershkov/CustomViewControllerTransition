//
//  SwipeInteractor.swift
//  CustomViewControllerTransition
//
//  Created by Christian Vershkov on 4/23/19.
//  Copyright © 2019 Christian Vershkov. All rights reserved.
//

import Foundation

import UIKit

extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}

struct Threshold {
    let velocity: CGPoint
    
    func isExceeded(forVelocity velocity: CGPoint) -> Bool {
        return abs(velocity.x) > self.velocity.x
    }
}

class SwipeInteractor: PercentDrivenInteractiveTransition {
    
    typealias PanGestureRecognizerBlock = (Direction) -> (Bool)
    
    // MARK: - Variables
    private var gestureRecognizedClosure: PanGestureRecognizerBlock?
    private var transitionGestureRecognizer = UIPanGestureRecognizer()
    private var rubberGestureRecognizer = UIPanGestureRecognizer()
    private var direction: Direction = .none
    private var interactionInProgress = false
    private var originalTouchPoint: CGPoint = .zero
    
    private var threshold = Threshold(velocity: CGPoint(x: 500, y: 0))
    
    init(in view: UIView, _ gestureRecognizedClosure: @escaping PanGestureRecognizerBlock) {
        super.init()
        self.gestureRecognizedClosure = gestureRecognizedClosure
        
        transitionGestureRecognizer.addTarget(self, action: #selector(handleTransitionPan(_:)))
        view.addGestureRecognizer(transitionGestureRecognizer)
    }
    
    func reset() {
        transitionGestureRecognizer.isEnabled = true
        direction = .none
        interactionInProgress = false
    }
}

private extension SwipeInteractor {
    @objc func handleTransitionPan(_ recognizer: UIPanGestureRecognizer) {
        defer {
            if !interactionInProgress {
                direction = .none
            }
        }
        
        let velocity = recognizer.velocity(in: recognizer.view)
        let translation = recognizer.translation(in: recognizer.view)
        let touchPoint = recognizer.location(in: recognizer.view)
        var xValue = translation.x
        
        if direction == .none {
            direction = velocity.x > 0 ? .left : .right
        }
        
        if (direction == .left && translation.x < 0) || (direction == .right && translation.x > 0) {
            xValue = 0
        }
        
        let percent: CGFloat = abs(xValue) / (recognizer.view?.bounds.width ?? 1)
        
        switch recognizer.state {
        case .began:
            interactionInProgress = gestureRecognizedClosure?(direction) ?? false
            originalTouchPoint = touchPoint
        case .changed:
            if interactionInProgress {
                updateInteractiveTransition(percentComplete: percent)
            } else {
                let offset = touchPoint.x - originalTouchPoint.x
                if let view = recognizer.view {
                    transform(view: view, with: offset)
                }
            }
        case .ended, .cancelled:
            if interactionInProgress {
                if threshold.isExceeded(forVelocity: velocity) || percent >= 0.5 {
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition()
                }
                recognizer.isEnabled = false
            } else {
                if let view = recognizer.view {
                    resetViewTrasformation(view: view)
                }
                let timingParameters = UISpringTimingParameters(damping: 0.6, response: 0.3)
                let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
                animator.addAnimations {
                    recognizer.view?.transform = .identity
                }
                animator.isInterruptible = true
                animator.startAnimation()
            }
        default:
            guard interactionInProgress else { return }
            cancelInteractiveTransition()
            break
        }
    }
}

extension SwipeInteractor {
    private func transform(view: UIView, with offset: CGFloat) {
        let newOffset = offset > 0 ? pow(offset, 0.7) : -pow(-offset, 0.7)
        view.transform = CGAffineTransform(translationX: newOffset, y: 0)
    }
    
    private func resetViewTrasformation(view: UIView) {
        let timingParameters = UISpringTimingParameters(damping: 0.6, response: 0.3)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            view.transform = .identity
        }
        animator.isInterruptible = true
        animator.startAnimation()
    }
}
