#import <UIKit/UIKit.h>


@interface DPToastView : UIView

- (void)show;
- (void)dismiss;

@property (nonatomic) NSTimeInterval displayingDuration;

@property (nonatomic, readonly, getter=isShowAnimating)    BOOL showAnimating;
@property (nonatomic, readonly, getter=isDismissAnimating) BOOL dismissAnimating;
@property (nonatomic, readonly, getter=isShowing)          BOOL showing;

@end
