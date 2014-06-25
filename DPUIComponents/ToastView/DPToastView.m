#import "DPToastView.h"
#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"
#import "DPToastViewAnimator.h"


NSString* const DPToastViewWillShowNotification    = @"DPToastViewWillShowNotification";
NSString* const DPToastViewDidShowNotification     = @"DPToastViewDidShowNotification";
NSString* const DPToastViewWillDismissNotification = @"DPToastViewWillDismissNotification";
NSString* const DPToastViewDidDismissNotification  = @"DPToastViewDidDismissNotification";


@interface DPToastView ()

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
        self.clipsToBounds = YES;
        _animator = [[DPToastViewAnimator alloc] initWithToastView:self];
        [self initializeSubViews];
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
        
        [_animator showAnimationWithCallback:comp];
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
        
        [_animator dismissAnimationWithCallback:comp];        
    }
}

@end
