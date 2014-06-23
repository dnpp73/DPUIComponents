#import <UIKit/UIKit.h>


@interface DPMarqueeLabel : UIView

@property (nonatomic)                                      BOOL marqueeEnabled;
@property (nonatomic, readonly, getter=isMarqueeAnimating) BOOL marqueeAnimating;

- (void)startMarquee;
- (void)startMarqueeAfterDelay:(NSTimeInterval)afterDelay;
- (void)stopMarquee;
- (void)stopMarqueeAfterDelay:(NSTimeInterval)afterDelay;

- (void)resetMarqueePositionAnimated:(BOOL)animated;

@property (nonatomic) NSTextAlignment textAlignment; // 独自に使ってる。デフォルトは Left。 Left と Center と Right しかサポートしてないから注意。

// UIScrollView attributes bridge
@property (nonatomic, readonly, getter=isTracking) BOOL tracking;
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;

// UILabel attributes bridge
@property (nonatomic, copy) NSString* text;
@property (nonatomic)       UIColor*  textColor;
@property (nonatomic)       UIFont*   font;
@property (nonatomic)       UIColor*  shadowColor;
@property (nonatomic)       CGSize    shadowOffset;

@end
