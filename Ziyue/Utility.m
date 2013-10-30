//
//  Utility.m
//  Ziyue
//
//  Created by yangw on 13-10-26.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "Utility.h"
#import <CommonCrypto/CommonDigest.h>

NSString * getTimeStr(int timeStamp) {
    int hour = 0;
    int minute = 0;
    int second = 0;
    if (timeStamp < 60) {
        return [NSString stringWithFormat:@"%d秒",timeStamp];
    }else if (timeStamp < 60*60) {
        minute = timeStamp/60;
        second = timeStamp%60;
        return [NSString stringWithFormat:@"%d分%d秒",minute,second];
    }else {
        second = timeStamp%60;
        hour = timeStamp/3600;
        minute = timeStamp - hour*3600+second;
        return [NSString stringWithFormat:@"%d小时%d分%d秒",hour,minute,second];
    }
    return nil;
}

BOOL hdEnsurePath(NSString* path) {
    if ([path length] == 0)
        return FALSE;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        NSString* parentPath = [path stringByDeletingLastPathComponent];
        if (hdEnsurePath(parentPath)) {
            NSError* error = nil;
            return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        } else {
            return FALSE;
        }
    }
    return TRUE;
}

@implementation NSString(encoding)
- (NSString*)md5 {
    
    
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}
- (NSString *)encodeString:(NSStringEncoding)encoding
{
    NSString *enString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                              NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                              CFStringConvertNSStringEncodingToEncoding(encoding))) ;
    return enString;
    
    
}

@end


@implementation Utility

- (void)function {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    }
}

- (void)dealloc {
    
}

@end
