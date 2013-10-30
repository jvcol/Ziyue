

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"


@interface HDBHelper : NSObject

+(HDBHelper*)instance;
+(void) closeDatabase;
+(BOOL) openDataBase;
+(void) dropDataBase;

+ (FMDatabase*)aloneDatabase;
+(FMDatabase *) shareDataBase;
+ (FMDatabaseQueue*)aloneQueue;
+ (FMDatabaseQueue*)shareQueue;

@end
