#import <UIKit/UIKit.h>


@interface UIView (dp_recursiveUtils)

- (BOOL)dp_recursiveTrackingCheck;
- (void)dp_recursiveCancelTrackingControls;
- (void)dp_recursiveCancelTrackingControlsWithIgnoreControl:(UIControl*)control;
- (void)dp_recursiveSetHighlighted:(BOOL)highlighted;
- (void)dp_recursiveSetSelected:(BOOL)selected;

- (void)dp_recursiveDeselectSelectedTableCellWithAnimated:(BOOL)animated;

- (UIResponder*)dp_firstResponderView;

@end
