#import "DPToastView.h"
#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"


NSString* const DPToastViewWillShowNotification    = @"DPToastViewWillShowNotification";
NSString* const DPToastViewDidShowNotification     = @"DPToastViewDidShowNotification";
NSString* const DPToastViewWillDismissNotification = @"DPToastViewWillDismissNotification";
NSString* const DPToastViewDidDismissNotification  = @"DPToastViewDidDismissNotification";


@interface DPToastView ()

@end


@implementation DPToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayingDuration = 2.0;
    }
    return self;
}

#pragma mark - Show Hide

- (void)show
{
    if ([DPToastViewManager sharedManager].currentToastView == nil) {
        _showAnimating = YES;
        _showing = YES;
        [[DPToastViewManager sharedManager] dequeueToastView:self];
        [[DPToastViewManager sharedManager] setCurrentToastView:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewWillShowNotification object:self];
        
        void (^comp)(BOOL) = ^(BOOL finished){
            _showAnimating = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidShowNotification object:self];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_displayingDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismiss];
            });
        };
        
        {
            #warning この括弧内を汎用的になるように実装する
            self.hidden = NO;
            self.alpha  = 0.0;
            
            UIViewController* targetViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            UIView*           targetView           = targetViewController.view;
            
            [targetView addSubview:self];
            
            void (^anim)(void) = ^{
                self.alpha = 1.0;
            };
            NSTimeInterval animationDuration = 1.0;
            NSTimeInterval animationDelay    = 0.0;
            UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
        }
        
    }
    else {
        [[DPToastViewManager sharedManager] enqueueToastView:self];
    }
}

- (void)dismiss
{
    if ([[DPToastViewManager sharedManager].currentToastView isEqual:self]) {
        void (^comp)(BOOL) = ^(BOOL finished){
            _dismissAnimating = NO;
            _showing = NO;
            [self removeFromSuperview];
            [[DPToastViewManager sharedManager] setCurrentToastView:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidDismissNotification object:self];
            [[DPToastViewManager sharedManager] showHeadToastViewIfExist];
        };
        
        _dismissAnimating = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewWillDismissNotification object:self];
        
        {
            #warning この括弧内を汎用的になるように実装する
            void (^anim)(void) = ^{
                self.alpha = 0.0;
            };
            NSTimeInterval animationDuration = 1.0;
            NSTimeInterval animationDelay    = 0.0;
            UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
        }
        
    }
}

@end
