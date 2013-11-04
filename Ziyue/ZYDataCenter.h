//
//  ZYDataCenter.h
//  Ziyue
//
//  Created by yangw on 13-10-30.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_Download_Notification_Update @"K_Download_Notification_Update" // 正在下载
#define K_Download_Notification_Finished @"K_Download_Nofitication_Finished" // 当前任务下载完成

// 数据更新 当执行删除操作时
#define K_Download_Notification_UpdateData @"K_Download_Notification_UpdateData"

typedef enum {
    DownloadState_None = 0,
    DownloadState_Complete,
    DownloadState_Pause,
    DownloadState_Waiting,
    DownloadState_Loading
}DownloadState;

@interface ZYDataCenter : NSObject

@property (nonatomic, assign) BOOL downloadFinished;

@property (nonatomic, retain) NSMutableDictionary * curDownloadDic;


+ (ZYDataCenter *)instance;

- (NSMutableArray *)downloadCourses;
- (NSMutableArray *)downloadChapters;


- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters;
- (void)pauseChapterWithChapterId:(NSInteger)chapterId;
- (void)resumeChapterWithChapterId:(NSInteger)chapterId;

- (BOOL)hasDownloadedWithChapterId:(NSInteger)chapterId;

- (void)deleteChapterWithChapterId:(NSInteger)chapterId;


- (NSDictionary *)chapterWithChapterId:(NSInteger)chapterId;

@end
