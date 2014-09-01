#import "UIView+dp_recursiveUtils.h"


@implementation UIView (dp_recursiveUtils)

#pragma mark - あると便利かなと。

- (BOOL)dp_recursiveTrackingCheck
{
    return [self dp_recursiveTrackingCheckWithTargetView:self];
}

- (BOOL)dp_recursiveTrackingCheckWithTargetView:(UIView*)view
{
    if ([view isKindOfClass:[UIControl class]] && [(UIControl*)view isTracking]) {
        return YES;
    }
    
    if ([view isKindOfClass:[UIScrollView class]] && [(UIScrollView*)view isTracking]) {
        return YES;
    }
    
    for (UIView* subview in view.subviews) {
        if ([self dp_recursiveTrackingCheckWithTargetView:subview]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -

- (void)dp_recursiveCancelTrackingControls
{
    [self dp_recursiveCancelTrackingControlsWithIgnoreControl:nil];
}

- (void)dp_recursiveCancelTrackingControlsWithIgnoreControl:(UIControl*)control
{
    [self dp_recursiveCancelTrackingControlsWithTargetView:self ignoreControl:control];
}

- (void)dp_recursiveCancelTrackingControlsWithTargetView:(UIView*)targetView ignoreControl:(UIControl*)ignoreControl
{
    void (^safeCancelTrackingControl)(UIView*) = ^(UIView* view){
        if ([view isKindOfClass:[UIControl class]]) {
            UIControl* control = (UIControl*)view;
            if (control != ignoreControl) {
                [control cancelTrackingWithEvent:nil];
            }
        }
    };
    
    safeCancelTrackingControl(targetView);
    for (UIView* subview in targetView.subviews) {
        [self dp_recursiveCancelTrackingControlsWithTargetView:subview ignoreControl:ignoreControl];
    }
}

#pragma mark -

- (void)dp_recursiveSetHighlighted:(BOOL)highlighted
{
    if ([self isKindOfClass:[UIControl class]]) {
        UIControl* control = (UIControl*)self;
        control.highlighted = highlighted;
    }
    
    for (UIView* subview in self.subviews) {
        [subview dp_recursiveSetHighlighted:highlighted];
    }
}

- (void)dp_recursiveSetSelected:(BOOL)selected
{
    if ([self isKindOfClass:[UIControl class]]) {
        UIControl* control = (UIControl*)self;
        control.selected = selected;
    }
    
    for (UIView* subview in self.subviews) {
        [subview dp_recursiveSetSelected:selected];
    }
}

#pragma mark -

- (void)dp_recursiveDeselectSelectedTableCellWithAnimated:(BOOL)animated
{
    [self dp_recursiveDeselectSelectedTableCellWithAnimated:animated targetView:self];
}

- (void)dp_recursiveDeselectSelectedTableCellWithAnimated:(BOOL)animated targetView:(UIView*)targetView
{
    static void (^safeDeselectSelectedTableCell)(UIView*, BOOL) = ^(UIView* view, BOOL animated){
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView* tableView = (UITableView*)view;
            
            if (tableView.indexPathForSelectedRow != nil) {
                [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:animated];
            }
            
            for (UITableViewCell* cell in tableView.visibleCells) {
                if (cell.selected == NO) {
                    [cell setHighlighted:NO animated:animated];
                }
            }
            
        }
    };
    
    safeDeselectSelectedTableCell(targetView, animated);
    for (UIView* subview in targetView.subviews) {
        [self dp_recursiveDeselectSelectedTableCellWithAnimated:animated targetView:subview];
    }
}

@end
