
#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "JsonData.h"
#import "Utility.h"

#define BaseUrl @"http://ziyue.tv/api/"
#define Request_Url_GetCoursesList [NSString stringWithFormat:@"%@course/index", BaseUrl]
#define Request_Url_GetCourseInfo [NSString stringWithFormat:@"%@course/view?", BaseUrl]


#define UserOperationType @"dragDown"

@protocol NetModelDelegate <NSObject>
@optional
- (void)apiSuccessedWithDictionary:(NSDictionary *)dictionary ForApi:(NSString *)api;
- (void)apiFailed:(NSDictionary *)dictionary WithMsg:(NSString *)msg;

@end

@class ASIHTTPRequest;
@class ASINetworkQueue;
@class ASIFormDataRequest;
@class JsonData;

@interface NetModel : NSObject{
    ASINetworkQueue *_networkQueue;
}
@property(nonatomic,assign)id delegate;
@property(nonatomic,retain)ASINetworkQueue *networkQueue;

- (ASIFormDataRequest*)beginRequest:(NSString*)api; // POST

- (ASIHTTPRequest *)beginGetRequest:(NSString *)api; // GET

- (void)endRequest:(ASIHTTPRequest*)request;

- (void)cancelAllOperations;

@end
