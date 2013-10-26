//
//  JsonData.m
//  VenusIphone
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JsonData.h"
#import "SBJson.h"

@interface JsonData (Private)

- (NSObject*)objFor : (NSString*)path;
@end

@implementation JsonData
@synthesize node, valid;


+ (NSString*)jsonStringForObj:(id)obj {
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    return [jsonWriter stringWithObject:obj];
}

- (id)initWithObject : (NSObject*)obj {
    self = [super init];
    if (self) {
        self.node = obj;
    }
    return self;
}

- (id)initWithString : (NSString*)str {
    self = [super init];
    if (self) {
       SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        node = [jsonParser objectWithString:str error:&error];   
        valid = (error == nil) ? TRUE : FALSE;
    }
    return self;
}

- (NSObject*)objFor : (NSString*)path {
    if (path == nil)
        return self.node;
    
    NSArray* fields = [path componentsSeparatedByString:@"."];
    NSObject* obj = node;
    for (int i = 0; i < [fields count]; i++) {
      
        NSString* field = (NSString*)[fields objectAtIndex:i];
        if ([obj isKindOfClass:[NSDictionary class]] && [field length] > 0) {
            NSRange range = [field rangeOfString:@"@"];
            if (range.location != NSNotFound) {
                obj = [(NSDictionary*)obj objectForKey:[field substringToIndex:range.location]];  
                if (!obj)
                    return nil;
                field = [field substringFromIndex:range.location];
            } else {
                obj = [(NSDictionary*)obj objectForKey:field];  
                if (!obj)
                    return nil;
                continue;
            }
        }    
        if ([obj isKindOfClass:[NSArray class]] && [field length] > 0) {
            NSString* flag = [field substringToIndex:1];
            if (![flag isEqualToString:@"@"])
                return nil;
            int seq = [[field substringFromIndex:1] intValue];
            if (seq < 0 || seq > [(NSArray*)obj count])
                return nil;
            obj = [(NSArray*)obj objectAtIndex:seq];
            if (!obj)
                return nil;
            continue;
        }
    }
    return obj;    
}

- (JsonData*)dataFor : (NSString*)path {
    NSObject* obj = [self objFor:path];
    //TODO: check for memory leak problem?
    return [[JsonData alloc] initWithObject:obj];
}

- (NSInteger)intValue:(NSString*)path {
    return [self intValue:path default:0];
}

- (NSString*) strValue:(NSString*)path {
    return [self strValue:path default:nil];
}

- (NSInteger)intValue:(NSString*)path default:(NSInteger)defValue {
    NSObject* obj = [self objFor:path];
    if (!obj)
        return defValue;
    if ([obj isKindOfClass:[NSString class]])
        return [(NSString*)obj intValue];
    else if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj intValue];
    return defValue;
}


- (NSString*) strValue:(NSString*)path default:(NSString*)defValue {
    NSObject* obj = [self objFor:path];
    if (!obj)
        return defValue;
    if ([obj isKindOfClass:[NSString class]])
        return (NSString*)obj;
    else if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber*)obj stringValue];
    return defValue;
}

- (NSDictionary*) dictValue:(NSString*)path {
    NSObject* obj = [self objFor:path];
    if (!obj)
        return nil;
    if ([obj isKindOfClass:[NSDictionary class]])    
        return (NSDictionary*)obj;
    return nil;
}

- (NSArray*) arrayValue:(NSString*)path {
    NSObject* obj = [self objFor:path];
    if (!obj)
        return nil;
    if ([obj isKindOfClass:[NSArray class]])    
        return (NSArray*)obj;
    return nil;
}


@end
