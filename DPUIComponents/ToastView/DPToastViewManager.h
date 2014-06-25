#import <Foundation/Foundation.h>


@class DPToastView;


@interface DPToastViewManager : NSObject

+ (instancetype)sharedManager;

- (void)enqueueToastView:(DPToastView*)toastView;
- (void)dequeueToastView:(DPToastView*)toastView;
@property (nonatomic, weak, readonly) DPToastView* currentToastView;
@property (nonatomic, copy, readonly) NSArray*     queueingToastViews;

@end
