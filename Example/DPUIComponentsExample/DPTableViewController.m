#import "DPTableViewController.h"
#import "DPToastView.h"


@interface DPTableViewController ()

@end


@implementation DPTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DPToastView* toastView = [[DPToastView alloc] initWithFrame:CGRectMake(arc4random_uniform(20)+40, arc4random_uniform(40)+20, arc4random_uniform(100)+200, arc4random_uniform(50)+30)];
    toastView.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(10)/10.0) green:(arc4random_uniform(10)/10.0) blue:(arc4random_uniform(10)/10.0) alpha:0.4];
    [toastView show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
