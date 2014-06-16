#import "DPMarqueeLabel.h"

@interface DPMarqueeLabel () <UIScrollViewDelegate>
{
    BOOL _isMarqueeAnimating;
    
    UIScrollView* _marqueeScrollView;
    UILabel* _label;
}
@end

@implementation DPMarqueeLabel

#pragma mark - initializer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewState];
        [self initSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initViewState];
        [self initSubviews];
    }
    return self;
}

- (void)initViewState
{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.backgroundColor  = [UIColor clearColor];
    
    self.marqueeEnabled = YES;
    
    self.textAlignment = NSTextAlignmentLeft;
}

- (void)initSubviews
{
    // marqueeScrollView
    _marqueeScrollView = ^{
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        scrollView.backgroundColor  = [UIColor clearColor];
        
        scrollView.delegate = self;
        
        scrollView.multipleTouchEnabled = NO;
        
        scrollView.alwaysBounceHorizontal = NO;
        scrollView.alwaysBounceVertical   = NO;
        
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator   = NO;
        
        scrollView.scrollsToTop = NO;
        
        return scrollView;
    }();
    [self addSubview:_marqueeScrollView];
    
    // label
    _label = ^{
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
        label.backgroundColor  = [UIColor clearColor];
        
        label.userInteractionEnabled = NO;
        
        return label;
    }();
    [_marqueeScrollView addSubview:_label];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_marqueeScrollView.layer removeAllAnimations];
    
    [_marqueeScrollView setContentOffset:CGPointZero animated:NO];
    
    CGSize size = [self.text sizeWithFont:self.font forWidth:CGFLOAT_MAX lineBreakMode:_label.lineBreakMode];
    size.height = _marqueeScrollView.bounds.size.height;
    CGPoint origin = CGPointZero;
    if (size.width < _marqueeScrollView.bounds.size.width) {
        if (self.textAlignment == NSTextAlignmentCenter) {
            origin.x = (NSInteger)((_marqueeScrollView.bounds.size.width - size.width)/2.0);
        }
        else if (self.textAlignment == NSTextAlignmentRight) {
            origin.x = (NSInteger)(_marqueeScrollView.bounds.size.width - size.width);
        }
    }
    _label.frame = (CGRect){origin, size};
    _marqueeScrollView.contentSize = (CGSize){size.width, 1};
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)    name:UIApplicationDidBecomeActiveNotification    object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification    object:nil];
    }
}

#pragma mark - catch notification

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
    [self stopMarquee];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [self startMarquee];
}

#pragma mark - scroll view bridged attributes

- (BOOL)isTracking
{
    return _marqueeScrollView.tracking;
}

- (BOOL)isDragging
{
    return _marqueeScrollView.dragging;
}

#pragma mark - label bridged attributes

- (void)setText:(NSString*)text
{
    BOOL isEqualToString = [_label.text isEqualToString:text];
    
    if (isEqualToString == NO) {
        [self stopMarquee];
    }
    
    _label.text = text;
    
    if (isEqualToString == NO) {
        [self setNeedsLayout];
    }
    
    [self startMarquee];
}

- (NSString*)text
{
    return _label.text;
}

- (void)setTextColor:(UIColor*)textColor
{
    _label.textColor = textColor;
}

- (UIColor*)textColor
{
    return _label.textColor;
}

- (void)setFont:(UIFont*)font
{
    _label.font = font;
}

- (UIFont*)font
{
    return _label.font;
}

- (void)setShadowColor:(UIColor*)shadowColor
{
    _label.shadowColor = shadowColor;
}

- (UIColor*)shadowColor
{
    return _label.shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _label.shadowOffset = shadowOffset;
}

- (CGSize)shadowOffset
{
    return _label.shadowOffset;
}

#pragma mark - attributes

- (BOOL)isMarqueeAnimating
{
    return _isMarqueeAnimating;
}

- (void)setMarqueeEnabled:(BOOL)marqueeEnabled
{
    _marqueeEnabled = marqueeEnabled;
    
    if (marqueeEnabled) {
        [self startMarqueeAfterDelay:1];
    } else {
        [self stopMarquee];
    }
}

#pragma mark - public implementation

- (void)startMarquee
{
    // 前処理
    if ([[NSThread currentThread] isMainThread] == NO) {
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startMarquee) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopMarquee) object:nil];
    
    if (self.marqueeEnabled == NO) {
        return;
    }
    
    if (_marqueeScrollView.tracking) {
        [self startMarqueeAfterDelay:5];
        return;
    }
    
    // マーキーさせる
    [self marqueeToEndPositionOfTitle];
}

