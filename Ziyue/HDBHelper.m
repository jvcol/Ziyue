

#import "HDBHelper.h"
#import "FMDatabase.h"

#define MAIN_DATABASE_NAME  @"zymedia.db"
static FMDatabase *theDataBase = nil;

@implementation HDBHelper

+(HDBHelper*)instance {
    static HDBHelper* mgr = nil;
    @synchronized(self) {
        if (mgr == nil)
            mgr = [[[self class] alloc] init];
    }
    return mgr;
}

+ (FMDatabase*)aloneDatabase {
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    FMDatabase* theDataBase =  [FMDatabase databaseWithPath:dbpath];
    return theDataBase;
}

+ (FMDatabaseQueue*)aloneQueue {
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    FMDatabaseQueue* queue = [FMDatabaseQueue databaseQueueWithPath:dbpath];
    return queue;
}

+ (FMDatabaseQueue*)shareQueue {
    static FMDatabaseQueue* queue = nil;
    @synchronized(self) {
        if (queue == nil)
            queue = [[self class] aloneQueue];
    }
    return queue;
}

+(FMDatabase *) shareDataBase {
    @synchronized(self)
    {
        if(theDataBase == nil)
        {
            NSString* docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString* dbpath = [docsdir stringByAppendingPathComponent:MAIN_DATABASE_NAME];
            theDataBase = [FMDatabase databaseWithPath:dbpath];
        }
        [theDataBase open];
    }
    return theDataBase;
}

+(void) dropDataBase
{
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    NSError *error = nil;
    if([[NSFileManager defaultManager] removeItemAtPath:dbpath error:&error])
    {
    }
}

+(BOOL) openDataBase
{
    if(theDataBase == nil)
        [self shareDataBase];
    if(![theDataBase open])
    {
        NSLog(@"open");
        return NO;
        
    }
    return YES;
    
}
+(void) closeDatabase
{
    if(theDataBase)
        if(![theDataBase close])
        {
        }
}

@end
