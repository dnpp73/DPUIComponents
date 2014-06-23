#import <Foundation/Foundation.h>


@class DPToastView;


@interface DPToastViewManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly, getter=isShowingToastView) BOOL showingToastView;
- (void)addToastView:(DPToastView*)toastView;
@property (nonatomic, weak, readonly) DPToastView* showingToastView;
@property (nonatomic, copy, readonly) NSArray*     queueingToastViews;

@end
