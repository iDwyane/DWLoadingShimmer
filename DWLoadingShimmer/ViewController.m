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
@property (nonatomic, strong) CAGradientLayer *colorLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
/** 是否已经覆盖，覆盖就继续覆盖 */
@property (nonatomic, assign) BOOL isCovered;
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

- (void)viewDidAppear:(BOOL)animated {
    
    // 自定义view 也支持
//    UIView *bgView = [UIView new];
//    bgView.backgroundColor = [UIColor redColor];
//    bgView.frame = CGRectMake(100, self.view.frame.size.height-60, 300, 50);
//    [self.view addSubview:bgView];
    //遍历 subviews
    [self coverSubviews:self.view];
}
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)coverSubviews:(UIView *)view {
    self.isCovered = YES;
    view.backgroundColor = [UIColor whiteColor];
    if (self.view.subviews.count > 0) {
        for (UIView *subview in view.subviews) {
            
            // 获取每个子控件的path，用于后面的加遮盖
            // 添加圆角
            UIBezierPath *defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:subview.frame.size.height/2.0/*subview.layer.cornerRadius*/];
            if ([subview isMemberOfClass:[UILabel class]] || [subview isMemberOfClass:[UITextView class]]) {
                defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:4];
            }
            UIBezierPath *relativePath = defaultCoverblePath;
            
            // 计算subview相对super的view的frame
            CGPoint offsetPoint = [subview convertRect:subview.bounds toView:view].origin;
            [subview layoutIfNeeded];
            [relativePath applyTransform:CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y)];
            
            UIBezierPath *totalCoverablePath = [[UIBezierPath alloc] init];
            [totalCoverablePath appendPath:relativePath];
            
            //  添加挡住所有控件的覆盖层(挡住整superview，包括 superview 的子控件)
            self.viewCover.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            [view addSubview:self.viewCover];
            
            
            // gradientLayer CAGradientLayer是CALayer的一个子类,用来生成渐变色的Layer
            CAGradientLayer *colorLayer = [CAGradientLayer layer];
            colorLayer.frame = (CGRect)self.view.bounds;

            colorLayer.startPoint = CGPointMake(-1.4, 0);
            colorLayer.endPoint = CGPointMake(1.4, 0);
            
            // 颜色分割线
            colorLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.01].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.009].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.04].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02].CGColor];

            colorLayer.locations = @[
                                     [NSNumber numberWithDouble:colorLayer.startPoint.x],
                                     [NSNumber numberWithDouble:colorLayer.startPoint.x],
                                     @0,
                                     [NSNumber numberWithDouble:0.2],
                                     [NSNumber numberWithDouble:1.2]];

            [self.viewCover.layer addSublayer:colorLayer];
            self.colorLayer = colorLayer;
            
            // superview添加mask(能显示的遮罩)
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = totalCoverablePath.CGPath;
            maskLayer.fillColor = [UIColor whiteColor].CGColor;
            colorLayer.mask = maskLayer;
            self.maskLayer = maskLayer;
             NSLog(@"maskLayer = %p", maskLayer);
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

- (IBAction)startLoading:(id)sender {
    if (self.isCovered) {
        return;
    }
    [self coverSubviews:self.view];
    NSLog(@"start");
}

- (IBAction)stopLoading:(id)sender {
    self.isCovered = NO;
    // 移除动态效果以及图层
    NSLog(@"self.maskLayer = %p", self.maskLayer);
    [self.colorLayer removeAllAnimations];
    [self.colorLayer removeFromSuperlayer];
    [self.maskLayer removeFromSuperlayer];
    // 移除控件的覆盖层
    [self.viewCover removeFromSuperview];
}

@end

