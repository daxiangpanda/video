//
//  PickerPresentationController.m
//  vtell
//
//  Created by chenzheng on 15/11/2017.
//  Copyright © 2017 sohu. All rights reserved.
//

#import "PickerPresentationController.h"
//#import "VTPrepareRecordController.h"
//#import "VTCardSwitchCell.h"
//#import "VTCardSwitchView.h"

@implementation PickerPresentationController


- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    
    return presentedViewControllerFrame;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? 0.3 : 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
//    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
//    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    NSTimeInterval duration = [self transitionDuration:transitionContext];

    if ([self.presentingViewController isKindOfClass:[VTNavigationController class]]) {
        toView.frame = toViewFinalFrame;
        [containerView addSubview:toView];
        
        VTPrepareRecordController *prepareVC = (VTPrepareRecordController *)(((VTNavigationController *)self.presentingViewController).topViewController);
        VTCardSwitchView *switchView = prepareVC.cardSwitchView;
        NSIndexPath *indexPath = [switchView.collectionView indexPathsForSelectedItems].firstObject;
        if (!indexPath) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        
        VTCardSwitchCell *cell = (VTCardSwitchCell *)[switchView.collectionView cellForItemAtIndexPath:indexPath];
        
        if (isPresenting) {
            UIView *snapshot = [cell snapshotViewAfterScreenUpdates:NO];
            snapshot.bounds = cell.bounds;
            snapshot.frame = [cell convertRect:cell.bounds toView:containerView];
            toView.alpha = 0;
            
            [containerView addSubview:snapshot];
            
            [UIView animateWithDuration:duration animations:^{
                snapshot.frame = toViewFinalFrame;
                toView.alpha = 1;
                snapshot.alpha = 0.0;
            } completion:^(BOOL finished) {
                BOOL wasCancelled = [transitionContext transitionWasCancelled];
                [snapshot removeFromSuperview];
                [transitionContext completeTransition:!wasCancelled];
            }];
        } else {
            UIView *snapshot = [fromView snapshotViewAfterScreenUpdates:NO];
            snapshot.frame = fromViewInitialFrame;
            snapshot.layer.cornerRadius = 16;
            snapshot.layer.masksToBounds = YES;
            CGRect snapshotFinalFrame = [cell convertRect:cell.bounds toView:containerView];
            
            fromView.frame = CGRectZero;
            
            [containerView addSubview:snapshot];

            [UIView animateWithDuration:duration animations:^{
                snapshot.frame = snapshotFinalFrame;
                snapshot.alpha = 0;
            } completion:^(BOOL finished) {
                BOOL wasCancelled = [transitionContext transitionWasCancelled];
                if (wasCancelled) {
                    fromView.frame = fromViewInitialFrame;
                }
                [snapshot removeFromSuperview];
                [transitionContext completeTransition:!wasCancelled];

            }];
        }
    } else {
        [super animateTransition:transitionContext];
    }
    
}

@end
