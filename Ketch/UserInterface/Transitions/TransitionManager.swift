//
//  TransitionManager.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Spring

class RootTransition : ViewControllerTransition {
    let rootView : RootView
    
    init(_ rootView: RootView, fromVC: UIViewController, toVC: UIViewController, duration: NSTimeInterval = 0.6) {
        self.rootView = rootView
        super.init(fromVC: fromVC, toVC: toVC, duration: duration)
    }
    
    override func animate() {
        if let vc = toVC as? BaseViewController {
            rootView.waterlineLocation = vc.waterlineLocation
        }
        containerView.addSubview(toView!)
        toView?.frame = context.finalFrameForViewController(toVC)
        toView?.alpha = 0
        fromView?.alpha = 1
        springWithCompletion(duration, {
            self.toView?.alpha = 1
            self.fromView?.alpha = 0
            self.rootView.layoutIfNeeded()
        }) { completed in
            self.context.completeTransition(true)
        }
    }
}

extension RootViewController : UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? BaseViewController {
            rootView.ketchIcon.hidden = vc.hideKetchBoat
            // TODO: This doesn't seem to work, maybe we need transitioningCoordinator?
//            if !animated {
//                rootView.waterlineLocation = vc.waterlineLocation
//            }
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch (fromVC, toVC) {
            
        case let (fromVC as LoadingViewController, toVC as SignupViewController):
            return SignupTransition(self.rootView, loadingVC: fromVC, signupVC: toVC)
            
        case let (fromVC as LoadingViewController, toVC as WaitlistViewController):
            return WaitlistTransition(self.rootView, loadingVC: fromVC, waitlistVC: toVC)
            
        case let (fromVC as LoadingViewController, toVC as GameViewController):
            return NewGameTransition(self.rootView, loadingVC: fromVC, gameVC: toVC)
            
        case (_ as GameViewController, _ as DockViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .RightToLeft, panGesture: currentEdgePan)
            
        case (_ as DockViewController, _ as GameViewController):
            return ScrollTransition(fromVC: fromVC, toVC: toVC, direction: .LeftToRight, panGesture: currentEdgePan)
            
        default:
            return RootTransition(rootView, fromVC: fromVC, toVC: toVC)
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? ViewControllerTransition)?.interactor
    }
}
