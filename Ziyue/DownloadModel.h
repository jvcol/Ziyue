

#import <Foundation/Foundation.h>


@protocol DownloadModelDelegate <NSObject>

- (void)didFileDownloaded:(NSString*)path tag:(NSInteger)tag;
- (void)didFileDownloadReceiveBytes:(long long)bytes;
- (void)didFileDownLoadedFailed:(int)tag;

@optional
-(void)updateProcess:(float)value;

@end

@interface DownloadModel : NSObject

@property (nonatomic, assign) id <DownloadModelDelegate> delegate;

//
- (void)stop;
- (void)resume;
//

- (void)downloadNetMediaWithUrl:(NSString*)fullUrl tag:(int)tag fileName:(NSString *)fileName;


@end
