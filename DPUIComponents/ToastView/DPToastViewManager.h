#import <Foundation/Foundation.h>


@class DPToastView;


@interface DPToastViewManager : NSObject

+ (instancetype)sharedManager;

- (void)enqueueToastView:(DPToastView*)toastView;
- (void)dismissCurrentToastView;
- (void)dismissToastView:(DPToastView*)toastView;
@property (nonatomic, readonly, getter=isShowingToastView) BOOL showingToastView;
@property (nonatomic, weak, readonly) DPToastView* currentToastView;
@property (nonatomic, copy, readonly) NSArray*     queueingToastViews;

@end
