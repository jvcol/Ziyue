//
//  ZYDataCenter.m
//  Ziyue
//
//  Created by yangw on 13-10-30.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "ZYDataCenter.h"
#import "HDBHelper.h"
#import "DownloadModel.h"
#import "ZYCourse.h"
#import "ZYChapter.h"
#import "HDOperationList.h"
#import "DownloadModel.h"

#define k_Table_D_Course @"coursetable"
#define k_Table_D_Chapter @"chaptertable"

@interface ZYDataCenter () <DownloadModelDelegate> {
    DownloadModel * _downloadModel;
    
    NSMutableArray * _hasDownloadedCourses;
    
    NSMutableArray * _allChapters;
    NSMutableArray * _hasDownloadesChapters;
    NSMutableArray * _waitingDownloadChapter;
    
    NSInteger _downloadingChapterId;
}

@end

@implementation ZYDataCenter

+(ZYDataCenter*)instance {
    static ZYDataCenter* instance = nil;
    @synchronized(self) {
        if (instance == nil)
            instance = [[[self class] alloc] init];
    }
    return instance;
}

- (void)dealloc {
    _downloadModel.delegate = nil;
    _downloadModel = nil;
    
    [_hasDownloadedCourses removeAllObjects];
    [_allChapters removeAllObjects];
    [_hasDownloadesChapters removeAllObjects];
    [_waitingDownloadChapter removeAllObjects];
}

- (id)init {
    self = [super init];
    if (self) {
        _hasDownloadedCourses = [[NSMutableArray alloc] init];
        _allChapters = [[NSMutableArray alloc] init];
        _hasDownloadesChapters = [[NSMutableArray alloc] init];
        _waitingDownloadChapter = [[NSMutableArray alloc] init];
        
        _downloadModel = [[DownloadModel alloc] init];
        _downloadModel.delegate = self;

        HDOperationList * executeQueue = [[HDOperationList alloc] init];
        [executeQueue setSuspended:NO];
        [executeQueue addBlock:^NSBlockReturnType{
            [self initTables];
            return NSBlockReturnTypeAutomatic;
        }];

    }
    return self;
}

-(void)initTables {
    NSString *create_course_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (courseId integer PRIMARY KEY,cover text ,title text,author text,desp_cn text,category text,chapterNum integer);", k_Table_D_Course] ;
    [[HDBHelper shareDataBase] executeUpdate: create_course_sql];
    
    NSString *create_chapter_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (chaptId integer PRIMARY KEY,courseId integer ,durationStr text,title text,url tex);", k_Table_D_Chapter] ;
    [[HDBHelper shareDataBase] executeUpdate: create_chapter_sql];

}

- (DownloadState)downloadStateWithChapterId:(NSInteger)chapterId {
    if (chapterId == _downloadingChapterId) {
        return DownloadState_Loading;
    }
    
    
    
    return DownloadState_None;
}

- (void)saveCourseInfo:(NSDictionary *)courseInfo {
    FMDatabaseQueue* queue = [HDBHelper shareQueue];
    
    // 存储课程信息
    [queue inDatabase:^(FMDatabase *db){
        db.logsErrors = YES;
        
        NSInteger coursid = [[courseInfo objectForKey:@"_id"] integerValue];
        NSString * cover = [courseInfo objectForKey:@"cover"];
        NSString * title = [courseInfo objectForKey:@"title_ch"];
        NSString * author = [courseInfo objectForKey:@"author"];
        NSString * desp_cn = [courseInfo objectForKey:@"desc"];
        NSString * category = [courseInfo objectForKey:@"subject"];
        NSInteger chatnum = [[courseInfo objectForKey:@"chaptnum"] integerValue];
        
        NSString *userSql = [NSString stringWithFormat:@"REPLACE INTO %@ (courseId,cover,title,author,desp_cn,category,chapterNum) values (%d,'%@','%@','%@','%@','%@',%d)",k_Table_D_Course,coursid,cover,title,author,desp_cn,category,chatnum];
        [db executeUpdate:userSql];
        
    }];

}

- (void)saveChapterInfo:(NSDictionary *)chapter {
    BOOL exist = NO;
    for (int ii=0; ii<_hasDownloadedCourses.count; ii++) {
        NSDictionary * dic = [_hasDownloadedCourses objectAtIndex:ii];
        if ([[dic objectForKey:@"_id"] intValue] == [[chapter objectForKey:@"_id"] intValue]) {
            [_hasDownloadedCourses replaceObjectAtIndex:ii withObject:chapter];
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_hasDownloadedCourses addObject:chapter];
    }
    
    NSInteger chapterid = [[chapter objectForKey:@"_id"] integerValue];
    NSInteger courseid = [[chapter objectForKey:@"course_id"] integerValue];
    NSString * durationStr = [chapter objectForKey:@"dur"];
    NSString * title = [chapter objectForKey:@"title"];
    NSString * url = [chapter objectForKey:@"file_url"];
    
    FMDatabaseQueue* queue = [HDBHelper shareQueue];
    
    // 存储课程章节信息
    [queue inDatabase:^(FMDatabase *db){
        db.logsErrors = YES;
        
        NSString *userSql = [NSString stringWithFormat:@"REPLACE INTO %@ (chaptId,courseId,durationStr,title,url) values (%d, %d,'%@','%@','%@')",k_Table_D_Chapter,chapterid,courseid,durationStr,title,url];
        [db executeUpdate:userSql];

    }];

}

- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters {
    
    [self saveChapterInfo:courseInfo];
    
    //
    for (int ii=0; ii<chapters.count; ii++) {
        [self addChapter2WaitingLoadList:[chapters objectAtIndex:ii]];
    }
    
}

- (void)addChapter2WaitingLoadList:(NSDictionary *)chapter {
    int chapterid = [[chapter objectForKey:@"_id"] intValue];
    for (NSDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] intValue] == chapterid) {
            return;
        }
    }
    
    self.downloadFinished = NO;
    [_waitingDownloadChapter addObject:chapter];
    if (_waitingDownloadChapter.count == 1) { // 开始下载
        [self go2Download];
    }

}

- (void)go2Download {
    if (_waitingDownloadChapter.count > 0) {
        NSDictionary * dic = [_waitingDownloadChapter objectAtIndex:0];
        int chaptid = [[dic objectForKey:@"_id"] intValue];
        NSString * url = [dic objectForKey:@"file_url"];
        if (url && url.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Start object:nil];
            [_downloadModel downloadNetMediaWithUrl:url tag:chaptid validator:nil];
        }
    }else {
        NSLog(@"下载完毕");
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Finished object:nil];
    }
}

- (void)stop {
    
}

- (void)resume {
    
}

- (void)didFileDownloaded:(NSString*)path tag:(NSInteger)tag validator:(id)validator {
    if (_waitingDownloadChapter.count > 0) {
        NSDictionary * dic = [_waitingDownloadChapter objectAtIndex:0];
        [self saveChapterInfo:dic];
        [_waitingDownloadChapter removeObjectAtIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Update object:nil];
        [self go2Download];
    }
}

- (void)didFileDownloadReceiveBytes:(long long)bytes {
    NSLog(@"%lld",bytes);
}

- (void)didFileDownLoadedFailed:(int)tag {
    [self stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Finished object:nil];

}


@end
