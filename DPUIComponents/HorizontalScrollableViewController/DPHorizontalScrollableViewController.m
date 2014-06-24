#import "DPHorizontalScrollableViewController.h"


@interface DPHorizontalScrollableViewController () <UIScrollViewDelegate>
{
    NSMutableArray* _rowViewControllers;
    
    __weak UIViewController* _currentViewController;
    __weak UIViewController* _beforeCurrentViewController;
    
    NSArray* _beforeVisibleViewControllers;
    
    __weak UIScrollView* _horizontalScrollView;
    __weak UIView*       _rowContainerView;
    __weak UIView*       _overlayContainerView;
}
@end


@implementation DPHorizontalScrollableViewController

#pragma mark - Initializer

- (instancetype)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _rowViewControllers = [NSMutableArray array];
        _overlayViewBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<DPHorizontalScrollableViewControllerDelegate>)delegate rowViewControllers:(NSArray*)rowViewControllers
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.rowViewControllers = rowViewControllers;
    }
    return self;
}

#pragma mark -

- (NSArray*)visibleViewControllers
{
    NSMutableArray* visibleViewControllers = [NSMutableArray array];
    
    for (UIViewController* rowViewController in _rowViewControllers) {
        CGRect rect = [self.view convertRect:rowViewController.view.bounds fromView:rowViewController.view];
        if (CGRectIntersectsRect(self.view.bounds, rect)) {
            [visibleViewControllers addObject:rowViewController];
        }
    }
    
    return visibleViewControllers.copy;
}

- (void)setCurrentViewController:(UIViewController*)currentViewController // private
{
    if (_currentViewController != currentViewController) {
        _beforeCurrentViewController = _currentViewController;
        _currentViewController = currentViewController;
        [self fireCurrentViewControllerDidChangeDelegationIfChanged];
        [self fireVisibleViewControllersDidChangeDelegationIfChanged];
    }
}

- (UIViewController*)currentViewController
{
    return _currentViewController;
}

- (NSArray*)rowViewControllers
{
    return _rowViewControllers.copy;
}

- (void)setRowViewControllers:(NSArray*)rowVewControllers
{
    if ([rowVewControllers isEqualToArray:_rowViewControllers] == NO) {
        for (UIViewController* viewController in _rowViewControllers.reverseObjectEnumerator) {
            [self removeRowViewController:viewController relayout:NO];
        }
        for (UIViewController* viewController in rowVewControllers) {
            [self addRowViewController:viewController relayout:NO];
        }
        if (self.isViewLoaded) {
            [self relayoutRowViewControllersAnimated:NO];
        }
    }
}

- (void)addRowViewController:(UIViewController*)viewController
{
    [self addRowViewController:viewController relayout:YES];
}

- (void)addRowViewController:(UIViewController*)viewController relayout:(BOOL)relayout
{
    if ([_rowViewControllers containsObject:viewController] == NO) {
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
        [self addChildViewController:viewController];
        [_rowViewControllers addObject:viewController];
        
        if (_rowViewControllers.count == 1) {
            [self setCurrentViewController:viewController];
        }
        
        if (relayout) {
            [self relayoutRowViewControllersAnimated:NO];
        }
    }
}

- (void)removeRowViewController:(UIViewController*)viewController
{
    [self removeRowViewController:viewController relayout:YES];
}

- (void)removeRowViewController:(UIViewController*)viewController relayout:(BOOL)relayout
{
    if ([self.visibleViewControllers containsObject:viewController]) {
        [NSException raise:@"Invalid View Controller" format:@"can not remove visible view controller"];
        return;
    }
    if ([_rowViewControllers containsObject:viewController] == NO) {
        [NSException raise:@"Invalid View Controller" format:@"can not remove that does not exist in row view controllers"];
        return;
    }

    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [_rowViewControllers removeObject:viewController];
    
    if (relayout) {
        [self relayoutRowViewControllersAnimated:NO];
    }
}

#pragma mark -

