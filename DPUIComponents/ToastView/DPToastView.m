#import "DPToastView.h"
#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"
#import "DPToastViewAnimator.h"
#import "UIView+dp_recursiveUtils.h"


NSString* const DPToastViewWillShowNotification    = @"DPToastViewWillShowNotification";
NSString* const DPToastViewDidShowNotification     = @"DPToastViewDidShowNotification";
NSString* const DPToastViewWillDismissNotification = @"DPToastViewWillDismissNotification";
NSString* const DPToastViewDidDismissNotification  = @"DPToastViewDidDismissNotification";


@interface DPToastView ()
{
    __weak UIPanGestureRecognizer* _panGestureRecognizer;
    __weak UITapGestureRecognizer* _tapGestureRecognizer;
}

@end


@implementation DPToastView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayingDuration = 2.5;
        _animator = [[DPToastViewAnimator alloc] initWithToastView:self];
        self.clipsToBounds = YES;
        self.hidden = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self initializeSubViews];
        
        {
            UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
            [_containerView addGestureRecognizer:pgr];
            _panGestureRecognizer = pgr;
            
            UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
            [_containerView addGestureRecognizer:tgr];
            _tapGestureRecognizer = tgr;
            
            [_tapGestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
        }
    }
    return self;
}

- (void)initializeSubViews
{
    UIView* containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    {
        UIView* backgroundView = [[UIView alloc] initWithFrame:containerView.bounds];
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        backgroundView.userInteractionEnabled = NO;
        [containerView addSubview:backgroundView];
        _backgroundView = backgroundView;
    }
    
    {
        UIView* contentsView = [[UIView alloc] initWithFrame:containerView.bounds];
        contentsView.backgroundColor = [UIColor clearColor];
        contentsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [containerView addSubview:contentsView];
        _contentsView = contentsView;
    }
    
    [self addSubview:containerView];
    _containerView = containerView;
}

#pragma mark - Show Hide

- (void)showInView:(UIView*)targetView
{
    if (targetView == nil) {
        [[DPToastViewManager sharedManager] dequeueToastView:self];
        [self removeFromSuperview];
        if ([DPToastViewManager sharedManager].currentToastView == nil) {
            [[DPToastViewManager sharedManager] showHeadToastViewIfExist];
        }
        return;
    }
    
    _targetView = targetView;
    
    if ([DPToastViewManager sharedManager].currentToastView == nil) {
        if (targetView != self.superview) {
            [targetView addSubview:self];
        }
        _showAnimating = YES;
        _showing = YES;
        [[DPToastViewManager sharedManager] dequeueToastView:self];
        [[DPToastViewManager sharedManager] setCurrentToastView:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewWillShowNotification object:self];
        
        void (^comp)(BOOL) = ^(BOOL finished){
            _showAnimating = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidShowNotification object:self];
            
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:_displayingDuration];
        };
        
        [_animator showAnimationWithCallback:comp];
    }
    else {
        [[DPToastViewManager sharedManager] enqueueToastView:self];
    }
}

- (void)dismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    if (self.dp_recursiveTrackingCheck) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:_displayingDuration];
        return;
    }
    
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
        
        [_animator dismissAnimationWithCallback:comp];        
    }
}

#pragma mark - UIGestureRecognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if (panGestureRecognizer == _panGestureRecognizer) {
        static CGPoint beganLocation;
        static CGRect  beganContainerFrame;
        static CGFloat beganAlpha;
        
        UIGestureRecognizerState state = panGestureRecognizer.state;
        if (state == UIGestureRecognizerStateBegan) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
            _tracking = YES;
            beganLocation = [panGestureRecognizer locationInView:self];
            beganContainerFrame = _containerView.frame;
            beganAlpha = _containerView.alpha;
        }
        else if (state == UIGestureRecognizerStateChanged) {
            _dragging = YES;
            
            CGPoint location = [panGestureRecognizer locationInView:self];
            {
                CGFloat y = location.y - beganLocation.y;
                y = MIN(y, 0);
                CGRect rect = CGRectOffset(beganContainerFrame, 0, y);
                _containerView.frame = rect;
            }
            {
                CGFloat alpha = beganAlpha;
                {   // 0.2 から 1.0 の間を取る感じにするやつ
                    alpha = (location.y - beganLocation.y) / beganContainerFrame.size.height + 1.0;
                    alpha = MIN(1.0, alpha);
                    alpha = MAX(0.0, alpha);
                    alpha *= beganAlpha;
                    CGFloat d = 0.2;
                    alpha *= (1.0-d)/1.0;
                    alpha += d;
                }
                _containerView.alpha = alpha;
            }
        }
        else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
            if (state == UIGestureRecognizerStateCancelled) {
                ;
            }
            else {
                
            }
            
            _tracking = NO;
            _dragging = NO;
            
            CGPoint v = [panGestureRecognizer velocityInView:self];
            if (v.y < -60 || _containerView.frame.origin.y <= -(_containerView.frame.size.height)) {
                void (^anim)(void) = ^{
                    _containerView.frame = CGRectOffset(beganContainerFrame, 0, -beganContainerFrame.size.height);
                    _containerView.alpha = 0.2;
                };
                void (^comp)(BOOL) = ^(BOOL finished){
                    [self dismiss];
                };
                NSTimeInterval animationDuration = 40.0 / fabs(v.y);
                NSTimeInterval animationDelay    = 0.0;
                UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState;
                [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
            } else {
                panGestureRecognizer.enabled = NO;
                void (^anim)(void) = ^{
                    _containerView.frame = beganContainerFrame;
                    _containerView.alpha = beganAlpha;
                };
                void (^comp)(BOOL) = ^(BOOL finished){
                    panGestureRecognizer.enabled = YES;
                    [self performSelector:@selector(dismiss) withObject:nil afterDelay:_displayingDuration];
                };
                NSTimeInterval animationDuration = (_containerView.frame.size.height - (_containerView.frame.size.height + _containerView.frame.origin.y)) * 0.005 + 0.08;
                NSTimeInterval animationDelay    = 0.0;
                UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
                [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
            }
            
        }
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer*)tapGestureRecognizer
{
    if (tapGestureRecognizer == _tapGestureRecognizer) {
        if ([self.delegate respondsToSelector:@selector(toastViewDidTapped:)]) {
            [self.delegate toastViewDidTapped:self];
        }
    }
}

@end
