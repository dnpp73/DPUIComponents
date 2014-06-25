#import <Foundation/Foundation.h>


@class DPToastView;


@interface DPToastViewAnimator : NSObject

@property (nonatomic, weak, readonly) DPToastView* toastView;
- (instancetype)initWithToastView:(DPToastView*)toastView;

@property (nonatomic) NSTimeInterval showAnimationDuration;
@property (nonatomic) NSTimeInterval dismissAnimationDuration;

- (void)showAnimationWithCallback:(void (^)(BOOL finished))callback;
- (void)dismissAnimationWithCallback:(void (^)(BOOL finished))callback;

@end
