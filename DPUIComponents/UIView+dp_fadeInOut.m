#import "UIView+dp_fadeInOut.h"


@implementation UIView (dp_fadeInOut)

- (void)dp_fadeInWithDuration:(NSTimeInterval)duration
{
    [self dp_fadeInWithDuration:duration compretion:nil];
}

- (void)dp_fadeInWithDuration:(NSTimeInterval)duration compretion:(void (^)(BOOL))completion
{
    UIView* targetView = self;
    BOOL    animated   = (duration > 0);
    
    void (^pre)(void) = ^{
        if (targetView.hidden == YES) {
            targetView.alpha = 0.0;
            targetView.hidden = NO;
        }
    };
    void (^anim)(void) = ^{
        targetView.alpha = 1.0;
    };
    void (^comp)(BOOL) = ^(BOOL finished){
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        pre();
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:anim
                         completion:comp];
    } else {
        pre();
        anim();
        comp(YES);
    }
}

- (void)dp_fadeOutWithDuration:(NSTimeInterval)duration
{
    [self dp_fadeOutWithDuration:duration hiddenAfterFadeOut:YES compretion:nil];
}

- (void)dp_fadeOutWithDuration:(NSTimeInterval)duration hiddenAfterFadeOut:(BOOL)hiddenAfterFadeOut compretion:(void (^)(BOOL))completion
{
    UIView* targetView = self;
    BOOL    animated   = (duration > 0);
    
    void (^pre)(void) = ^{
    };
    void (^anim)(void) = ^{
        targetView.alpha = 0.0;
    };
    void (^comp)(BOOL) = ^(BOOL finished){
        if (finished && hiddenAfterFadeOut) {
            targetView.hidden = YES;
        }
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        pre();
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:anim
                         completion:comp];
    } else {
        pre();
        anim();
        comp(YES);
    }
}

@end
