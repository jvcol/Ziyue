

#import "DownloadModel.h"
#import "ASIHTTPRequest.h" // get
#import "ASINetworkQueue.h"
#import "Utility.h"

//#import "HDChannelDConfig.h"

@interface DownloadModel () <ASIProgressDelegate> {
    ASINetworkQueue *networkQueue;
}

@end

@implementation DownloadModel {
    
}

-(id) init {
    self = [super init];
    if (self) {
        networkQueue = [[ASINetworkQueue alloc] init];
        [networkQueue reset];
        [networkQueue setDownloadProgressDelegate:self];
        [networkQueue setShowAccurateProgress:YES];
        [networkQueue setRequestDidFinishSelector:@selector(dataRequestSuccessed:)];
        [networkQueue setRequestDidFailSelector:@selector(dataRequestFailed:)];
        [networkQueue setDelegate:self];
        
    }
    return self;
}

- (void)dealloc {
    [networkQueue cancelAllOperations];
    [networkQueue reset];
}

- (void)stop {
	[networkQueue cancelAllOperations];
    [networkQueue reset];
}

- (void)resume {
    [networkQueue reset];
	[networkQueue setDownloadProgressDelegate:self];
    [networkQueue setShowAccurateProgress:YES];
	[networkQueue setRequestDidFinishSelector:@selector(dataRequestSuccessed:)];
	[networkQueue setRequestDidFailSelector:@selector(dataRequestFailed:)];
	[networkQueue setDelegate:self];
}

- (void)downloadNetMediaWithUrl:(NSString *)fullUrl tag:(int)tag fileName:(NSString *)fileName {
    NSURL *url = [NSURL URLWithString:fullUrl];
    
    NSString * str = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    str = [str stringByAppendingPathComponent:DownloadFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:str])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:str
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    NSString * path = [str stringByAppendingPathComponent:fileName];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
    [request setShowAccurateProgress:YES];
    [request setDownloadProgressDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    
    [request setUserAgent:CLIENT_AGENT];
    [request setUserInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:path, fullUrl,[NSNumber numberWithInt:tag],fileName, nil] forKeys:[NSArray arrayWithObjects:@"path",@"fullurl", @"tag",@"filename", nil]]];
//    if (!hdEnsurePath([path stringByDeletingLastPathComponent]))
//        return;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) {
		[self fileDownloaded:request.userInfo forType:tag];
        return;
	}
    [request setDownloadDestinationPath:path];
    
    [request setTimeOutSeconds:30];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [networkQueue addOperation:request];
    if ([networkQueue requestsCount] == 1) {
        [networkQueue go];
    }


}

- (void)setProgress:(float)newProgress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateProcess:)]) {
        [self.delegate updateProcess:newProgress];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
//    NSLog(@"receive : %lld",bytes);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFileDownloadReceiveBytes:)]) {
        [self.delegate didFileDownloadReceiveBytes:bytes];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength {
//    NSLog(@"total : %lld",newLength);
}

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request {
    NSDictionary *dict = request.userInfo;
    [self fileDownloaded:dict forType:request.tag];

}

- (void)dataRequestFailed:(ASIHTTPRequest *)request {
    NSInteger tag = [[request.userInfo objectForKey:@"tag"] intValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFileDownLoadedFailed:)]) {
        [self.delegate didFileDownLoadedFailed:tag];
    }

}

- (void)fileDownloaded:(NSDictionary*)userInfo forType:(NSInteger)fileType {
    NSString *path = [userInfo objectForKey:@"path"];
    NSInteger tag = [[userInfo objectForKey:@"tag"] intValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFileDownloaded:tag:)]) {
        [self.delegate didFileDownloaded:path tag:tag];
    }
}

@end
