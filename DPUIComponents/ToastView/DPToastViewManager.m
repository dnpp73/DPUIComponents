#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"
#import "DPToastView.h"
#import "DPToastView_Private.h"


@interface DPToastViewManager ()
{
    NSMutableArray* _queueingToastViews;
}

@end


@implementation DPToastViewManager

#pragma mark - Singleton Pattern

+ (instancetype)sharedManager
{
    static DPToastViewManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initSharedInstance];
    });
    return manager;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initSharedInstance
{
    self = [super init];
    if (self) {
        _queueingToastViews = [NSMutableArray array];
    }
    return self;
}

#pragma mark -

- (void)enqueueToastView:(DPToastView*)toastView // Public
{
    if ([toastView isKindOfClass:[DPToastView class]] == NO) {
        return;
    }
    if ([_currentToastView isEqual:toastView]) {
        return;
    }
    if ([_queueingToastViews containsObject:toastView]) {
        return;
    }
    
    [_queueingToastViews addObject:toastView];
    if (_showingToastView == NO) {
        [self showHeadToastViewIfExist];
    }
}

- (void)dequeueToastView:(DPToastView*)toastView // Public
{
    if ([_currentToastView isEqual:toastView] == NO) {
        if ([_queueingToastViews containsObject:toastView]) {
            [_queueingToastViews removeObject:toastView];
        }
    }
}

- (void)showHeadToastViewIfExist // Private
{
    if (_queueingToastViews.count == 0) {
        return;
    }
    
    if (_showingToastView) {
        return;
    }
    
    DPToastView* toastView = _queueingToastViews[0];
    [_queueingToastViews removeObject:toastView];
    _currentToastView = toastView;
    _showingToastView = YES;

    UIViewController* targetViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView*           targetView           = targetViewController.view;

    [targetView addSubview:toastView];
    toastView.showAnimating = YES;
    
    void (^comp)(BOOL) = ^(BOOL finished){
        toastView.showAnimating = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(toastView.displayingDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissToastView:toastView];
        });
    };
    
    {
        #warning この括弧内を汎用的になるように実装する
        toastView.hidden = NO;
        toastView.alpha  = 0.0;
        void (^anim)(void) = ^{
            toastView.alpha = 1.0;
        };
        NSTimeInterval animationDuration = 1.0;
        NSTimeInterval animationDelay    = 0.0;
        UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
    }
}

- (void)dismissCurrentToastView // Public
{
    [self dismissToastView:_currentToastView];
}

- (void)dismissToastView:(DPToastView*)toastView // Private
{
    if ([toastView isKindOfClass:[DPToastView class]] == NO) {
        return;
    }
    if ([_currentToastView isEqual:toastView] == NO) {
        return;
    }
    
    toastView.dismissAnimating = YES;
    
    void (^comp)(BOOL) = ^(BOOL finished){
        toastView.dismissAnimating = NO;
        [toastView removeFromSuperview];
        _currentToastView = nil;
        _showingToastView = NO;
        
        [self showHeadToastViewIfExist];
    };

    {
        #warning この括弧内を汎用的になるように実装する
        void (^anim)(void) = ^{
            toastView.alpha = 0.0;
        };
        NSTimeInterval animationDuration = 1.0;
        NSTimeInterval animationDelay    = 0.0;
        UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:animationDuration delay:animationDelay options:options animations:anim completion:comp];
    }
}

#pragma mark - getter

- (NSArray*)queueingToastViews
{
    return _queueingToastViews.copy;
}

#ifdef DEBUG
- (void)printState
{
    NSLog(@"%d, %d, %d", _currentToastView.isShowing, _currentToastView.isShowAnimating, _currentToastView.isDismissAnimating);
}
#endif

@end
