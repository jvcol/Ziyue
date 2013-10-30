
#import "ASINetworkQueue.h"
#import "NetModel.h"
#import "Utility.h"

#define API_REQUEST     0

@interface NetModel (Private)

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request;
- (void)dataRequestFailed:(ASIHTTPRequest *)request;

- (void)dispatchSuccessed:(JsonData*) data forApi:(NSString*)api;
- (void)dispatchFailed:(NSInteger)errNo withMsg:(NSString*)msg forApi:(NSString*)api;

@end


@implementation NetModel

@synthesize delegate;
@synthesize networkQueue = _networkQueue;

-(id) init {
    self = [super init];
    if (self) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue reset];
        [_networkQueue setDownloadProgressDelegate:self];
        [_networkQueue setRequestDidFinishSelector:@selector(dataRequestSuccessed:)];
        [_networkQueue setRequestDidFailSelector:@selector(dataRequestFailed:)];
        [_networkQueue setDelegate:self];
    }
    return self;
}


- (ASIFormDataRequest*)beginRequest:(NSString*)api {
    NSURL *url = [NSURL URLWithString:api];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setUserAgent:CLIENT_AGENT];
    [request setUserInfo:[NSDictionary dictionaryWithObject:api forKey:@"api"]];
    [request setTimeOutSeconds:10];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
    return request;
}

- (ASIHTTPRequest *)beginGetRequest:(NSString *)api {
    NSURL *url = [NSURL URLWithString:api];
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setUserAgent:CLIENT_AGENT];
    [request setUserInfo:[NSDictionary dictionaryWithObject:api forKey:@"api"]];
    [request setTimeOutSeconds:10];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
    return request;
}

- (void)endRequest:(ASIHTTPRequest*)request {
    [_networkQueue addOperation:request];
    if ([_networkQueue requestsCount] == 1) {
        [_networkQueue go];
    }
}



- (void)cancelAllOperations
{
    [_networkQueue cancelAllOperations];
}

- (void)dataRequestSuccessed:(ASIHTTPRequest *)request {

    NSString *api = [request.userInfo objectForKey:@"api"];
    id dragDown = [request.userInfo objectForKey:UserOperationType];

    JsonData *jsonData = [[JsonData alloc] initWithString:[request responseString]];
    NSInteger code = [jsonData intValue:@"code" default:-1];
    if (code == 0) {
        NSDictionary *dict = [jsonData dictValue:nil];
        [dict setValue:dragDown forKey:UserOperationType];
        if(delegate && [delegate respondsToSelector:@selector( apiSuccessedWithDictionary:ForApi:)])
        {
            [delegate performSelector:@selector(apiSuccessedWithDictionary:ForApi:) withObject:dict withObject:api];
        }
    } else {
        NSString *msg;
        if (jsonData.valid)
            msg = [jsonData strValue:@"message" default:nil];
        else
            msg = NSLocalizedString(@"Unkown error", @"Unkown error");
        
        if (delegate && [delegate respondsToSelector:@selector(apiFailed:WithMsg:)]) {
            [delegate performSelector:@selector(apiFailed:WithMsg:) withObject:[jsonData dictValue:nil] withObject:msg];
        }
    }
}

- (void)dataRequestFailed:(ASIHTTPRequest *)request {
    NSString *message = @"erro";
        
    id class = [request.userInfo objectForKey:@"class"];
    if (class) {
        if ([delegate respondsToSelector:@selector(apiFailed:WithMsg:)]) {
            [delegate performSelector:@selector(apiFailed:WithMsg:) withObject:class withObject:message];
        }
    }
}

@end
