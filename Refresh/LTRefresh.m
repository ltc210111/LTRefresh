//
//  LTRefresh.m
//  Refresh
//
//  Created by lotic on 16/5/27.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import "LTRefresh.h"
#import "prefix.h"

@interface LTRefresh() {
    //绘制视图
    CALayer *drawLayer;
    //提示标签
    UILabel *capionLabel;
    UILabel *refreshLabel;
    //指示器图标
    UIImage *image;
    //圈圈图层
    UIView *circleView;
    //是否在进行回弹动画
    BOOL backing;
    //回弹动画结束立即执行结束的动画
    void (^backCompleteBlock)();
}
@property (nonatomic, assign)BOOL refreshing;   //刷新状态
@property (nonatomic, assign)BOOL shouldDo;     //执行控制
@property (nonatomic, assign)BOOL scrolling;    //是否回弹
@property (nonatomic, strong)CAGradientLayer *gradientLayer; //颜色渐变层
@end

///下拉到此偏移量开变形
const CGFloat LPBeganStretchOffset = 24;
///下拉到此偏移量开始刷新
const CGFloat LPBeganRefreshOffset = 54;
///下拉到此偏移量动画结束
const CGFloat LPEndAnimateOffset = 84;

const CGFloat LPRefreshMargin = 3;
const NSTimeInterval LPRefreshAnimateDuration = 0.5;

@implementation LTRefresh
#pragma mark - 重写
- (instancetype)init {
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 0, LPBeganStretchOffset);
        self.clipsToBounds = YES;
        //圈圈图层
        circleView = [UIView new];
        circleView.frame = CGRectMake(SCREENWIDTH/4, 0, SCREENWIDTH/15, SCREENWIDTH/15);
        [self addSubview:circleView];
        //图层
        drawLayer = [CALayer layer];
        drawLayer.frame = CGRectMake(0, 0, SCREENWIDTH/15, SCREENWIDTH/15);
        drawLayer.opacity = 0;
        [circleView.layer addSublayer:drawLayer];
        //提示标签
        capionLabel = [UILabel new];
        capionLabel.text = @"下拉刷新";
        capionLabel.bounds = CGRectMake(0, 0, 300, 30);
        capionLabel.center = CGPointMake(0, -3);
        capionLabel.alpha = 0;
        capionLabel.textColor = [UIColor colorWithWhite:.45 alpha:1];
        capionLabel.textAlignment = NSTextAlignmentCenter;
        capionLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:capionLabel];
        //刷新提示标签
        refreshLabel = [UILabel new];
        refreshLabel.text = @"释放刷新";
        refreshLabel.bounds = CGRectMake(0, 0, 300, 15);
        refreshLabel.center = CGPointMake(0, -3);
        refreshLabel.alpha = 0;
        refreshLabel.textColor = [UIColor colorWithWhite:.45 alpha:1];
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        refreshLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:refreshLabel];
        self.scrolling = NO;
    }
    return self;
}

- (void)setPullProgress:(CGFloat)pullProgress {
    CGRect frame = self.frame;
    frame.size.height = pullProgress;
    frame.origin.y = -pullProgress;
    self.frame = frame;
    
    [self drawChange:pullProgress];
    if (pullProgress == 0) {
        self.backgroundColor = LT_randomColor;
        [circleView.layer removeAnimationForKey:@"rotationAnimation"];
        refreshLabel.text = @"释放刷新";
    }
    if (pullProgress == _pullProgress) return;
    if(self.refreshing) {
        if (_pullProgress > LPEndAnimateOffset && pullProgress < LPEndAnimateOffset) {
            [self superviewScrollTo:-LPEndAnimateOffset];//滚动
            [self doRefresh];
        }
    }
    _pullProgress = pullProgress;
}

#pragma mark - 绘制
- (void)drawChange:(CGFloat)h {
///初始化画布
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize size = drawLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, screenScale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

///绘制图片&圆线
    //大圆半径
    CGFloat R = size.width /2;
    //拉伸度
    CGFloat s = (h-LPBeganStretchOffset) / (LPBeganRefreshOffset-LPBeganStretchOffset);
    CGRect frame = CGRectMake(-R, -R , 2*R, 2*R);
    //－/绘制圆线
    CGContextSetRGBStrokeColor(ctx,.3,.3,.3,.8);
    CGContextSetLineWidth(ctx, 1.0);
    s = s < 1.5 ? s : 1.4;
    CGContextAddArc(ctx, R, R, R - 6, - M_PI_2,s * M_PI, 0);
    CGContextDrawPath(ctx, kCGPathStroke); //绘制路径
    //旋转坐标系
    CGContextTranslateCTM(ctx, R, R );
    CGContextRotateCTM(ctx, s * M_PI*1.5);
    if (!image) image = [UIImage imageNamed:@"LPRefresh_pull"];
    [image drawInRect:frame];
    //提取绘制图像
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ctx);
    CGContextRelease(ctx);
    UIGraphicsEndImageContext();
    drawLayer.opacity = h / LPBeganRefreshOffset * 2;
    drawLayer.contents = (__bridge id _Nullable)(img.CGImage);
