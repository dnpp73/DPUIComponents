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
    
    if (_currentToastView) {
        return;
    }
    
    DPToastView* toastView = _queueingToastViews[0];
    [toastView show];
}

#pragma mark - getter

- (NSArray*)queueingToastViews
{
    return _queueingToastViews.copy;
}

#pragma mark -

- (void)setCurrentToastView:(DPToastView*)toastView
{
    _currentToastView = toastView;
}

@end
