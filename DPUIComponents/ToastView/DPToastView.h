#import <UIKit/UIKit.h>


@interface DPToastView : UIView

- (void)showAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@property (nonatomic) NSTimeInterval displayingDuration;

@end
