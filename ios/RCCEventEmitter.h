//
//  RCCEventEmitter.h
//  ReactNativeControllers
//
//  Created by Pavlo Aksonov on 10/08/16.
//  Copyright © 2016 artal. All rights reserved.
//

#import "RCTEventEmitter.h"
#import "RCTBridgeModule.h"

@interface RCCEventEmitter : RCTEventEmitter<RCTBridgeModule>

+ (instancetype)sharedInstance;
-(void)startObserving;
-(void)stopObserving;
@property (nonatomic) BOOL isObserving;
- (void)didFocus:(NSString *)callbackId;
- (void)willFocus:(NSString *)callbackId;
- (void)willPop:(NSString *)callbackId;
- (void)willTransition:(NSString *)callbackId;
- (void)didTransition:(NSString *)callbackId;
@end
