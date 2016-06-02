//
//  LTRefresh.h
//  Refresh
//
//  Created by lotic on 16/5/27.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTRefresh : UIView
///下拉进度
@property (assign, nonatomic) CGFloat pullProgress;
///刷新执行
@property (strong, nonatomic) void (^refreshBlock)();
@property (assign, nonatomic) CGContextRef ctx;
//滚动至指定点
- (void)superviewScrollTo:(CGFloat)offsetY;
- (void)refreshSuccess:(BOOL)isSuccess;
@end
