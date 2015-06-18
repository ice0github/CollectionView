//
//  CCell.m
//  
//
//  Created by crazypoo on 15/6/18.
//
//

#import "CCell.h"
#define SIZE 100

@implementation CCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        }
    return self;
}

-(void)layoutSubviews
{
#warning 形状
    [super layoutSubviews];
    CGFloat longSide = SIZE * 0.5 * cosf(M_PI * 30 / 180);
    CGFloat shortSide = SIZE * 0.5 * sin(M_PI * 30 / 180);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, longSide)];
    [path addLineToPoint:CGPointMake(shortSide, 0)];
    [path addLineToPoint:CGPointMake(shortSide + SIZE * 0.5, 0)];
    [path addLineToPoint:CGPointMake(SIZE, longSide)];
    [path addLineToPoint:CGPointMake(shortSide + SIZE * 0.5, longSide * 2)];
    [path addLineToPoint:CGPointMake(shortSide, longSide * 2)];
    [path closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [path CGPath];
    self.layer.mask = maskLayer;
    
    self.backgroundColor = [UIColor orangeColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = self.contentView.frame;
}


@end
