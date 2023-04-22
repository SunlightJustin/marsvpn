//
//  MSWaveAnimationView.h
//  MSUnified
//
//  Created by max on 15/11/16.
//  Copyright © 2015年 max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSWaveAnimationView : UIView
@property(nonatomic, strong)UIColor *circleColor;
@property(nonatomic, strong)UIColor *fillColor;
@property(nonatomic, assign)CGFloat beginRadius;
@property(nonatomic, assign)CGFloat duration;

- (void)startWaveWithBeginRadius:(CGFloat)radius duration:(CGFloat)duration;

- (void)moreWave;

- (void)stopWave;
@end
