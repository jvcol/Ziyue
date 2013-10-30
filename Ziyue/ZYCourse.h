//
//  ZYCourse.h
//  Ziyue
//
//  Created by yangw on 13-10-30.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYCourse : NSObject

@property (nonatomic, assign) NSInteger courseId;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * desp_cn;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, assign) NSInteger chapterNum;

@end
