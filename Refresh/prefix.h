//
//  prefix.h
//  Refresh
//
//  Created by lotic on 16/5/29.
//  Copyright © 2016年 lotic. All rights reserved.
//

#ifndef prefix_h
#define prefix_h


#define SCREENWIDTH     [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT    [[UIScreen mainScreen] bounds].size.height
#define LINECOLOR       [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:.3]
#define LT_w            self.frame.size.width
#define LT_h            self.frame.size.height
#define LT_randomColor  [UIColor colorWithRed:(arc4random() % 155 + 100) /255.0 green:(arc4random() % 155 + 100)/255.0 blue:(arc4random() % 155 + 100)/255.0 alpha:1]
#endif /* prefix_h */