- (void)relayoutRowViewControllersAnimated:(BOOL)animated
{
    void (^pre)(void) = ^{
        ;
    };
    void (^anim)(void) = ^{
        CGSize size = self.view.bounds.size;
        
        _horizontalScrollView.contentSize = CGSizeMake(size.width*_rowViewControllers.count, 0);
        _rowContainerView.frame     = CGRectMake(0, 0, size.width*_rowViewControllers.count, size.height);
        _overlayContainerView.frame = CGRectMake(0, 0, size.width*_rowViewControllers.count, size.height);
        
        for (UIViewController* viewController in _rowViewControllers) {
            NSInteger index = [_rowViewControllers indexOfObject:viewController];
            viewController.view.frame = CGRectMake(size.width*index, 0, size.width, size.height);
            
            if (viewController.view.superview != _rowContainerView ||
                [_rowContainerView.subviews indexOfObject:viewController.view] != index) {
                [_rowContainerView insertSubview:viewController.view atIndex:index];
            }
        }
        
        while (_overlayContainerView.subviews.count != _rowViewControllers.count) {
            if (_overlayContainerView.subviews.count < _rowViewControllers.count) {
                UIView* overlayView = [[UIView alloc] initWithFrame:CGRectZero];
                overlayView.userInteractionEnabled = NO;
                overlayView.backgroundColor = _overlayViewBackgroundColor;
                [_overlayContainerView addSubview:overlayView];
            }
            else if (_overlayContainerView.subviews.count > _rowViewControllers.count) {
                [_overlayContainerView.subviews.lastObject removeFromSuperview];
            }
        }
        for (UIView* overlayView in _overlayContainerView.subviews) {
            NSInteger index = [_overlayContainerView.subviews indexOfObject:overlayView];
            overlayView.frame = CGRectMake(size.width*index, 0, size.width, size.height);
        }
        
        if (_currentViewController != nil && [_rowViewControllers containsObject:_currentViewController]) {
            NSInteger index = [_rowViewControllers indexOfObject:_currentViewController];
            CGPoint contentOffset = CGPointMake(size.width*index, 0);
            [_horizontalScrollView setContentOffset:contentOffset];
            
            UIView* overlayView = _overlayContainerView.subviews[index];
            overlayView.alpha = 0.0;
        }
    };
    void (^comp)(BOOL) = ^(BOOL finished){
        ;
    };
    
    pre();
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:anim completion:comp];
    } else {
        anim();
        comp(YES);
    }
}

#pragma mark -

- (void)focusToViewController:(UIViewController*)viewController animated:(BOOL)animated force:(BOOL)force
{
    if ([_rowViewControllers containsObject:viewController] == NO) {
        [NSException raise:@"Invalid View Controller" format:@"can not remove that does not exist in row view controllers"];
        return;
    }
    
    if (_currentViewController == viewController) {
        return;
    }
    
    void (^pre)(void) = ^{
        ;
    };
    void (^anim)(void) = ^{
        NSInteger index = [_rowViewControllers indexOfObject:viewController];
        CGFloat  contentOffsetX = _horizontalScrollView.bounds.size.width * index;
        
        [_horizontalScrollView setContentOffset:CGPointMake(contentOffsetX, 0)];
    };
    void (^comp)(BOOL) = ^(BOOL finished){
        [self setCurrentViewController:viewController];
    };
    
    pre();
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:anim completion:comp];
    } else {
        anim();
        comp(YES);
    }
}

#pragma mark -

- (void)setOverlayViewBackgroundColor:(UIColor*)overlayViewBackgroundColor
{
    if ([_overlayViewBackgroundColor isEqual:overlayViewBackgroundColor] == NO) {
        _overlayViewBackgroundColor = overlayViewBackgroundColor;
        
        for (UIView* overlayView in _overlayContainerView.subviews) {
            overlayView.backgroundColor = overlayViewBackgroundColor;
        }
    }
}

#pragma mark -

- (BOOL)isScrollViewScrollEnabled
{
    return _horizontalScrollView.isScrollEnabled;
}

- (void)setScrollViewScrollEnabled:(BOOL)scrollViewScrollEnabled
{
    _horizontalScrollView.scrollEnabled = scrollViewScrollEnabled;
}

- (BOOL)isScrollViewTracking
{
    return _horizontalScrollView.isTracking;
}

- (BOOL)isScrollViewDragging
{
    return _horizontalScrollView.isDragging;
}

- (CGFloat)normalizedContentOffsetX
{
    return _horizontalScrollView.contentOffset.x / _horizontalScrollView.bounds.size.width;
}

#pragma mark -

