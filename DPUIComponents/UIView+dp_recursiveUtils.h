#import <UIKit/UIKit.h>


@interface UIView (dp_recursiveUtils)

- (BOOL)dp_recursiveTrackingCheck;
- (void)dp_recursiveCancelTrackingControls;
- (void)dp_recursiveCancelTrackingControlsWithIgnoreControl:(UIControl*)control;
- (void)dp_recursiveDeselectSelectedTableCellWithAnimated:(BOOL)animated;

@end
