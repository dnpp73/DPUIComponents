#import <UIKit/UIKit.h>


@interface UIView (dp_fadeInOut)

- (void)dp_fadeInWithDuration:(NSTimeInterval)duration;
- (void)dp_fadeInWithDuration:(NSTimeInterval)duration compretion:(void (^)(BOOL))completion;
- (void)dp_fadeOutWithDuration:(NSTimeInterval)duration;
- (void)dp_fadeOutWithDuration:(NSTimeInterval)duration hiddenAfterFadeOut:(BOOL)hiddenAfterFadeOut compretion:(void (^)(BOOL))completion;

@end
