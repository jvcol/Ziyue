//
//  Utility.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "Utility.h"

NSString * getTimeStr(int timeStamp) {
    int hour = 0;
    int minute = 0;
    int second = 0;
    if (timeStamp < 60) {
        return [NSString stringWithFormat:@"%d秒",timeStamp];
    }else if (timeStamp < 60*60) {
        minute = timeStamp/60;
        second = timeStamp%60;
        return [NSString stringWithFormat:@"%d分%d秒",minute,second];
    }else {
        second = timeStamp%60;
        hour = timeStamp/3600;
        minute = timeStamp - hour*3600+second;
        return [NSString stringWithFormat:@"%d小时%d分%d秒",hour,minute,second];
    }
    return nil;
}




@implementation Utility

- (void)function {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    }
}

@end
