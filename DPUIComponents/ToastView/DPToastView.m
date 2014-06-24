#import "DPToastView.h"
#import "DPToastViewManager.h"


@interface DPToastView ()

@end


@implementation DPToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayingDuration = 2.0;
    }
    return self;
}

#pragma mark - Show Hide

- (void)show
{
    [[DPToastViewManager sharedManager] enqueueToastView:self];
}

- (void)dismiss
{
    [[DPToastViewManager sharedManager] dismissToastView:self];
}

@end
