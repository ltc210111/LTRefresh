//
//  ViewController.m
//  Refresh
//
//  Created by lotic on 16/5/27.
//  Copyright © 2016年 lotic. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+LTRefreshView.h"

@interface ViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic,assign) NSInteger num;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.num = 0;
    UIButton * b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.backgroundColor = [UIColor redColor];
    [b setTitle:[NSString stringWithFormat:@"%ld",(long)self.num] forState:UIControlStateNormal];
    b.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 50, 30, 100, 30);
    [b addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:b];
    self.mainScrollView.delegate =self;
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.bounds.size.width, self.mainScrollView.bounds.size.height+100);
    self.mainScrollView.backgroundColor = [UIColor clearColor];
    
    //添加刷新控件
    [self.mainScrollView addRefreshWithBlock:^{
        NSLog(@"LPRefresh开始刷新");
        self.num++;
        [b setTitle:[NSString stringWithFormat:@"%ld",(long)self.num] forState:UIControlStateNormal];
    }];
    
}
- (IBAction)successBtn:(id)sender {
    [self.mainScrollView endRefreshingSuccess];
}
- (IBAction)failBtn:(id)sender {
    [self.mainScrollView endRefreshingFail];
}

-(void) buttonAction {
     [self.mainScrollView endRefreshingSuccess];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f",self.mainScrollView.contentInset.top);
}


@end