- (void)fireCurrentViewControllerDidChangeDelegationIfChanged
{
    if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewController:didChangeCurrentViewController:)]) {
        if (_beforeCurrentViewController != _currentViewController) {
            [self.delegate horizontalScrollableViewController:self didChangeCurrentViewController:_beforeCurrentViewController];
        }
    }
}

- (void)fireVisibleViewControllersDidChangeDelegationIfChanged
{
    if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewController:didChangeVisibleViewControllers:)]) {
        if ([_beforeVisibleViewControllers isEqualToArray:self.visibleViewControllers] == NO) {
            [self.delegate horizontalScrollableViewController:self didChangeVisibleViewControllers:_beforeVisibleViewControllers];
        }
    }
    _beforeVisibleViewControllers = self.visibleViewControllers;
}

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor clearColor];
    
    UIScrollView* horizontalScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    horizontalScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    horizontalScrollView.backgroundColor = [UIColor clearColor];
    horizontalScrollView.showsHorizontalScrollIndicator = NO;
    horizontalScrollView.showsVerticalScrollIndicator = NO;
    horizontalScrollView.bounces = YES;
    horizontalScrollView.alwaysBounceHorizontal = NO;
    horizontalScrollView.alwaysBounceVertical = NO;
    horizontalScrollView.delaysContentTouches = YES;
    horizontalScrollView.pagingEnabled = YES;
    horizontalScrollView.delegate = self;
    [self.view addSubview:horizontalScrollView];
    _horizontalScrollView = horizontalScrollView;
    
    UIView* rowContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    rowContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    rowContainerView.backgroundColor = [UIColor clearColor];
    [_horizontalScrollView addSubview:rowContainerView];
    _rowContainerView = rowContainerView;
    
    UIView* overlayContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    overlayContainerView.backgroundColor = [UIColor clearColor];
    overlayContainerView.userInteractionEnabled = NO;
    [_horizontalScrollView addSubview:overlayContainerView];
    _overlayContainerView = overlayContainerView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self relayoutRowViewControllersAnimated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    if (scrollView == _horizontalScrollView) {
        if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewControllerWillBeginDragging:)]) {
            [self.delegate horizontalScrollableViewControllerWillBeginDragging:self];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (scrollView == _horizontalScrollView) {
        
        for (UIView* overlayView in _overlayContainerView.subviews) {
            NSInteger index = [_overlayContainerView.subviews indexOfObject:overlayView];
            CGFloat alpha = self.normalizedContentOffsetX - index;
            if (alpha < -1.0) {
                alpha = 0.0;
            } else if (-1.0 <= alpha && alpha < 0.0) {
                alpha = -alpha;
            } else if ( 0.0 <= alpha && alpha < 1.0) {
                ; // nop
            } else {
                alpha = 0.0;
            }
            overlayView.alpha = alpha;
        }
        
        if (scrollView.isTracking) { // setContentOffset するときは責任を持って fire すること、という方針にした
            [self fireVisibleViewControllersDidChangeDelegationIfChanged];
        }
        if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewControllerDidScroll:)]) {
            [self.delegate horizontalScrollableViewControllerDidScroll:self];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset
{
    if (scrollView == _horizontalScrollView) {
        ;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _horizontalScrollView) {
        
        if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewControllerDidEndDragging:willDecelerate:)]) {
            [self.delegate horizontalScrollableViewControllerDidEndDragging:self willDecelerate:decelerate];
        }
        
        if (decelerate == NO) {
            NSInteger index = MAX(0, lround(self.normalizedContentOffsetX));
            if (index < _rowViewControllers.count) {
                [self setCurrentViewController:_rowViewControllers[index]];
            }
        }
        
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView
{
    if (scrollView == _horizontalScrollView) {
        ;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    if (scrollView == _horizontalScrollView) {
        NSInteger index = MAX(0, lround(self.normalizedContentOffsetX));
        if (index < _rowViewControllers.count) {
            [self setCurrentViewController:_rowViewControllers[index]];
        }
        
        if ([self.delegate respondsToSelector:@selector(horizontalScrollableViewControllerDidEndDecelerating:)]) {
            [self.delegate horizontalScrollableViewControllerDidEndDecelerating:self];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
    if (scrollView == _horizontalScrollView) {
        ;
    }
}

@end
