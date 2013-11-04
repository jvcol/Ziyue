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
#import "Utility.h"

#define k_Table_D_Course @"coursetable"
#define k_Table_D_Chapter @"chaptertable"

@interface ZYDataCenter () <DownloadModelDelegate> {
    DownloadModel * _downloadModel;

    NSMutableArray * _allCourses;

    NSMutableArray * _allChapters;
    
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
    
    [_allCourses removeAllObjects];
    
    [_allChapters removeAllObjects];
    
}

- (NSMutableArray *)downloadCourses {
    return _allCourses;
}

- (NSMutableArray *)downloadChapters {
    return _allChapters;
}

- (id)init {
    self = [super init];
    if (self) {
        _allCourses = [[NSMutableArray alloc] init];
        _allChapters = [[NSMutableArray alloc] init];
        
        _downloadModel = [[DownloadModel alloc] init];
        _downloadModel.delegate = self;

        HDOperationList * executeQueue = [[HDOperationList alloc] init];
        [executeQueue setSuspended:NO];
        [executeQueue addBlock:^NSBlockReturnType{
            [self initTables];
            [self loadAllData];
            return NSBlockReturnTypeAutomatic;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveBeforeQuit)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveBeforeQuit)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        for (NSMutableDictionary * dic in _allChapters) {
            if ([[dic objectForKey:@"downloadState"] intValue] == DownloadState_Loading) {
                self.curDownloadDic = dic;
                int chaptid = [[dic objectForKey:@"_id"] intValue];
                NSString * url = [dic objectForKey:@"file_url"];
                NSString * filename = [dic objectForKey:@"filename"];
                [self.curDownloadDic setObject:[NSNumber numberWithInt:DownloadState_Loading] forKey:@"downloadState"];
                [_downloadModel downloadNetMediaWithUrl:url tag:chaptid fileName:filename];
                break;
            }
        }

    }
    return self;
}

-(void)initTables {
    NSString *create_course_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (courseId integer PRIMARY KEY,cover text ,title text,author text,desp_cn text,category text,chapterNum integer);", k_Table_D_Course] ;
    [[HDBHelper shareDataBase] executeUpdate: create_course_sql];
    
    NSString *create_chapter_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (chaptId integer PRIMARY KEY,courseId integer ,durationStr text,cp_title text,cp_url tex,downloadState integer,cp_downloadSize,cp_totalSize);", k_Table_D_Chapter] ;
    [[HDBHelper shareDataBase] executeUpdate: create_chapter_sql];

}


- (NSDictionary *)chapterWithChapterId:(NSInteger)chapterId {
    for (NSDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            return dic;
        }
    }
    return nil;
}

- (void)pauseChapterWithChapterId:(NSInteger)chapterId {
    for (NSMutableDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            int state = [[dic objectForKey:@"downloadState"] intValue];
            if (state == DownloadState_Loading) {
                [_downloadModel stop];
                self.curDownloadDic = nil;
            }
            [dic setObject:[NSNumber numberWithInt:DownloadState_Pause] forKey:@"downloadState"];
        }
    }
}

- (void)resumeChapterWithChapterId:(NSInteger)chapterId {
    for (NSMutableDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            [dic setObject:[NSNumber numberWithInt:DownloadState_Waiting] forKey:@"downloadState"];
            if (self.curDownloadDic == nil) {
                [_downloadModel resume];
                [self checkForDownload];
            }
        }
    }
}

- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters {
    BOOL exist = NO;
    for (int ii=0; ii<_allCourses.count; ii++) {
        NSMutableDictionary * dic = [_allCourses objectAtIndex:ii];
        if ([[dic objectForKey:@"_id"] integerValue] == [[courseInfo objectForKey:@"_id"] integerValue]) {
            [_allCourses replaceObjectAtIndex:ii withObject:courseInfo];
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_allCourses addObject:courseInfo];
    }
    
    for (NSMutableDictionary * dic in chapters) {
        if (![_allChapters containsObject:dic]) {
            [dic setObject:[NSNumber numberWithInt:DownloadState_Waiting] forKey:@"downloadState"];
            [_allChapters addObject:dic];
        }
    }
    
    [self checkForDownload];
    
}

