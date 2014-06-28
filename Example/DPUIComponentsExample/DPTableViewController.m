#import "DPTableViewController.h"
#import "DPToastView.h"


@interface DPTableViewController () <DPToastViewDelegate>

@end


@implementation DPTableViewController

#pragma mark -

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == self.tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        DPToastView* toastView = [[DPToastView alloc] initWithFrame:[self rectForToastView]];
        toastView.delegate = self;
        {
            toastView.backgroundView.backgroundColor = [self randomColorForToastViewBackground];
        }
        [toastView showInView:(arc4random_uniform(2) ? [self targetView] : [self targetView])];
    }
}

- (UIView*)targetView
{
//    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    return self.navigationController.view;
}

- (CGRect)rectForToastView
{
    CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
    CGRect rect = CGRectMake(0, navigationBarSize.height, navigationBarSize.width, 50);
    rect = [self.navigationController.navigationBar convertRect:rect toView:[self targetView]];
    return rect;
}

- (UIColor*)randomColorForToastViewBackground
{
    return [UIColor colorWithRed:(arc4random_uniform(100)/100.0)
                           green:(arc4random_uniform(100)/100.0)
                            blue:(arc4random_uniform(100)/100.0)
                           alpha:(arc4random_uniform(5)/10.0+0.5)];
}

#pragma mark -

- (IBAction)unwindToTableViewControllerFromModalViewController:(UIStoryboardSegue*)segue
{
    [segue.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DPToastViewDelegate

- (void)toastViewDidTapped:(DPToastView*)toastView
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), toastView);
}

@end
