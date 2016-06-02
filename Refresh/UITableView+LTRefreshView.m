//
//  UITableView+LTRefreshView.m
//  Refresh
//
//  Created by lotic on 16/6/2.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import "UITableView+LTRefreshView.h"
#import <objc/runtime.h>
#import "prefix.h"

static NSString *KEY_PATH = @"contentOffset";

@implementation UITableView (LTRefreshView)
//(rumtime机制)
#pragma mark - 属性getter和setter方法
static char LPRefreshIndicatorKey;
- (void)setIndicator:(LTRefresh *)indicator {
    if (indicator != self.indicator) {
        [self.indicator removeFromSuperview];
        objc_setAssociatedObject(self, &LPRefreshIndicatorKey, indicator, OBJC_ASSOCIATION_ASSIGN);
        [self addSubview:indicator];
    }
}

- (LTRefresh *)indicator {
    return objc_getAssociatedObject(self, &LPRefreshIndicatorKey);
}

#pragma mark - 添加刷新事件
- (void)addRefreshWithBlock:(void (^)())block {
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = NO;
    //添加观察者，监听contentOffset
    [self addObserver:self
           forKeyPath:KEY_PATH
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    //刷新主件
    self.indicator = [LTRefresh new];
    CGRect frame = self.indicator.frame;
    frame.size.width = SCREENWIDTH;
    self.indicator.frame = frame;
    self.indicator.refreshBlock = block;
}

#pragma mark - 监听相应事件
//当界面开始滑动
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if([keyPath isEqualToString:KEY_PATH]) {
        self.indicator.pullProgress = -self.contentOffset.y;
    }
}
#pragma mark - 结束刷新
- (void)endRefreshingSuccess {
    [self.indicator refreshSuccess:YES];
}

- (void)endRefreshingFail {
    [self.indicator refreshSuccess:NO];
}

@end