- (BOOL)hasDownloadedWithChapterId:(NSInteger)chapterId {
    
    for (NSMutableDictionary * dic in _allChapters) {
        if ([dic intValue:@"_id"] == chapterId) {
            return YES;
        }
    }
    return NO;
}

- (void)deleteChapterWithChapterId:(NSInteger)chapterId {
    NSInteger index = NSNotFound;
    NSDictionary * dictmp = nil;
    for (NSMutableDictionary * dic in _allChapters) {
        if ([dic intValue:@"_id"] == chapterId) {
            index = [_allChapters indexOfObject:dic];
            dictmp = dic;
        }
    }
    if (self.curDownloadDic && [[self.curDownloadDic objectForKey:@"_id"] integerValue] == chapterId) { // 正在下载
        // 找到下个
        self.curDownloadDic = nil;
        [_downloadModel stop];
        if (index != NSNotFound) {
            [_allChapters removeObjectAtIndex:index];
        }
        [_downloadModel resume];
        [self checkForDownloadWithLastCourseId:[self.curDownloadDic intValue:@"course_id"]];
    }
    else {
        if (index != NSNotFound) {
            [_allChapters removeObjectAtIndex:index];
        }
    }

    [self performSelectorInBackground:@selector(deleteChapterStart:) withObject:dictmp];
}

- (void)deleteChapterStart:(NSDictionary *)dic {
    NSInteger chapterId = [dic intValue:@"_id"];
    NSString * url = [dic strValue:@"file_url"];
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DownloadFilePath];
    [path stringByAppendingPathComponent:[url md5]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    FMDatabaseQueue* queue = [HDBHelper shareQueue];
    
    [queue inDatabase:^(FMDatabase *db){
        NSString *deletetopic = [NSString stringWithFormat:@"delete from %@ where _id=%d",k_Table_D_Chapter,chapterId];
        [db executeUpdate:deletetopic];
    }];
    
    
    [self performSelectorOnMainThread:@selector(deleteChapterFinish) withObject:nil waitUntilDone:YES];
    
}

- (void)deleteChapterFinish {
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_UpdateData object:nil];

}

- (void)checkForDownload {
    if (self.curDownloadDic == nil) {
        for (NSMutableDictionary * dic in _allChapters) {
            if ([[dic objectForKey:@"downloadState"] intValue] == DownloadState_Waiting) {
                self.curDownloadDic = dic;
                int chaptid = [[dic objectForKey:@"_id"] intValue];
                NSString * url = [dic objectForKey:@"file_url"];
                NSString * filename = [dic objectForKey:@"filename"];
                [self.curDownloadDic setObject:[NSNumber numberWithInt:DownloadState_Loading] forKey:@"downloadState"];
                [_downloadModel downloadNetMediaWithUrl:url tag:chaptid fileName:filename];
                break;
            }
        }
    }
    
}

- (void)checkForDownloadWithLastCourseId:(NSInteger)courseId {
    if (self.curDownloadDic) {
        return;
    }
    BOOL find = NO;
    for (NSMutableDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"downloadState"] intValue] == DownloadState_Waiting && [[dic objectForKey:@"course_id"] integerValue] == courseId) {
            find = YES;
            self.curDownloadDic = dic;
            int chaptid = [[dic objectForKey:@"_id"] intValue];
            NSString * url = [dic objectForKey:@"file_url"];
            NSString * filename = [dic objectForKey:@"filename"];
            [self.curDownloadDic setObject:[NSNumber numberWithInt:DownloadState_Loading] forKey:@"downloadState"];
            [_downloadModel downloadNetMediaWithUrl:url tag:chaptid fileName:filename];
            break;
        }
    }
    if (!find) {
        [self checkForDownload];
    }
}

