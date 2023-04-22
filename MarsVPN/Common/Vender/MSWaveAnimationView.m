//
//  MSWaveAnimationView.m
//  MSUnified
//
//  Created by max on 15/11/16.
//  Copyright © 2015年 max. All rights reserved.
//

#import "MSWaveAnimationView.h"
@interface MSWaveAnimationView ()<CAAnimationDelegate>
@property(nonatomic, strong)NSMutableArray *waveLayers;
@end
@implementation MSWaveAnimationView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.circleColor = [UIColor redColor];
        self.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.waveLayers = [NSMutableArray array];
        self.duration = 2;
    }
    return self;
}

- (void)startWaveWithBeginRadius:(CGFloat)radius duration:(CGFloat)duration{
    [self stopWave];
    
    self.beginRadius = radius;
    self.duration = duration;
    self.waveLayers = [NSMutableArray array];
    [self moreWave];
}


- (CAAnimationGroup *)waveAnimation{
    CGFloat scale = CGRectGetWidth(self.frame) / (self.beginRadius * 2);
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(scale);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0.5);
    opacityAnimation.toValue = @(0.0);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation, opacityAnimation];
    group.duration = self.duration;
    group.removedOnCompletion = NO;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    group.delegate = self;
    
    return group;
}

- (void)waveLayerInit:(CAShapeLayer *)layer{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, self.beginRadius, self.beginRadius, self.beginRadius, 0, M_PI * 2, YES);
    CGPathCloseSubpath(path);
    
    layer.frame = CGRectMake((CGRectGetWidth(self.frame) - self.beginRadius * 2) / 2,
                             (CGRectGetHeight(self.frame) - self.beginRadius * 2) / 2,
                             self.beginRadius * 2,
                             self.beginRadius * 2);
    layer.strokeColor = self.circleColor.CGColor;
    layer.fillColor = self.fillColor.CGColor;
    layer.path = path;
    CGPathRelease(path);
}

- (void)moreWave{
    CAShapeLayer *waveLayer = [CAShapeLayer layer];
    [self waveLayerInit:waveLayer];
    [waveLayer addAnimation:[self waveAnimation] forKey:@"wave"];
    [self.waveLayers addObject:waveLayer];
    [self.layer addSublayer:waveLayer];
}

- (void)stopWave{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moreWave) object:nil];
}

- (void)animationDidStart:(CAAnimation *)anim{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moreWave) object:nil];
    [self performSelector:@selector(moreWave) withObject:nil afterDelay:self.duration * 0.5];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSArray *layers = [NSArray arrayWithArray:self.waveLayers];
    [layers enumerateObjectsUsingBlock:^(CAShapeLayer *layer, NSUInteger idx, BOOL *stop) {
        if([layer animationForKey:@"wave"] == anim){
            [layer removeFromSuperlayer];
            [self.waveLayers removeObject:layer];
        }
    }];
}
@end
