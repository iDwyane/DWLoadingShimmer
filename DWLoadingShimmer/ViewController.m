//
//  ViewController.m
//  DWLoadingShimmer
//
//  Created by Dwyane Wade on 2018/11/23.
//  Copyright © 2018年 Dwyane_Coding. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startLoadingBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopLoadingBtn;
@property (nonatomic, strong) NSArray *noNeedMaskView;
@property (nonatomic, strong) UIView *viewCover;
@end

@implementation ViewController

- (UIView *)viewCover {
    if (!_viewCover) {
        _viewCover = [UIView new];
        _viewCover.backgroundColor = [UIColor whiteColor];
    }
    return _viewCover;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor redColor];
    bgView.frame = CGRectMake(100, self.view.frame.size.height-60, 300, 50);
    [self.view addSubview:bgView];
    
    //遍历 subviews
    [self traverseSubviews:self.view];
}

- (void)traverseSubviews:(UIView *)view {
    view.backgroundColor = [UIColor whiteColor];
    if (self.view.subviews.count > 0) {
        for (UIView *subview in view.subviews) {
            
            // 获取每个子控件的path，用于后面的加遮盖
            CGPoint offsetPoint = [subview convertRect:subview.bounds toView:view].origin; 
            [subview layoutIfNeeded];
            
            // 添加圆角
            UIBezierPath *defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:subview.frame.size.height/2.0/*subview.layer.cornerRadius*/];
            if ([subview isMemberOfClass:[UILabel class]] || [subview isMemberOfClass:[UITextView class]]) {
                defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:4];
            }
            UIBezierPath *relativePath = defaultCoverblePath;
            
            // 相对位置
            [relativePath applyTransform:CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y)];
            
            UIBezierPath *totalCoverablePath = [[UIBezierPath alloc] init];
            [totalCoverablePath appendPath:relativePath];
            
            // 挡住控件的遮罩
            self.viewCover.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            [view addSubview:self.viewCover];
            
            // superview添加mask(能显示的遮罩)
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = totalCoverablePath.CGPath;
            maskLayer.fillColor = [UIColor whiteColor].CGColor;//[UIColor colorWithRed:0.9333 green:0.9333 blue:0.9333 alpha:1].CGColor;//[UIColor redColor].CGColor;
            [self.viewCover.layer addSublayer:maskLayer];
            
            
            // gradientLayer CAGradientLayer是CALayer的一个子类,用来生成渐变色的Layer
            CAGradientLayer *colorLayer = [CAGradientLayer layer];
            colorLayer.frame = (CGRect)self.view.bounds;
            [self.viewCover.superview.layer addSublayer:colorLayer];

            colorLayer.startPoint = CGPointMake(-1.4, 0);
            colorLayer.endPoint = CGPointMake(1.4, 0);
            
            // 颜色分割线
            colorLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.03].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.02].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.06].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.04].CGColor];

            colorLayer.locations = @[
                                     [NSNumber numberWithDouble:colorLayer.startPoint.x],
                                     [NSNumber numberWithDouble:colorLayer.startPoint.x],
                                     @0,
                                     [NSNumber numberWithDouble:0.2],
                                     [NSNumber numberWithDouble:1.2]];
            colorLayer.cornerRadius = self.viewCover.layer.cornerRadius;

            [self.viewCover.layer addSublayer:colorLayer];
            colorLayer.mask = maskLayer;

            // 动画 animate
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
            animation.fromValue = colorLayer.locations;
            animation.toValue = @[
                                  @0,
                                  @1,
                                  @1,
                                  @1.2,
                                  @1.2];
            animation.duration = 0.7;
            animation.repeatCount = HUGE;
            [animation setRemovedOnCompletion:NO];
            // 视图添加动画
            [colorLayer addAnimation:animation forKey:@"locations-layer"];

        }
        
    }
    
}

//- (void)shimmer:(UIView *)subview totalCoverablePath:(UIBezierPath *)totalCoverablePath{
//
//
//
//
//
//    // gradientLayer
//    CAGradientLayer *colorLayer = [CAGradientLayer layer];
//    colorLayer.frame = (CGRect)self.view.bounds;
//    //    colorLayer.position = self.view.center;
//    colorLayer.startPoint = CGPointMake(0.0, 0.5);
//    colorLayer.endPoint = CGPointMake(1.0, 0.5);
//    // 颜色分割线
//    colorLayer.locations = @[@(0.0), @(0.1), @(0.3)];
//    // 颜色分配
//    //    colorLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.9686 green:0.9686 blue:0.9686 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:0.5].CGColor,(__bridge id)[UIColor colorWithRed:0.9686 green:0.9686 blue:0.9686 alpha:1].CGColor];
//    colorLayer.colors = @[(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor];
//
//    //    colorLayer.colors = @[(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor];
//    //    colorLayer.colors = @[[UIColor colorWithHue:0.333333 saturation:1 brightness:0.92 alpha:1],[UIColor colorWithHue:0.333333 saturation:1 brightness:0.95 alpha:1],[UIColor colorWithHue:0.333333 saturation:1 brightness:0.88 alpha:1]];
//    // 全部都添加，然后 mask 那几个控件
//    [self.view.layer addSublayer:colorLayer];
////    [self.view.layer addSublayer:maskLayer];
//
//    // 移动动画
//    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"locations"];
//    animation.duration = 0.7;
//    animation.repeatCount = HUGE;
//    [animation setRemovedOnCompletion:NO];
//    animation.toValue = @[@0.6, @1.2, @1.5];//[NSValue valueWithCGPoint:CGPointMake(300, 300)]; // 终点帧
//    // 视图添加动画
//    [colorLayer addAnimation:animation forKey:@"locations-layer"];
//}
- (IBAction)startLoading:(id)sender {
    NSLog(@"start");
}

- (IBAction)stopLoading:(id)sender {
    NSLog(@"stop");
}

@end

