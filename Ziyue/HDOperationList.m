

#import "HDOperationList.h"

#define AntiARCRetain(...) void *retainedThing = (__bridge_retained void *)__VA_ARGS__; retainedThing = retainedThing
#define AntiARCRelease(...) void *retainedThing = (__bridge void *) __VA_ARGS__; id unretainedThing = (__bridge_transfer id)retainedThing; unretainedThing = nil

@implementation NSBlockOperationItem

@synthesize block;

@end

@implementation HDOperationList

- (id)init {
    self = [super init];
    _blocks = [[NSMutableArray alloc] init];
    _cond = [[NSCondition alloc] init];
    _next = [[NSCondition alloc] init];
    _mtx = [[NSLock alloc] init];
    return self;
}

- (void)dealloc {
    [self cancel];
    [self clear];
}

- (void)clear {
    [_mtx lock];
    [_blocks removeAllObjects];
    [_mtx unlock];
}

- (void)addBlock:(NSBlockOperationBlock)block {
    [_mtx lock];
    
    NSBlockOperationItem* item = [[NSBlockOperationItem alloc] init];
    item.block = block;
    [_blocks addObject:item];
    
    [_mtx unlock];
    
    [_cond signal];
}

- (NSUInteger)count {
    [_mtx lock];
    NSUInteger ret = _blocks.count;
    [_mtx unlock];
    return ret;
}

- (void)setSuspended:(BOOL)b {
    if (b) {
        [self cancel];
    } else {
        [self start];
    }
}

- (void)next {
    [_next signal];
}

- (void)main {
    while (1) {
        
        [_cond lock];
        if (_blocks.count == 0)
            [_cond wait];
        [_cond unlock];
        
        while (_blocks.count) {
            [_mtx lock];
            
            NSBlockOperationItem* item = [_blocks objectAtIndex:0];
            
            [_mtx unlock];
            
            NSBlockReturnType ret = item.block();
            
            // 移除运行完毕的
            [_mtx lock];
            if (_blocks.count)
                [_blocks removeObjectAtIndex:0];
            [_mtx unlock];
            
            if (ret == NSBlockReturnTypeManual) {
                [_next lock];
                [_next wait];
                [_next unlock];
            }
        }
        
    }
}

@end
