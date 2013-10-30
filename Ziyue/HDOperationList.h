

#import <Foundation/Foundation.h>

typedef enum {
    NSBlockReturnTypeManual,
    NSBlockReturnTypeAutomatic,
} NSBlockReturnType;

typedef NSBlockReturnType (^NSBlockOperationBlock)();

@interface NSBlockOperationItem : NSObject

@property (nonatomic, copy) NSBlockOperationBlock block;

@end

@interface HDOperationList : NSThread {
    NSMutableArray* _blocks;
    NSCondition *_cond, *_next;
    NSLock* _mtx;
}

- (void)clear;
- (void)addBlock:(NSBlockOperationBlock)block;
- (NSUInteger)count;
- (void)setSuspended:(BOOL)b;

@end
