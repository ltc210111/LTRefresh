//
//  TableViewController.m
//  Refresh
//
//  Created by lotic on 16/6/2.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import "TableViewController.h"
#import "UITableView+LTRefreshView.h"
@interface TableViewController() <UITableViewDelegate,UITableViewDataSource> {
    NSInteger cellNum;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    cellNum = 5;
    //添加刷新控件
    [self.tableView addRefreshWithBlock:^{
        [self performSelector:@selector(addData) withObject:nil afterDelay:1];
    }];
}
-(void)addData {
    cellNum ++;
    [self.tableView endRefreshingSuccess];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1.4];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cellNum;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        static NSString* indentifier = @"cell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"cell - num : %ld",(long)indexPath.row];
    if(indexPath.row > 4) cell.textLabel.text = [NSString stringWithFormat:@"new cell - num : %ld",(long)indexPath.row];
        return cell;
}

@end

