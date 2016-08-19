//
//  UIViewController+NavBarButtons.m
//  ReactNativeControllers
//
//  Created by Pavlo Aksonov on 11/08/16.
//  Copyright © 2016 artal. All rights reserved.
//

#import "UIViewController+NavBarButtons.h"
#import "RCCViewController.h"
#import "RCCNavigationController.h"
#import "RCCTabBarController.h"
#import "RCCDrawerController.h"
#import "RCCTheSideBarManagerViewController.h"
#import "RCTRootView.h"
#import "RCCManager.h"
#import "RCTConvert.h"
#import "RCCExternalViewControllerProtocol.h"
#import "RNCubeController.h"
#import "RCTEventDispatcher.h"
#import "UIBarButtonItem+Badge.h"
#import "RCCEventEmitter.h"
#import <objc/runtime.h>

NSString const *CALLBACK_ASSOCIATED_KEY = @"RCCNavigationController.CALLBACK_ASSOCIATED_KEY";
NSString const *CALLBACK_ASSOCIATED_ID = @"RCCNavigationController.CALLBACK_ASSOCIATED_ID";
NSString const *NAVIGATOR_ID = @"RCCNavigationController.NAVIGATOR_ID";
NSString const *STYLE_KEY = @"RCCViewController.STYLE_KEY";

@implementation UIViewController(NavBarButtons)

