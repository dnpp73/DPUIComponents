#import "DPNavigationController.h"
#import "DPToastView.h"
#import "DPToastViewManager.h"


@interface DPNavigationController ()

@end


@implementation DPNavigationController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([DPToastViewManager sharedManager].currentToastView) {
        DPToastView* toastView = [DPToastViewManager sharedManager].currentToastView;
        CGSize navigationBarSize = self.navigationBar.frame.size;
        CGRect rect = CGRectMake(0, navigationBarSize.height, navigationBarSize.width, toastView.frame.size.height);
        rect = [self.navigationBar convertRect:rect toView:toastView.superview];
        toastView.frame = rect;
    }
}

@end
