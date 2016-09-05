//
//  UIViewController+NavBarButtons.h
//  ReactNativeControllers
//
//  Created by Pavlo Aksonov on 11/08/16.
//  Copyright © 2016 artal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(NavBarButtons)
@property (copy, nonatomic) NSString *navigatorID;
@property (copy, nonatomic) NSDictionary *parentStyle;
-(void)setButtons:(NSArray*)buttons side:(NSString*)side animated:(BOOL)animated;
-(void)setTitleImage:(id)titleImageData;
-(void)onPop;
-(BOOL)shouldPop;
-(void)setProps:(NSDictionary *)props;
-(void)onButtonPress:(UIBarButtonItem*)barButtonItem;
@end
