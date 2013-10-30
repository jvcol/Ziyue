//
//  ZYChapter.h
//  Ziyue
//
//  Created by yangw on 13-10-30.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYChapter : NSObject

@property (nonatomic, assign) NSInteger chaptId;
@property (nonatomic, assign) NSInteger courseId;
@property (nonatomic, retain) NSString * durationStr;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
