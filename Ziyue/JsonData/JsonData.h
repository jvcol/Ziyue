//
//  JsonData.h
//  VenusIphone
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JsonData : NSObject {

}

@property(assign, nonatomic) NSObject* node;
@property(assign, nonatomic) BOOL valid;

+ (NSString*)jsonStringForObj:(id)obj;
- (id)initWithObject : (NSObject*)obj;
- (id)initWithString : (NSString*)str;
- (JsonData*)dataFor : (NSString*)path;
- (NSInteger)intValue:(NSString*)path;
- (NSString*) strValue:(NSString*)path;
- (NSInteger)intValue:(NSString*)path default:(NSInteger)defValue;
- (NSString*) strValue:(NSString*)path default:(NSString*)defValue;
- (NSDictionary*) dictValue:(NSString*)path;
- (NSArray*) arrayValue:(NSString*)path;

//Usage:
//JsonData * jsonData = [[[JsonData alloc] initWithObject:jsonObject] autorelease];
//NSString* a = [[jsonData dataFor:@"data.a@1.name"] strValue:@"test"];

@end