- (void)didFileDownloaded:(NSString*)path tag:(NSInteger)tag {
    if (self.curDownloadDic != nil) {
        [self.curDownloadDic setObject:[NSNumber numberWithInt:DownloadState_Complete] forKey:@"downloadState"];
        
        int index = NSNotFound;
        for (int ii=0;ii<_allChapters.count;ii++) {
            NSDictionary * dic  = [_allChapters objectAtIndex:ii];
            if ([dic objectForKey:@"_id"] == [self.curDownloadDic objectForKey:@"_id"]) {
                index = ii;
            }
        }
        if (index != NSNotFound) {
            [_allChapters replaceObjectAtIndex:index withObject:self.curDownloadDic];
        }else {
            [_allChapters insertObject:self.curDownloadDic atIndex:0];
        }
        NSInteger courseId = [[self.curDownloadDic objectForKey:@"course_id"] integerValue];
        self.curDownloadDic = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Finished object:nil];

        [self checkForDownloadWithLastCourseId:courseId];
        
    }
}

- (void)didFileDownloadReceiveBytes:(long long)bytes {
    NSLog(@"%lld",bytes);
    if (self.curDownloadDic) {
        long size = [[self.curDownloadDic objectForKey:@"downloadSize"] longValue];
        size += bytes;
        [self.curDownloadDic setObject:[NSNumber numberWithLong:size] forKey:@"downloadSize"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Update object:nil];
}

- (void)didFileDownLoadedFailed:(int)tag {
    NSLog(@"file download failed");
}

- (void)loadAllData {
    __block NSMutableArray * coursearray  = [NSMutableArray array];
    __block NSMutableArray * chaptersarray = [NSMutableArray array];
    
    FMDatabaseQueue* queue = [HDBHelper shareQueue];

    [queue inDatabase:^(FMDatabase *db){
        db.logsErrors = YES;

        NSString *sql = [NSString stringWithFormat:@"select * from %@", k_Table_D_Course];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSInteger coursid = [rs intForColumn:@"courseId"];
            NSString * cover = [rs stringForColumn:@"cover"];
            NSString * title = [rs stringForColumn:@"title"];
            NSString * author = [rs stringForColumn:@"author"];
            NSString * desp_cn = [rs stringForColumn:@"desp_cn"];
            NSString * category = [rs stringForColumn:@"category"];
            NSInteger chatnum = [rs intForColumn:@"chapterNum"];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjects:
                                  [NSArray arrayWithObjects:
                                   [NSNumber numberWithInteger:coursid],cover,title,author,desp_cn,category,[NSNumber numberWithInteger:chatnum], nil] forKeys:
                                  [NSArray arrayWithObjects:@"_id",@"cover",@"title_ch",@"author",@"desc",@"subject",@"chaptnum", nil]];
            [coursearray addObject:dic];
        }
        
        sql = [NSString stringWithFormat:@"select * from %@",k_Table_D_Chapter];
        FMResultSet * rss = [db executeQuery:sql];
        while ([rss next]) {
            NSInteger chapterid = [rss intForColumn:@"chaptId"];
            NSInteger courseid = [rss intForColumn:@"courseId"];
            NSString * durationStr = [rss stringForColumn:@"durationStr"];
            NSString * title = [rss stringForColumn:@"cp_title"];
            NSString * url = [rss stringForColumn:@"cp_url"];
            int state = [rss intForColumn:@"downloadState"];
            long downloadSize = [rss longForColumn:@"cp_downloadSize"];
            long totalSize = [rss longForColumn:@"cp_totalSize"];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjects:
                                  [NSArray arrayWithObjects:
                                   [NSNumber numberWithInteger:chapterid],[NSNumber numberWithInteger:courseid],durationStr,title,url,[NSNumber numberWithInt:state], [NSNumber numberWithLong:downloadSize], [NSNumber numberWithLong:totalSize], nil] forKeys:
                                  [NSArray arrayWithObjects:@"_id",@"course_id",@"dur",@"title",@"file_url",@"downloadState", @"downloadSize", @"totalSize", nil]];
            [chaptersarray addObject:dic];
        }
        
    }];

    [_allCourses removeAllObjects];
    [_allChapters removeAllObjects];
    [_allCourses addObjectsFromArray:coursearray];
    [_allChapters addObjectsFromArray:chaptersarray];
}

