//
//  Utility.h
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

#define isiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? YES : NO


#define PrintSelfInfo     NSLog(@"class: %@ -> function: %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));

#define FONT(a) [UIFont systemFontOfSize:a]
#define RGB3(a) [UIColor colorWithRed:(a)/255.0 green:(a)/255.0 blue:(a)/255.0 alpha:1]
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define iOS7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)?YES:NO)

#define CLIENT_AGENT @"iPhoneClient"

NSString * getTimeStr(int timeStamp);

BOOL hdEnsurePath(NSString* path);


@interface NSString(encoding)
- (NSString*)md5;
- (NSString *)encodeString:(NSStringEncoding)encoding;

@end

@interface Utility : NSObject

@end