////进入形变
    ///开始动画
    if (h <= LPBeganRefreshOffset) {
        if(h!=0) self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:h / 180];  //动态变化背景颜色
        circleView.frame = CGRectMake(SCREENWIDTH/3 , h / 2, SCREENWIDTH/15, SCREENWIDTH/15);
        capionLabel.center = CGPointMake(SCREENWIDTH/2, h / 2 + SCREENWIDTH/30);
        if (h > LPBeganStretchOffset) {
            refreshLabel.alpha = 0;
            capionLabel.alpha = 1;
        }
    }
    ///进入刷新
    else if (h > LPBeganRefreshOffset) {
        capionLabel.alpha = 1 - (h - LPBeganStretchOffset) * 2 / LPEndAnimateOffset ;
        capionLabel.center = CGPointMake(SCREENWIDTH/2, 1.6 * (h - 30));
        refreshLabel.alpha = h / LPBeganRefreshOffset - 1;
        refreshLabel.center = CGPointMake(SCREENWIDTH/2, 1.6 * (h - 39));
        if ( h > LPBeganRefreshOffset * 1.2 ) {
            circleView.frame = CGRectMake(SCREENWIDTH/3 , LPBeganRefreshOffset / 2 , SCREENWIDTH/15, SCREENWIDTH/15);
            refreshLabel.center = CGPointMake(SCREENWIDTH/2, (LPBeganRefreshOffset + LPBeganStretchOffset) /2);
            refreshLabel.alpha = 1;
        }
        if( h > LPEndAnimateOffset) self.refreshing = YES;
    }
}
#pragma mark - 刷新
-(void)doRefresh {
    refreshLabel.text = @"刷新中";
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = .618;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 999;
    [circleView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    if (_refreshBlock) _refreshBlock();//执行刷新代码
}

#pragma mark - 辅助方法
//滚动
- (void)superviewScrollTo:(CGFloat)offsetY {
    UIScrollView *scrollView = (UIScrollView *)[self superview];
    if (scrollView) {
        CGPoint offset = scrollView.contentOffset;
        offset.y = offsetY;
        [scrollView setContentOffset:offset animated:YES];
    }
}
#pragma mark - 结束刷新
- (void)refreshSuccess:(BOOL)isSuccess {
    self.refreshing = NO;
    NSString *str = isSuccess == YES?@"请求成功":@"请求失败";
    [UIView animateWithDuration:5 animations:^{
        refreshLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:str];
    } completion:^(BOOL finished) {
        if (finished && _pullProgress == LPEndAnimateOffset) {
            [self performSelector:@selector(superviewScrollTo:) withObject:0 afterDelay:1];
//            [self superviewScrollTo:0];//滚动到顶部
        }
    }];
}

#pragma mark - 结束动画
- (void)endAnimate:(BOOL)isSuccess {
    NSString *str = isSuccess == YES?@"请求成功":@"请求失败";
    self.refreshing = NO;
    refreshLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:str];
    [UIView animateWithDuration:5. animations:^{
        refreshLabel.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished && _pullProgress == LPEndAnimateOffset) {
            [self superviewScrollTo:0];//滚动到顶部
            refreshLabel.text = @"释放刷新";
        }
    }];
}


#pragma mark - 重写布局方法保持居中
//- (void)setFrame:(CGRect)frame {
//    if (self.frame.size.width != frame.size.width) {
//        [self centerSub:frame.size.width];
//    }
//    [super setFrame:frame];
//}

- (void)setBounds:(CGRect)bounds {
    if (self.bounds.size.width != bounds.size.width) {
        [self centerSub:bounds.size.width];
    }
    [super setBounds:bounds];
}
//drawLayer居中
- (void)centerSub:(CGFloat)width {
    CGRect frame = drawLayer.frame;
    frame.origin.x = (width - frame.size.width) / 2.l;
    drawLayer.frame = frame;
    CGPoint center = capionLabel.center;
    center.x = width / 2.l;
    capionLabel.center = center;
}
#pragma mark - 懒加载
//- (CAGradientLayer *)gradientLayer {
//    if(_gradientLayer == nil) {
//        _gradientLayer = [CAGradientLayer layer];
//        UIColor *color1 = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:.3];
//        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)color1.CGColor,(id)LINECOLOR.CGColor, nil];
//        self.gradientLayer.startPoint = CGPointMake(0.5, 0.9);
//        self.gradientLayer.endPoint = CGPointMake(0.5, 1);
//        [self.layer addSublayer:self.gradientLayer];
//
//    }
//    return _gradientLayer;
//}

//- (CALayer *)drawLayer {
//    if(_drawLayer == nil) {
//        _drawLayer = [[CALayer alloc]init];
//    }
//    return _drawLayer;
//}

//-(void)setCapionLabel:(UILabel *)capionLabel {
//    if (_capionLabel != self.capionLabel) {
//        [self.indicator removeFromSuperview];
//
//        [self addSubview:indicator];
//    }
//}
@end