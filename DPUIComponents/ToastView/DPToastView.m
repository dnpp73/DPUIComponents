#import "DPToastView.h"
#import "DPToastView_Private.h"
#import "DPToastViewManager.h"
#import "DPToastViewManager_Private.h"


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

#pragma mark - 

- (BOOL)isShowing
{
    return [[[DPToastViewManager sharedManager] currentToastView] isEqual:self];
}

- (void)setShowAnimating:(BOOL)showAnimating
{
    _showAnimating = showAnimating;
}

- (void)setDismissAnimating:(BOOL)dismissAnimating
{
    _dismissAnimating = dismissAnimating;
}

@end
