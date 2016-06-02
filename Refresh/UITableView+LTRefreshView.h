//
//  UITableView+LTRefreshView.h
//  Refresh
//
//  Created by lotic on 16/6/2.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTRefresh.h"

@interface UITableView (LTRefreshView)
///下拉View
@property (strong, nonatomic) LTRefresh *indicator;

- (void)addRefreshWithBlock:(void (^)())block;
///刷新结果
- (void)endRefreshingSuccess;
- (void)endRefreshingFail;
@end
