#import "DPTableViewController.h"
#import "DPToastView.h"


@interface DPTableViewController ()

@end


@implementation DPTableViewController

#pragma mark -

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotificationObserver];
}

#pragma mark -

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == self.tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        DPToastView* toastView = [[DPToastView alloc] initWithFrame:[self rectForToastView] targetView:[self targetView]];
        {
            toastView.backgroundView.backgroundColor = [self randomColorForToastViewBackground];
        }
        [toastView show];
    }
}

- (UIView*)targetView
{
    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
}

- (CGRect)rectForToastView
{
    CGRect rect = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 70);
    rect = [self.navigationController.navigationBar convertRect:rect toView:[self targetView]];
    return rect;
}

- (CGRect)randomRectForToastView
{
    return CGRectMake(
                      arc4random_uniform(80)+0,
                      arc4random_uniform(80)+0,
                      arc4random_uniform(200)+100,
                      arc4random_uniform(80)+50
                      );
}

- (UIColor*)randomColorForToastViewBackground
{
    return [UIColor colorWithRed:(arc4random_uniform(10)/10.0)
                           green:(arc4random_uniform(10)/10.0)
                            blue:(arc4random_uniform(10)/10.0)
                           alpha:(arc4random_uniform(5)/10.0+0.5)];
}

#pragma mark - Notification

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchToastViewWillShowNotification:)    name:DPToastViewWillShowNotification    object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchToastViewDidShowNotification:)     name:DPToastViewDidShowNotification     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchToastViewWillDismissNotification:) name:DPToastViewWillDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchToastViewDidDismissNotification:)  name:DPToastViewDidDismissNotification  object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DPToastViewWillShowNotification    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DPToastViewDidShowNotification     object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DPToastViewWillDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DPToastViewDidDismissNotification  object:nil];
}

- (void)catchToastViewWillShowNotification:(NSNotification*)notification
{
    DPToastView* toastView = notification.object;
    toastView.frame = [self rectForToastView];
//    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)catchToastViewDidShowNotification:(NSNotification*)notification
{
//    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)catchToastViewWillDismissNotification:(NSNotification*)notification
{
//    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

- (void)catchToastViewDidDismissNotification:(NSNotification*)notification
{
//    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification.object);
}

@end
