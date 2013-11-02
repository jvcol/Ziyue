//
//  NSDictionary+ValuePath.h
//  Aloha
//
//  Created by Joe on 12-9-19.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ValuePath)
- (NSInteger)intValue:(NSString*)path;
- (long long)longValue:(NSString*)path;
- (float)floatValue:(NSString*)path;
- (NSString*)strValue:(NSString*)path;
- (NSInteger)intValue:(NSString*)path default:(NSInteger)defValue;
- (float)floatValue:(NSString*)path default:(float)defValue;
- (NSString*)strValue:(NSString*)path default:(NSString*)defValue;
-(NSArray *) arrayValue :(NSString *) path;
@end


