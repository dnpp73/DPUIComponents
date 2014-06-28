#import <UIKit/UIKit.h>


extern NSString* const DPToastViewWillShowNotification;
extern NSString* const DPToastViewDidShowNotification;
extern NSString* const DPToastViewWillDismissNotification;
extern NSString* const DPToastViewDidDismissNotification;


@class    DPToastViewAnimator;
@protocol DPToastViewDelegate;


@interface DPToastView : UIView

@property (nonatomic, readonly) DPToastViewAnimator* animator;
- (void)showInView:(UIView*)targetView;
@property (nonatomic, weak) UIView* targetView;
- (void)dismiss;

@property (nonatomic, weak) id<DPToastViewDelegate> delegate;

@property (nonatomic) NSTimeInterval displayingDuration;
@property (nonatomic, weak, readonly) UIView* containerView;
@property (nonatomic, weak, readonly) UIView* contentsView;
@property (nonatomic, weak, readonly) UIView* backgroundView;

@property (nonatomic, readonly, getter=isShowAnimating)    BOOL showAnimating;
@property (nonatomic, readonly, getter=isDismissAnimating) BOOL dismissAnimating;
@property (nonatomic, readonly, getter=isShowing)          BOOL showing;

@property (nonatomic, readonly, getter=isTracking)         BOOL tracking;
@property (nonatomic, readonly, getter=isDragging)         BOOL dragging;

@end


@protocol DPToastViewDelegate <NSObject>
@optional
- (void)toastViewDidTapped:(DPToastView*)toastView;
@end