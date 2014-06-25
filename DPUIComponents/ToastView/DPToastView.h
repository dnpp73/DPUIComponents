#import <UIKit/UIKit.h>


extern NSString* const DPToastViewWillShowNotification;
extern NSString* const DPToastViewDidShowNotification;
extern NSString* const DPToastViewWillDismissNotification;
extern NSString* const DPToastViewDidDismissNotification;


@interface DPToastView : UIView

- (void)show;
- (void)dismiss;

@property (nonatomic) NSTimeInterval displayingDuration;

@property (nonatomic, readonly, getter=isShowAnimating)    BOOL showAnimating;
@property (nonatomic, readonly, getter=isDismissAnimating) BOOL dismissAnimating;
@property (nonatomic, readonly, getter=isShowing)          BOOL showing;

@end
