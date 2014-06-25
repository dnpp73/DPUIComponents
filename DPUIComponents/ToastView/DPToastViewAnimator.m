#import "DPToastViewAnimator.h"
#import "DPToastView.h"


@interface DPToastViewAnimator ()

@end


@implementation DPToastViewAnimator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithToastView:(DPToastView*)toastView
{
    self = [super init];
    if (self) {
        _toastView = toastView;
        _showAnimationDuration    = 0.5;
        _dismissAnimationDuration = 0.5;
    }
    return self;
}

- (void)showAnimationWithCallback:(void (^)(BOOL))callback
{
    if (_toastView == nil || _toastView.targetView == nil) {
        if (callback) {
            callback(NO);
        }
        return;
    }
    
    _toastView.hidden = NO;
    _toastView.alpha  = 0.3;
    _toastView.containerView.frame = CGRectOffset(_toastView.bounds, 0, -_toastView.bounds.size.height);
    
    [_toastView.targetView addSubview:_toastView];
    
    void (^anim)(void) = ^{
        _toastView.alpha = 1.0;
        _toastView.containerView.frame = _toastView.bounds;
    };
    NSTimeInterval animationDuration = _showAnimationDuration;
    NSTimeInterval animationDelay    = 0.0;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:callback];
}

- (void)dismissAnimationWithCallback:(void (^)(BOOL))callback
{
    if (_toastView == nil || _toastView.targetView == nil) {
        if (callback) {
            callback(NO);
        }
        return;
    }
    
    void (^anim)(void) = ^{
        _toastView.alpha = 0.4;
        _toastView.containerView.frame = CGRectOffset(_toastView.bounds, 0, -_toastView.bounds.size.height);
    };
    NSTimeInterval animationDuration = _dismissAnimationDuration;
    NSTimeInterval animationDelay    = 0.0;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:callback];
}

@end
