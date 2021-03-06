//
//  ScrollTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ScrollTransition : ViewControllerTransition {
    enum Direction {
        case RightToLeft, LeftToRight
    }
    let direction : Direction
    
    init(fromVC: UIViewController, toVC: UIViewController, direction: Direction, panGesture: UIPanGestureRecognizer?) {
        self.direction = direction
        super.init(fromVC: fromVC, toVC: toVC, interactor: panGesture.map { PanInteractor($0) })
        duration = 0.3
    }
    
    override func animate() -> RACSignal {
        var leftFrame = containerView.bounds
        leftFrame.origin.x -= leftFrame.width
        var centerFrame = containerView.bounds
        var rightFrame = containerView.bounds
        rightFrame.origin.x += rightFrame.width
        
        self.containerView.addSubview(self.toView!)
        var toInitialFrame = direction == .RightToLeft ? rightFrame : leftFrame
        var fromFinalFrame = direction == .RightToLeft ? leftFrame : rightFrame
        toView?.frame = toInitialFrame
        
        return UIView.animate(duration, options: .CurveEaseInOut) {
            self.fromView?.frame = fromFinalFrame
            self.toView?.frame = centerFrame
        }.doCompleted {
            if (self.cancelled) {
                self.fromView?.frame = centerFrame
            }
        }
    }
}