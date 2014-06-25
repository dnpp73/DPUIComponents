#import <UIKit/UIKit.h>


extern NSString* const DPToastViewWillShowNotification;
extern NSString* const DPToastViewDidShowNotification;
extern NSString* const DPToastViewWillDismissNotification;
extern NSString* const DPToastViewDidDismissNotification;


@class DPToastViewAnimator;


@interface DPToastView : UIView

- (instancetype)initWithFrame:(CGRect)frame targetView:(UIView*)targetView;

@property (nonatomic, weak) UIView* targetView;
@property (nonatomic, readonly) DPToastViewAnimator* animator;
- (void)show;
- (void)dismiss;

@property (nonatomic) NSTimeInterval displayingDuration;
@property (nonatomic, weak, readonly) UIView* containerView;
@property (nonatomic, weak, readonly) UIView* contentsView;
@property (nonatomic, weak, readonly) UIView* backgroundView;

@property (nonatomic, readonly, getter=isShowAnimating)    BOOL showAnimating;
@property (nonatomic, readonly, getter=isDismissAnimating) BOOL dismissAnimating;
@property (nonatomic, readonly, getter=isShowing)          BOOL showing;

@end