- (void)startMarqueeAfterDelay:(NSTimeInterval)afterDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startMarquee) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopMarquee) object:nil];
    if (afterDelay == 0) {
        [self startMarquee];
    } else {
        [self performSelector:@selector(startMarquee) withObject:nil afterDelay:afterDelay];
    }
}

- (void)stopMarquee
{
    if ([[NSThread currentThread] isMainThread] == NO) {
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startMarquee) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopMarquee) object:nil];
    
    // マーキーやめる
    CGPoint offset = _marqueeScrollView.contentOffset;
    [_marqueeScrollView.layer removeAllAnimations];
    _marqueeScrollView.contentOffset = offset;
}

- (void)stopMarqueeAfterDelay:(NSTimeInterval)afterDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startMarquee) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopMarquee) object:nil];
    if (afterDelay == 0) {
        [self stopMarquee];
    } else {
        [self performSelector:@selector(stopMarquee) withObject:nil afterDelay:afterDelay];
    }
}

- (void)resetMarqueePositionAnimated:(BOOL)animated
{
    [self stopMarquee];
    
    [_marqueeScrollView setContentOffset:CGPointZero animated:animated];
    
    CGSize size = [self.text sizeWithFont:self.font forWidth:CGFLOAT_MAX lineBreakMode:_label.lineBreakMode];
    size.height = _marqueeScrollView.bounds.size.height;
    CGPoint origin = CGPointZero;
    if (size.width < _marqueeScrollView.bounds.size.width) {
        if (self.textAlignment == NSTextAlignmentCenter) {
            origin.x = (NSInteger)((_marqueeScrollView.bounds.size.width - size.width)/2.0);
        }
        else if (self.textAlignment == NSTextAlignmentRight) {
            origin.x = (NSInteger)(_marqueeScrollView.bounds.size.width - size.width);
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            _label.frame = (CGRect){origin, size};
            _marqueeScrollView.contentSize = (CGSize){size.width, 1};
        } completion:nil];
    } else {
        _label.frame = (CGRect){origin, size};
        _marqueeScrollView.contentSize = (CGSize){size.width, 1};
    }
    
    [self startMarquee];
}

#pragma mark - marquee

- (void)marqueeToEndPositionOfTitle
{
    if (_marqueeScrollView.contentSize.width < _marqueeScrollView.frame.size.width) {
        return;
    }
    
    if (self.marqueeEnabled == NO) {
        return;
    }
    
    if (_isMarqueeAnimating) {
        return;
    }
    
    if (_marqueeScrollView.tracking) {
        // UIScrollViewDelegate の方で start がくるはず
        return;
    }
    
    CGPoint endPoint = CGPointZero;
    endPoint.x = _marqueeScrollView.contentSize.width - _marqueeScrollView.frame.size.width;
    NSTimeInterval duration = fabs(endPoint.x - _marqueeScrollView.contentOffset.x) * 0.05;
    _isMarqueeAnimating = YES;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_marqueeScrollView setContentOffset:endPoint animated:NO];
                     }
                     completion:^(BOOL finished){
                         _isMarqueeAnimating = NO;
                         
                         if (finished) {
                             double delayInSeconds = 5.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [self marqueeToHeadPositionOfTitle];
                             });
                         }
                         
                     }];
}

- (void)marqueeToHeadPositionOfTitle
{
    if (_marqueeScrollView.contentSize.width < _marqueeScrollView.frame.size.width) {
        return;
    }
    
    if (self.marqueeEnabled == NO) {
        return;
    }
    
    if (_isMarqueeAnimating) {
        return;
    }
    
    if (_marqueeScrollView.tracking) {
        // UIScrollViewDelegate の方で start がくるはず
        return;
    }
    
    CGPoint headPosition = CGPointZero;
    NSTimeInterval duration = fabs(headPosition.x - _marqueeScrollView.contentOffset.x) * 0.05;
    _isMarqueeAnimating = YES;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_marqueeScrollView setContentOffset:headPosition animated:NO];
                     }
                     completion:^(BOOL finished){
                         _isMarqueeAnimating = NO;
                         
                         if (finished) {
                             double delayInSeconds = 5.0;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 [self marqueeToEndPositionOfTitle];
                             });
                         }
                         
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (scrollView == _marqueeScrollView) {
        if (scrollView.tracking) {
            [self stopMarquee];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _marqueeScrollView) {
        [self startMarqueeAfterDelay:5];
    }
}

@end
