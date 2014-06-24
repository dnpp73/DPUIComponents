#import "DPToastViewManager.h"
#import "DPToastView.h"


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
    
#warning 実装する
    {
        [[[[UIApplication sharedApplication] keyWindow] rootViewController].view addSubview:toastView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(toastView.displayingDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissToastView:toastView];
        });
    }
}

- (void)dismissCurrentToastView // Public
{
    [self dismissToastView:_currentToastView];
}

- (void)dismissToastView:(DPToastView*)toastView // Public
{
    if ([toastView isKindOfClass:[DPToastView class]] == NO) {
        return;
    }
    if ([_currentToastView isEqual:toastView] == NO) {
        return;
    }
    
    void (^comp)(BOOL) = ^(BOOL finished){
        [toastView removeFromSuperview];
        _currentToastView = nil;
        _showingToastView = NO;
        [self showHeadToastViewIfExist];
    };

#warning 実装する
    {
        comp(YES);
    }
}

#pragma mark - getter

- (NSArray*)queueingToastViews
{
    return _queueingToastViews.copy;
}

@end
