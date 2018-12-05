//
//  DWLoadingShimmer.m
//  DWLoadingShimmer
//
//  Created by Dwyane on 2018/11/27.
//  Copyright © 2018年 Dwyane_Coding. All rights reserved.
// https://github.com/iDwyane/DWLoadingShimmer

#import "DWLoadingShimmer.h"

@interface DWLoadingShimmer ()

/** 拿来遮盖 toCoveriView 的覆盖层 */
@property (nonatomic, strong) UIView *viewCover;
/** 颜色渐变层 */
@property (nonatomic, strong) CAGradientLayer *colorLayer;
/** 用于显示建层层的mask */
@property (nonatomic, strong) CAShapeLayer *maskLayer;
/** 总的覆盖路径 */
@property (nonatomic, strong) UIBezierPath *totalCoverablePath;
@end

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define safeAreaTopHeight ((kScreenHeight == 812.0 || kScreenHeight == 896.0) ? 88 : 64) //X h=812,XR & XR max h=896

@implementation DWLoadingShimmer

#pragma mark ------ lazy method ------
- (UIView *)viewCover {
    if (!_viewCover) {
        _viewCover = [UIView new];
        _viewCover.tag = 1127; // 做一个标志，尽可能大一点，防止冲突
        _viewCover.backgroundColor = [UIColor whiteColor];
    }
    return _viewCover;
}

- (UIBezierPath *)totalCoverablePath {
    if (!_totalCoverablePath) {
        _totalCoverablePath = [[UIBezierPath alloc] init]; //总的path
    }
    return _totalCoverablePath;
}


+ (void)startCovering:(UIView *)view {
    [[self alloc] coverSubviews:view];
}

+ (void)stopCovering:(UIView *)view {
    [[self alloc] removeSubviews:view];
}

- (void)removeSubviews:(UIView *)view {
    
    if (!view) {
        @throw [NSException exceptionWithName:@"removeSubViews"
                                       reason:@"[(void)removeSubviews:(UIView *)view]:view is nil"
                                     userInfo:nil];
        return;
    }
    
    for (UIView *subview in view.subviews) {
        if (subview.tag == 1127) {
            [subview removeFromSuperview];
            break; // 跳出循环
        }
    }
    
}


- (void)coverSubviews:(UIView *)view {
    
    if (!view) {
        @throw [NSException exceptionWithName:@"coverSubviews"
                                       reason:@"[(void)coverSubviews:(UIView *)view]:view is nil"
                                     userInfo:nil];
        return;
    }

    // Avoid multiple cover. 避免多次cover
    for (UIView *subview in view.subviews) {
        if (subview.tag == 1127) {
            return;
        }
    }
    
    NSArray *coverableCellsIds = @[@"Cell1", @"Cell1", @"Cell1", @"Cell1", @"Cell1"];
    if ([view isMemberOfClass:[UITableView class]]) {
        for (int i = 0; i < coverableCellsIds.count; i++) {
            [self getTableViewPath:view index:i coverableCellsIds:coverableCellsIds];
        }
        [self addCoverView:view];
        return;
    }

    view.backgroundColor = [UIColor whiteColor];

    if (view.subviews.count > 0) {
        int i = 0;
        for (UIView *subview in view.subviews) {
            // 判断是否 UITableviewCell 类型
            if ([subview isMemberOfClass:[UITableViewCell class]]) {
                [self getTableViewPath:subview index:i coverableCellsIds:coverableCellsIds];
                i++;
                if (i == coverableCellsIds.count-1) {
                    break; //退出循环
                }
            }else {
                
                // 获取每个子控件的path，用于后面的加遮盖
                // 添加圆角
                UIBezierPath *defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:subview.frame.size.height/2.0];
                if ([subview isMemberOfClass:[UILabel class]] || [subview isMemberOfClass:[UITextView class]]) {
                    defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:subview.bounds cornerRadius:4];
                }
                UIBezierPath *relativePath = defaultCoverblePath;
                
                // 计算subview相对super的view的frame
                CGPoint offsetPoint = [subview convertRect:subview.bounds toView:view].origin;
                [subview layoutIfNeeded];
                [relativePath applyTransform:CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y)];
                
                [self.totalCoverablePath appendPath:relativePath];
            }
            
        }
        // 添加遮罩以及动态效果
        [self addCoverView:view];
        
    }
    
}

// 得出需要显示的的coverPath
- (void)getTableViewPath:(UIView *)view index:(int)i coverableCellsIds:(NSArray *)coverableCellsIds {
    
    UITableView *tableView = (UITableView *)view;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:coverableCellsIds[i]];
    
    // Determine if there is a navigation controller. 判断是否有导航控制器
    float headerOffset = [self getHeaderOffset];
    
    cell.frame = CGRectMake(0, cell.frame.size.height*i+headerOffset, cell.frame.size.width, cell.frame.size.height);
    
    [cell layoutIfNeeded];
    
    //If it is a UITableViewCell, you still need to traverse the subviews of the cell a second time. 如果是 UITableViewCell ， 则仍需第二次遍历cell 的 subviews
    for (UIView *cellSubview in cell.contentView.subviews) {
        UIBezierPath *defaultCoverblePath = [UIBezierPath bezierPathWithRoundedRect:cellSubview.bounds cornerRadius:cellSubview.frame.size.height/2.0];
        CGPoint offsetPoint = [cellSubview convertRect:cellSubview.bounds toView:tableView].origin;
        [cellSubview layoutIfNeeded];
        // 因为是相对于 tableview 的 origin，而tableview 有导航栏运行后会有一个自动调节 所以覆盖路径 为offsetPoint.y = offsetPoint.y+headerOffset
        [defaultCoverblePath applyTransform:CGAffineTransformMakeTranslation(offsetPoint.x, offsetPoint.y+headerOffset)];
        
        [self.totalCoverablePath appendPath:defaultCoverblePath];
    }
    
}


- (void)addCoverView:(UIView *)view {
    //  添加挡住所有控件的覆盖层(挡住整superview，包括 superview 的子控件)
    self.viewCover.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height); // tableview的y值由系统自动调节，所以不用 +headerOffset
    [view addSubview:self.viewCover];
    
    // gradientLayer CAGradientLayer是CALayer的一个子类,用来生成渐变色的Layer
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame = (CGRect)view.bounds;
    
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
    
    // superview添加mask(能显示的遮罩)
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = self.totalCoverablePath.CGPath;
    maskLayer.fillColor = [UIColor redColor].CGColor; //设置填充色

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
    animation.duration = 0.9;
    animation.repeatCount = HUGE;
    [animation setRemovedOnCompletion:NO];
    // 视图添加动画
    [colorLayer addAnimation:animation forKey:@"locations-layer"];
    
}

// 增加适配 x xr xr max
- (CGFloat)getHeaderOffset {
    if ([self currentViewController]) {
        return safeAreaTopHeight;
    }else return 0;
}

- (UIViewController *)currentViewController
{
    UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

- (UINavigationController *)currentNavigationController
{
    return [self currentViewController].navigationController;
}


@end
