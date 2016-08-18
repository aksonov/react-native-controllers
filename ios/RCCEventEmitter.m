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

-(void)willTransition:(NSString *)callbackId {
    [self sendEventWithName:@"WillTransition" body:callbackId];
}

-(void)didTransition:(NSString *)callbackId {
    [self sendEventWithName:@"DidTransition" body:callbackId];
}

@end