- (void)saveCourseInfo:(NSDictionary *)courseInfo {
    FMDatabaseQueue* queue = [HDBHelper shareQueue];
    
    // 存储课程信息
    [queue inDatabase:^(FMDatabase *db){
        db.logsErrors = YES;
        
        NSInteger coursid = [[courseInfo objectForKey:@"_id"] integerValue];
        NSString * cover = [courseInfo strValue:@"cover"];
        NSString * title = [courseInfo strValue:@"title_ch"];
        NSString * author = [courseInfo strValue:@"author"];
        NSString * desp_cn = [courseInfo strValue:@"desc"];
        NSString * category = [courseInfo strValue:@"subject"];
        NSInteger chatnum = [[courseInfo objectForKey:@"chaptnum"] integerValue];
        
        NSString *userSql = [NSString stringWithFormat:@"REPLACE INTO %@ (courseId,cover,title,author,desp_cn,category,chapterNum) values (%d,'%@','%@','%@','%@','%@',%d)",k_Table_D_Course,coursid,cover,title,author,desp_cn,category,chatnum];
        [db executeUpdate:userSql];
        
    }];
    
}

- (void)saveChapterInfo:(NSDictionary *)chapter {
    
    FMDatabaseQueue* queue = [HDBHelper shareQueue];
    
    // 存储课程章节信息
    [queue inDatabase:^(FMDatabase *db){
        db.logsErrors = YES;
        
        NSInteger chapterid = [[chapter objectForKey:@"_id"] integerValue];
        NSInteger courseid = [[chapter objectForKey:@"course_id"] integerValue];
        NSString * durationStr = [chapter objectForKey:@"dur"];
        NSString * title = [chapter objectForKey:@"title"];
        NSString * url = [chapter objectForKey:@"file_url"];
        int state = [[chapter objectForKey:@"downloadState"] intValue];
        long downloadSize = [[chapter objectForKey:@"downloadSize"] longValue];
        long totalSize = [[chapter objectForKey:@"totalSize"] longValue];

        NSString *userSql = [NSString stringWithFormat:@"REPLACE INTO %@ (chaptId,courseId,durationStr,cp_title,cp_url,downloadState,cp_downloadSize,cp_totalSize) values (%d, %d,'%@','%@','%@',%d,%ld,%ld)",k_Table_D_Chapter,chapterid,courseid,durationStr,title,url,state,downloadSize,totalSize];
        [db executeUpdate:userSql];
        
    }];
    
}

- (void)saveBeforeQuit {
    if (self.curDownloadDic) {
        for (NSMutableDictionary * dic in _allChapters) {
            if ([dic intValue:@"_id"] == [self.curDownloadDic intValue:@"_id"]) {
                [dic setObject:[self.curDownloadDic objectForKey:@"downloadSize"] forKey:@"downloadSize"];
                [dic setObject:[self.curDownloadDic objectForKey:@"downloadState"] forKey:@"downloadState"];
            }
        }
    }
    NSMutableArray * coursearray = [NSMutableArray arrayWithArray:_allCourses];
    NSMutableArray * chapterarray = [NSMutableArray arrayWithArray:_allChapters];
    
    [_allCourses removeAllObjects];
    [_allChapters removeAllObjects];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_apply([coursearray count], queue, ^(size_t index){
            NSDictionary * dic = [coursearray objectAtIndex:index];
            [self saveCourseInfo:dic];
        });
        dispatch_apply([chapterarray count], queue, ^(size_t index){
            NSDictionary * dic = [chapterarray objectAtIndex:index];
            [self saveChapterInfo:dic];
        });

    });

}


@end
