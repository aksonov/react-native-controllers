//
//  UINavigationBar+PassTouches.m
//  ReactNativeControllers
//
//  Created by Pavlo Aksonov on 18/08/16.
//  Copyright © 2016 artal. All rights reserved.
//

#import "UINavigationBar+PassTouches.h"

@implementation UINavigationBar(PassTouches)

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        BOOL pointInside = [view pointInside:[self convertPoint:point toView:view] withEvent:event];
        if (([view respondsToSelector:@selector(navigationItem)] || (!view.hidden && view.alpha > 0 && view.userInteractionEnabled)) && pointInside)
            return YES;
    }
    return NO;
}
@end
