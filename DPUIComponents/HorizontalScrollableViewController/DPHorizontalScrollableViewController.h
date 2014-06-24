#import <UIKit/UIKit.h>


@class DPHorizontalScrollableViewController;


@protocol DPHorizontalScrollableViewControllerDelegate <NSObject>
@optional
- (void)horizontalScrollableViewControllerDidScroll:(DPHorizontalScrollableViewController*)horizontalScrollableViewController;
- (void)horizontalScrollableViewControllerWillBeginDragging:(DPHorizontalScrollableViewController*)horizontalScrollableViewController;
- (void)horizontalScrollableViewControllerDidEndDragging:(DPHorizontalScrollableViewController*)horizontalScrollableViewController willDecelerate:(BOOL)decelerate;
- (void)horizontalScrollableViewControllerDidEndDecelerating:(DPHorizontalScrollableViewController*)horizontalScrollableViewController;

- (void)horizontalScrollableViewController:(DPHorizontalScrollableViewController*)horizontalScrollableViewController didChangeCurrentViewController:(UIViewController*)beforeViewController;
- (void)horizontalScrollableViewController:(DPHorizontalScrollableViewController*)horizontalScrollableViewController didChangeVisibleViewControllers:(NSArray*)beforeVisibleViewControllers;
@end


@interface DPHorizontalScrollableViewController : UIViewController

@property (nonatomic, readonly) UIViewController* currentViewController;
@property (nonatomic, readonly) NSArray*          visibleViewControllers;

@property (nonatomic, copy) NSArray* rowViewControllers;
- (void)addRowViewController:(UIViewController*)viewController;
- (void)removeRowViewController:(UIViewController*)viewController;

- (void)focusToViewController:(UIViewController*)viewController animated:(BOOL)animated force:(BOOL)force;

@property (nonatomic, weak) id<DPHorizontalScrollableViewControllerDelegate> delegate;
- (instancetype)initWithDelegate:(id<DPHorizontalScrollableViewControllerDelegate>)delegate rowViewControllers:(NSArray*)rowViewControllers;

@property (nonatomic) UIColor* overlayViewBackgroundColor; // clearColor means disabled. default is [UIColor colorWithWhite:0.0 alpha:0.2]

// UIScrollView attributes bridge
@property (nonatomic, getter = isScrollViewScrollEnabled)      BOOL    scrollViewScrollEnabled;
@property (nonatomic, readonly, getter = isScrollViewTracking) BOOL    scrollViewTracking;
@property (nonatomic, readonly, getter = isScrollViewDragging) BOOL    scrollViewDragging;
@property (nonatomic, readonly)                                CGFloat normalizedContentOffsetX;

@end
