#import "DPToastView.h"
#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"
#import "DPToastViewAnimator.h"


NSString* const DPToastViewWillShowNotification    = @"DPToastViewWillShowNotification";
NSString* const DPToastViewDidShowNotification     = @"DPToastViewDidShowNotification";
NSString* const DPToastViewWillDismissNotification = @"DPToastViewWillDismissNotification";
NSString* const DPToastViewDidDismissNotification  = @"DPToastViewDidDismissNotification";


@interface DPToastView ()
{
    __weak UISwipeGestureRecognizer* _swipeGestureRecognizer;
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
        _displayingDuration = 2.0;
        _animator = [[DPToastViewAnimator alloc] initWithToastView:self];
        self.clipsToBounds = YES;
        self.hidden = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self initializeSubViews];
        
        {
            UISwipeGestureRecognizer* gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecognizer:)];
            gr.direction = UISwipeGestureRecognizerDirectionUp;
            [self addGestureRecognizer:gr];
            _swipeGestureRecognizer = gr;
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
    
    if (targetView != self.superview) {
        [targetView addSubview:self];
    }
    
    if ([DPToastViewManager sharedManager].currentToastView == nil) {
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

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    if (swipeGestureRecognizer == _swipeGestureRecognizer) {
        [self dismiss];
    }
}

@end
