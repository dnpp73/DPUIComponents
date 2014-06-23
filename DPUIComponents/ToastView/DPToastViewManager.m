#import "DPToastViewManager.h"
#import "DPToastView.h"


@interface DPToastViewManager ()
{
    NSMutableArray* _queueingToastViews;
    
    NSHashTable* _observers;
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
        _observers          = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark - 

- (void)addToastView:(DPToastView*)toastView
{
    if ([toastView isKindOfClass:[DPToastView class]] == NO) {
        return;
    }
    if ([_showingToastView isEqual:toastView]) {
        return;
    }
    if ([_queueingToastViews containsObject:toastView]) {
        return;
    }
    
    [_queueingToastViews addObject:toastView];
    if (_showingToastView == NO) {
#warning それっぽく実装する
    }
}

#pragma mark - getter

- (NSArray*)queueingToastViews
{
    return _queueingToastViews.copy;
}

@end