-(void)setButtons:(NSArray*)buttons side:(NSString*)side animated:(BOOL)animated
{
    NSMutableArray *barButtonItems = [NSMutableArray new];
    for (NSDictionary *button in buttons)
    {
        NSString *title = button[@"title"];
        UIImage *iconImage = nil;
        id icon = button[@"icon"];
        if (icon) iconImage = [RCTConvert UIImage:icon];
        
        UIBarButtonItem *barButtonItem;
        if (iconImage)
        {
            barButtonItem = [[UIBarButtonItem alloc] initWithImage:iconImage style:UIBarButtonItemStylePlain target:self action:@selector(onButtonPress:)];
        }
        else if (title)
        {
            barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(onButtonPress:)];
        }
        else if ([side isEqualToString:@"back"])
        {
            barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(onButtonPress:)];
        }
        else continue;
        objc_setAssociatedObject(barButtonItem, &CALLBACK_ASSOCIATED_KEY, button[@"onPress"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [barButtonItems addObject:barButtonItem];
        
        NSString *buttonId = button[@"id"];
        if (buttonId)
        {
            objc_setAssociatedObject(barButtonItem, &CALLBACK_ASSOCIATED_ID, buttonId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        NSNumber *disabled = button[@"disabled"];
        BOOL disabledBool = disabled ? [disabled boolValue] : NO;
        if (disabledBool) {
            [barButtonItem setEnabled:NO];
        }
        
        NSNumber *disableIconTintString = button[@"disableIconTint"];
        BOOL disableIconTint = disableIconTintString ? [disableIconTintString boolValue] : NO;
        if (disableIconTint) {
            [barButtonItem setImage:[barButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        
        NSString *testID = button[@"testID"];
        if (testID)
        {
            barButtonItem.accessibilityIdentifier = testID;
        }
        
        if ([side isEqualToString:@"left"])
        {
            self.navigationItem.leftBarButtonItems = nil;
            [self.navigationItem setLeftBarButtonItem:barButtonItems[0] animated:animated];
        }
        
        if ([side isEqualToString:@"right"])
        {
            self.navigationItem.rightBarButtonItems = nil;
            [self.navigationItem setRightBarButtonItem:barButtonItems[0] animated:animated];
        }
        
        
        NSString *badgeValue = button[@"badgeValue"];
        if (badgeValue){
            barButtonItem.badgeValue = badgeValue;
            self.navigationItem.rightBarButtonItem.badgeValue = badgeValue;
        }
        NSString *badgeColor = button[@"badgeBGColor"];
        if (badgeColor){
            barButtonItem.badgeBGColor = [RCTConvert UIColor:badgeColor];
        }
        float badgeMinSize = [button[@"badgeMinSize"] floatValue];
        if (badgeMinSize){
            barButtonItem.badgeMinSize = badgeMinSize;
        }
        float badgeFontSize = [button[@"badgeFontSize"] floatValue] || 13.0f;
        NSString *badgeFontFamily = button[@"badgeFontFamily"];
        if (badgeFontFamily){
            barButtonItem.badgeFont = [UIFont fontWithName:badgeFontFamily size:badgeFontSize];
        }
        
        NSString *navBarTextColor = button[@"textColor"];
        if (!navBarTextColor){
            navBarTextColor = self.parentStyle[@"navBarButtonColor"];
        }
        NSString *navBarFontFamily = button[@"fontFamily"];
        if (!navBarFontFamily){
            navBarFontFamily = self.parentStyle[@"navBarFontFamily"];
        }
        float navBarFontSize = [button[@"navBarFontSize"] floatValue];
        if (!navBarFontSize){
            navBarFontSize = [self.parentStyle[@"navBarButtonFontSize"] floatValue];
        }
        NSDictionary *s = self.parentStyle;
        if (navBarTextColor || navBarFontFamily)
        {
            NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
            if (navBarTextColor)
            {
                UIColor *color = navBarTextColor != (id)[NSNull null] ? [RCTConvert UIColor:navBarTextColor] : nil;
                [attributes setValue:color forKey:NSForegroundColorAttributeName];
            }
            
            if (navBarFontFamily)
            {
                if (!navBarFontSize)
                {
                    navBarFontSize = 15.0f;
                }
                UIFont *font = [UIFont fontWithName:navBarFontFamily size:navBarFontSize];
                [attributes setValue:font forKey:NSFontAttributeName];
            }
            
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        if (button[@"disabledTextColor"]){
            NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
            [attributes setValue:[RCTConvert UIColor:button[@"disabledTextColor"]] forKey:NSForegroundColorAttributeName];
            [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
        }
        if ([button[@"disabled"] boolValue]){
            barButtonItem.enabled = NO;
        } else {
            barButtonItem.enabled = YES;
        }
    }
    if (!barButtonItems.count){
        if ([side isEqualToString:@"left"])
        {
            [self.navigationItem setLeftBarButtonItems:barButtonItems animated:animated];
        }
        
        if ([side isEqualToString:@"right"])
        {
            [self.navigationItem setRightBarButtonItems:barButtonItems animated:animated];
        }
        
    }
}



-(void)setTitleImage:(id)titleImageData
{
    if (!titleImageData || [titleImageData isEqual:[NSNull null]])
    {
        self.navigationItem.titleView = nil;
        return;
    }
    
    UIImage *titleImage = [RCTConvert UIImage:titleImageData];
    if (titleImage)
    {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleImage];
    }
}

-(void)onPop
{
    [[RCCEventEmitter sharedInstance] willPop:self.navigatorID];
}

-(void)setProps:(NSDictionary *)props {
    RCTRootView *view = (RCTRootView *)self.view;
    if (props[@"title"]){
        self.title = props[@"title"];
    }
    if ([props[@"rightButtonDisabled"] boolValue]){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if ([props[@"leftButtonDisabled"] boolValue]){
        self.navigationItem.leftBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    if ([view respondsToSelector:@selector(appProperties)]){
        view.appProperties = props;
    }
}

-(void)onButtonPress:(UIBarButtonItem*)barButtonItem
{
    NSString *callbackId = objc_getAssociatedObject(barButtonItem, &CALLBACK_ASSOCIATED_KEY);
    if (!callbackId) return;
    NSString *buttonId = objc_getAssociatedObject(barButtonItem, &CALLBACK_ASSOCIATED_ID);
    [[[RCCManager sharedInstance] getBridge].eventDispatcher sendAppEventWithName:callbackId body:@
     {
         @"type2": @"NavBarButtonPress",
         @"id": buttonId ? buttonId : [NSNull null]
     }];
    
}

-(NSString *)navigatorID {
    return objc_getAssociatedObject(self, &NAVIGATOR_ID);
}

-(void)setNavigatorID:(NSString *)ident {
    objc_setAssociatedObject(self, &NAVIGATOR_ID, ident, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setParentStyle:(NSDictionary *)style {
    objc_setAssociatedObject(self, &STYLE_KEY, style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    for (int i=0;i<[self.childViewControllers count];i++){
        NSMutableDictionary *mergedStyle = [NSMutableDictionary dictionaryWithDictionary:style];
        // there are a few styles that we don't want to remember from our parent (they should be local)
//        [mergedStyle removeObjectForKey:@"navBarHidden"];
//        [mergedStyle removeObjectForKey:@"statusBarHidden"];
//        [mergedStyle removeObjectForKey:@"navBarHideOnScroll"];
//        [mergedStyle removeObjectForKey:@"drawUnderNavBar"];
//        [mergedStyle removeObjectForKey:@"drawUnderTabBar"];
//        [mergedStyle removeObjectForKey:@"statusBarBlur"];
//        [mergedStyle removeObjectForKey:@"navBarBlur"];
//        [mergedStyle removeObjectForKey:@"navBarTransparent"];
//        [mergedStyle removeObjectForKey:@"navBarTranslucent"];
//        [mergedStyle removeObjectForKey:@"statusBarHideWithNavBar"];
        
        [self.childViewControllers[i] setParentStyle:style];
    }
}

-(NSDictionary *)parentStyle {
    return objc_getAssociatedObject(self, &STYLE_KEY);
}

@end
