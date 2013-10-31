

#import <Foundation/Foundation.h>


@protocol DownloadModelDelegate <NSObject>

- (void)didFileDownloaded:(NSString*)path tag:(NSInteger)tag validator:(id)validator;
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

- (void)downloadNetMediaWithUrl:(NSString*)fullUrl tag:(int)tag validator:(id)validator;


@end
