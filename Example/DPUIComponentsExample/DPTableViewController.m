#import "DPTableViewController.h"
#import "DPToastView.h"


@interface DPTableViewController ()

@end


@implementation DPTableViewController

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == self.tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        CGRect frame = CGRectMake(
                                  arc4random_uniform(80)+0,
                                  arc4random_uniform(80)+0,
                                  arc4random_uniform(200)+100,
                                  arc4random_uniform(80)+50
                                  );
        DPToastView* toastView = [[DPToastView alloc] initWithFrame:frame];
        {
            toastView.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(10)/10.0)
                                                        green:(arc4random_uniform(10)/10.0)
                                                         blue:(arc4random_uniform(10)/10.0)
                                                        alpha:(arc4random_uniform(5)/10.0+0.5)];
        }
        [toastView show];
    }
}

@end
