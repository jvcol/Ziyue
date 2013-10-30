//
//  ZYDataCenter.h
//  Ziyue
//
//  Created by yangw on 13-10-30.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_Download_Notification_Start @"K_Download_Notification_Start"
#define K_Download_Notification_Update @"K_Download_Notification_Update"
#define K_Download_Notification_Finished @"K_Download_Nofitication_Finished"

typedef enum {
    DownloadState_None,
    DownloadState_Complete,
    DownloadState_Loading
}DownloadState;

@interface ZYDataCenter : NSObject

@property (nonatomic, assign) BOOL downloadFinished;


+ (ZYDataCenter *)instance;

- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters;

- (DownloadState)downloadStateWithChapterId:(NSInteger)chapterId;

@end
