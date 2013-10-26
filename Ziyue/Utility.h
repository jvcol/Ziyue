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


@interface Utility : NSObject

@end
