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

    NSMutableArray * _allCourses;

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
    
    [_allChapters removeAllObjects];
    [_hasDownloadesChapters removeAllObjects];
    [_waitingDownloadChapter removeAllObjects];
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
        _hasDownloadesChapters = [[NSMutableArray alloc] init];
        _waitingDownloadChapter = [[NSMutableArray alloc] init];
        
        _downloadModel = [[DownloadModel alloc] init];
        _downloadModel.delegate = self;

        HDOperationList * executeQueue = [[HDOperationList alloc] init];
        [executeQueue setSuspended:NO];
        [executeQueue addBlock:^NSBlockReturnType{
            [self initTables];
            [self loadAllData];
            return NSBlockReturnTypeAutomatic;
        }];
        
        
        for (NSDictionary * dic in _allChapters) {
            int state = [[dic objectForKey:@"downloadState"] intValue];
            if (state == DownloadState_Complete) {
                [_hasDownloadesChapters addObject:dic];
            }else if (state == DownloadState_Loading) {
                [self addChapter2WaitingLoadList:dic];
            }
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveBeforeQuit)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveBeforeQuit)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

    }
    return self;
}

-(void)initTables {
    NSString *create_course_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (courseId integer PRIMARY KEY,cover text ,title text,author text,desp_cn text,category text,chapterNum integer);", k_Table_D_Course] ;
    [[HDBHelper shareDataBase] executeUpdate: create_course_sql];
    
    NSString *create_chapter_sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (chaptId integer PRIMARY KEY,courseId integer ,durationStr text,cp_title text,cp_url tex,downloadState integer,cp_downloadSize,cp_totalSize);", k_Table_D_Chapter] ;
    [[HDBHelper shareDataBase] executeUpdate: create_chapter_sql];

}

- (DownloadState)downloadStateWithChapterId:(NSInteger)chapterId {
    if (chapterId == _downloadingChapterId) {
        return DownloadState_Loading;
    }
    for (NSDictionary * dic in _hasDownloadesChapters) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            return DownloadState_Complete;
        }
    }
    
    for (NSDictionary * dic in _waitingDownloadChapter) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            return DownloadState_Loading;
        }
    }
    
    return DownloadState_None;
}

- (NSDictionary *)chapterWithChapterId:(NSInteger)chapterId {
    for (NSDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] integerValue] == chapterId) {
            return dic;
        }
    }
    return nil;
}

- (void)downLoadCourse:(NSDictionary *)courseInfo chapters:(NSArray *)chapters {
    BOOL exist = NO;
    for (int ii=0; ii<_allCourses.count; ii++) {
        NSDictionary * dic = [_allCourses objectAtIndex:ii];
        if ([[dic objectForKey:@"_id"] integerValue] == [[courseInfo objectForKey:@"_id"] integerValue]) {
            [_allCourses replaceObjectAtIndex:ii withObject:courseInfo];
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_allCourses addObject:courseInfo];
    }
    
    //
    for (int ii=0; ii<chapters.count; ii++) {
        [self addChapter2WaitingLoadList:[chapters objectAtIndex:ii]];
    }
    
}

- (void)addChapter2WaitingLoadList:(NSDictionary *)chapter {
    int chapterid = [[chapter objectForKey:@"_id"] intValue];
    for (NSDictionary * dic in _allChapters) {
        if ([[dic objectForKey:@"_id"] intValue] == chapterid && [[dic objectForKey:@"downloadState"] intValue] == DownloadState_Complete) {
            return;
        }
    }
    
    [_allChapters addObject:chapter];
    
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
        _downloadingChapterId = chaptid;
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"pause"];
    [_downloadModel stop];
}

- (void)resume {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"pause"];
    [_downloadModel resume];
    [self go2Download];
}

- (BOOL)isPaused {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"pause"] boolValue];
}

- (void)didFileDownloaded:(NSString*)path tag:(NSInteger)tag validator:(id)validator {
    if (_waitingDownloadChapter.count > 0) {
        NSDictionary * dic = [_waitingDownloadChapter objectAtIndex:0];
        
        NSMutableDictionary * chaptdic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [chaptdic setObject:[NSNumber numberWithInt:DownloadState_Complete] forKey:@"downloadState"];
        
        NSInteger index = [_allChapters indexOfObject:dic];
        if (index == NSNotFound) {
            [_allChapters addObject:chaptdic];
        }else {
            [_allChapters replaceObjectAtIndex:index withObject:chaptdic];
        }
        
        index = [_hasDownloadesChapters indexOfObject:dic];
        if (index == NSNotFound) {
            [_hasDownloadesChapters insertObject:chaptdic atIndex:0];
        }else {
            [_hasDownloadesChapters replaceObjectAtIndex:index withObject:chaptdic];
        }
        
        @synchronized(_waitingDownloadChapter){
            [_waitingDownloadChapter removeObjectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Update object:nil];
            [self go2Download];
        }
    }
}

- (void)didFileDownloadReceiveBytes:(long long)bytes {
//    NSLog(@"%lld",bytes);
    
    /*
     http://ziyue.tv/file/video/ch_id/152951/token/5273021160b4c.html -- d73de3aaeea590dccbefa0bb80c85675
     http://ziyue.tv/file/video/ch_id/152954/token/5273021160e3e.html -- 0f7a066f3ea78bc24e7e3400c88bf023
     
     http://ziyue.tv/file/video/ch_id/152951/token/5273021160b4c.html -- d73de3aaeea590dccbefa0bb80c85675
     http://ziyue.tv/file/video/ch_id/152953/token/5273021160cfd.html -- 4bcd6a369e34f35c3f3091c8ef0963b6
     
     http://ziyue.tv/file/video/ch_id/152951/token/5273021160b4c.html -- d73de3aaeea590dccbefa0bb80c85675
     */
}

- (void)didFileDownLoadedFailed:(int)tag {
    NSLog(@"file download failed");
//    [self stop];
//    [[NSNotificationCenter defaultCenter] postNotificationName:K_Download_Notification_Finished object:nil];

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
            NSDictionary * dic = [NSDictionary dictionaryWithObjects:
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
            NSDictionary * dic = [NSDictionary dictionaryWithObjects:
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
