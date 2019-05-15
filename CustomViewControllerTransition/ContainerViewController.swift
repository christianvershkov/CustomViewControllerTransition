//
//  ContainerViewController.swift
//  CustomViewControllerTransition
//
//  Created by Christian Vershkov on 4/24/19.
//  Copyright © 2019 Christian Vershkov. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    var viewControllers: [UIViewController] = []
    var selectedViewController: UIViewController
    
    private var swipeInteractor: SwipeInteractor?
    private var rubberbandingGestureRecognizer = UIPanGestureRecognizer()
    private var containerView: UIView!
    
    init(viewControllers: [UIViewController], selectedViewControllerIndex: Int = 0) {
        guard viewControllers.isEmpty == false, selectedViewControllerIndex < viewControllers.count else {
            fatalError()
        }
        self.viewControllers = viewControllers
        self.selectedViewController = viewControllers[selectedViewControllerIndex]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard viewControllers.isEmpty == false else {
            fatalError()
        }
        
        containerView = UIView()
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        transition(from: nil, to: selectedViewController)
        
        swipeInteractor = SwipeInteractor(in: containerView) { [unowned self] direction in
            guard let currentIndex = self.viewControllers.firstIndex(where: { $0 === self.selectedViewController }) else {
                return false
            }
            
            var toViewController: UIViewController?
            if direction == .right && currentIndex != self.viewControllers.count - 1 {
                toViewController = self.viewControllers[currentIndex + 1]
            } else if direction == .left && currentIndex > 0 {
                toViewController = self.viewControllers[currentIndex - 1]
            }
            guard let to = toViewController else {
                return false
            }
            
            self.transition(from: self.selectedViewController, to: to)
            return true
        }
    }
}

private extension ContainerViewController {
    func transition(from: UIViewController?, to: UIViewController) {
        to.view.frame = containerView.bounds
        addChild(to)
        
        guard let from = from else {
            containerView.addSubview(to.view)
            to.didMove(toParent: self)
            return
        }
        
        let fromIndex = viewControllers.firstIndex(of: from) ?? 0
        let toIndex = viewControllers.firstIndex(of: to) ?? 0
        let direction: Direction = fromIndex < toIndex ? .left : .right
        
        let animator = SwipeAnimator(direction: direction)
        let transitionContext = SwipeTransitionContext(fromViewController: from, toViewController: to, containerView: containerView, direction: direction)
        
        transitionContext.percentValueUpdated = { percentComplete in
            //not used
        }
        
        transitionContext.completion = { [unowned self] didComplete in
            if didComplete {
                from.view.removeFromSuperview()
                from.removeFromParent()
                to.didMove(toParent: self)
                self.selectedViewController = to
            } else {
                to.view.removeFromSuperview()
                to.removeFromParent()
            }
            self.swipeInteractor?.reset()
            print(didComplete)
        }
        swipeInteractor?.animator = animator
        swipeInteractor?.startInteractiveTransition(transitionContext)
    }
}
