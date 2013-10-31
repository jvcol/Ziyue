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

// 数据更新
#define K_Download_Notification_UpdateData @"K_Download_Notification_UpdateData"

typedef enum {
    DownloadState_None = 0,
    DownloadState_Complete,
    DownloadState_Pause,
    DownloadState_Loading
}DownloadState;

@interface ZYDataCenter : NSObject

@property (nonatomic, assign) BOOL downloadFinished;
@property (nonatomic, readonly, getter = isPaused) BOOL isPaused;


+ (ZYDataCenter *)instance;

- (NSMutableArray *)downloadCourses;
- (NSMutableArray *)downloadChapters;


- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters;

- (DownloadState)downloadStateWithChapterId:(NSInteger)chapterId;

- (NSDictionary *)chapterWithChapterId:(NSInteger)chapterId;

@end
