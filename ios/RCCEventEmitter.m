//
//  RCCEventEmitter.m
//  ReactNativeControllers
//
//  Created by Pavlo Aksonov on 10/08/16.
//  Copyright © 2016 artal. All rights reserved.
//

#import "RCCEventEmitter.h"
#import "RCTAssert.h"

static RCCEventEmitter *sharedInstance = nil;

@implementation RCCEventEmitter

RCT_EXPORT_MODULE();

-(id)init
{
    self = [super init];
    sharedInstance = self;
    return self;
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

-(void)startObserving {
    _isObserving = YES;
}

-(void)stopObserving {
    _isObserving = NO;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"DidFocus",@"WillFocus", @"NavBarButtonPress",@"WillPop", @"WillTransition", @"DidTransition"];
}

- (void)willFocus:(NSString *)callbackId {
    [self sendEventWithName:@"WillFocus" body:callbackId];
}

- (void)didFocus:(NSString *)callbackId {
    [self sendEventWithName:@"DidFocus" body:callbackId];
}

- (void)willPop:(NSString *)callbackId {
    [self sendEventWithName:@"WillPop" body:callbackId];
}

-(void)willTransition:(NSString *)callbackId side:(NSString *)side percentage:(float)percentage {
    [self sendEventWithName:@"WillTransition" body:@{@"callbackId": callbackId, @"side": side, @"percentage": [NSNumber numberWithFloat:percentage]}];
}

-(void)didTransition:(NSString *)callbackId side:(NSString *)side {
    [self sendEventWithName:@"DidTransition" body:@{@"callbackId": callbackId, @"side": side}];
}

@end
