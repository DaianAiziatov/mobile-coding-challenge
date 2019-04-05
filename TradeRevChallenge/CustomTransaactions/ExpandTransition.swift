//
//  CustomTransition.swift
//  TradeRevChallenge
//
//  Created by Daian Aiziatov on 04/04/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import UIKit

class ExpandTransition: NSObject, UIViewControllerAnimatedTransitioning {

    enum ExpandTransitionMode {
        case present
        case dismiss
    }

    var transitionMode: ExpandTransitionMode = .present
    var origin = CGPoint.zero
    var selectedCell: UICollectionViewCell?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        switch transitionMode {
        case .present:
            guard let toView = transitionContext.view(forKey: .to),
                let cellSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
                else {
                    transitionContext.completeTransition(false)
                    return
            }
            toView.alpha = 0
            cellSnapshot.frame.origin = origin
            containerView.addSubview(cellSnapshot)
            containerView.addSubview(toView)
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: [.curveEaseIn],
                           animations: {
                            cellSnapshot.center = toView.center
                            cellSnapshot.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            }, completion: { _ in
                toView.alpha = 1
                cellSnapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        case .dismiss:
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: [.curveEaseIn],
                           animations: {
                            fromView.alpha = 0
                            fromView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }, completion: { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }


}


