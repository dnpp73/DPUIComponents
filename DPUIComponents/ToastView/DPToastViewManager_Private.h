#import "DPToastViewManager.h"


@interface DPToastViewManager (dp_private)

- (void)setCurrentToastView:(DPToastView*)toastView;
- (void)showHeadToastViewIfExist;

@end