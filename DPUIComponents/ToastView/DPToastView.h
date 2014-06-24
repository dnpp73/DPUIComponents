#import <UIKit/UIKit.h>


@interface DPToastView : UIView

- (void)show;
- (void)dismiss;

@property (nonatomic) NSTimeInterval displayingDuration;

@end
