//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "NSWindow+Shake.h"
#import <Quartz/Quartz.h>

static int kShakeCount = 3;
static double kShakeDuration = 0.4f;
static double kShakeVigour = 0.05f;

@implementation NSWindow (Shake)

- (void)shake
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, NSMinX(self.frame), NSMinY(self.frame));
    
    int index;
    
    for (index = 0; index < kShakeCount; ++index) {
        CGPathAddLineToPoint(path, NULL, NSMinX(self.frame) - self.frame.size.width * kShakeVigour, NSMinY(self.frame));
        CGPathAddLineToPoint(path, NULL, NSMinX(self.frame) + self.frame.size.width * kShakeVigour, NSMinY(self.frame));
    }
    
    CGPathCloseSubpath(path);
    shakeAnimation.path = path;
    shakeAnimation.duration = kShakeDuration;
    
    CGPathRelease(path);
    
    [self setAnimations:@{@"frameOrigin": shakeAnimation}];
    [self.animator setFrameOrigin:self.frame.origin];
}

@end
