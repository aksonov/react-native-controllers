#import "RCCNavigationController.h"
#import "RCCViewController.h"
#import "RCCManager.h"
#import "RCTEventDispatcher.h"
#import "RCTConvert.h"
#import "RCTRootView.h"
#import "UIBarButtonItem+Badge.h"
#import "UIViewController+NavBarButtons.h"
#import <objc/runtime.h>

@interface RCCNavigationController() {
  NSArray *_children;
  NSDictionary*_globalProps;
  RCTBridge *_bridge;
  BOOL popAction;
}


@end
@implementation RCCNavigationController

- (instancetype)initWithProps:(NSDictionary *)props children:(NSArray *)children globalProps:(NSDictionary*)globalProps bridge:(RCTBridge *)bridge
{
  _globalProps = globalProps;
  _bridge = bridge;
  NSString *component = props[@"component"];
  NSDictionary *passProps = props[@"passProps"];
  NSDictionary *navigatorStyle = props[@"style"];
  
  RCCViewController *viewController;
  
  if (!component) {
    if ([children count] < 1) return nil;
    _children = children;
    viewController = [RCCViewController controllerWithLayout:children[0] globalProps:globalProps bridge:bridge];
  } else {
    viewController = [[RCCViewController alloc] initWithComponent:component passProps:passProps navigatorStyle:navigatorStyle globalProps:globalProps bridge:bridge];
  }
  
  self = [super initWithRootViewController:viewController];
  if (!self) return nil;
  
  self.navigationBar.translucent = NO; // default
  
  if (navigatorStyle[@"navBarHidden"]){
    self.navigationBar.hidden = YES;
  }
  
  return self;
}

- (void)performAction:(NSString*)performAction actionParams:(NSDictionary*)actionParams bridge:(RCTBridge *)bridge
{
  BOOL animated = actionParams[@"animated"] ? [actionParams[@"animated"] boolValue] : YES;
  
  // setTitle
  if ([performAction isEqualToString:@"setTitle"])
  {
    NSString *title = actionParams[@"title"];
    if (title) [self topViewController].title = title;
    return;
  }
  
  if ([performAction isEqualToString:@"setTitleImage"])
  {
    [[self topViewController] setTitleImage:actionParams[@"titleImage"]];
    return;
  }
  
  // push
  if ([performAction isEqualToString:@"push"])
  {
    NSString *component = actionParams[@"component"];
    RCCViewController *viewController;
    if (!component) {
      NSString *ident = actionParams[@"id"];
      if (!ident) return;
      for (int i=0;i<[self.viewControllers count];i++){
        if ([self.viewControllers[i].navigatorID isEqualToString:ident]){
          NSLog(@"DOUBLE PUSH, IGNORE: %@", ident);
          return;
        }
      }
      RCCViewController *parent = (RCCViewController*)self.topViewController;
      for (int i=0;i<[_children count];i++){
        if ([_children[i] isEqual:[NSNull null]]){
          continue;
        }
        if ([_children[i][@"props"][@"id"] isEqualToString:ident]){
          viewController = [RCCViewController controllerWithLayout:_children[i] globalProps:_globalProps bridge:_bridge];
          if ([viewController respondsToSelector:@selector(setProps:)]){
            [viewController setProps:actionParams[@"passProps"]];
          }
          [viewController setParentStyle:parent.navigatorStyle];
          [viewController setParentStyle:parent.parentStyle];
          break;
        }
      }
    } else {
    
    NSDictionary *passProps = actionParams[@"passProps"];
    NSDictionary *navigatorStyle = actionParams[@"style"];
    
    // merge the navigatorStyle of our parent
    if ([self.topViewController isKindOfClass:[RCCViewController class]])
    {
      RCCViewController *parent = (RCCViewController*)self.topViewController;
      NSMutableDictionary *mergedStyle = [NSMutableDictionary dictionaryWithDictionary:parent.navigatorStyle];
      
      // there are a few styles that we don't want to remember from our parent (they should be local)
      [mergedStyle removeObjectForKey:@"navBarHidden"];
      [mergedStyle removeObjectForKey:@"statusBarHidden"];
      [mergedStyle removeObjectForKey:@"navBarHideOnScroll"];
      [mergedStyle removeObjectForKey:@"drawUnderNavBar"];
      [mergedStyle removeObjectForKey:@"drawUnderTabBar"];
      [mergedStyle removeObjectForKey:@"statusBarBlur"];
      [mergedStyle removeObjectForKey:@"navBarBlur"];
      [mergedStyle removeObjectForKey:@"navBarTranslucent"];
      [mergedStyle removeObjectForKey:@"statusBarHideWithNavBar"];
      
      [mergedStyle addEntriesFromDictionary:navigatorStyle];
      navigatorStyle = mergedStyle;
    }
    
    viewController = [[RCCViewController alloc] initWithComponent:component passProps:passProps navigatorStyle:navigatorStyle globalProps:nil bridge:bridge];
    }
    [self pushViewController:viewController animated:animated];
    return;
  }
  popAction = NO;
  
  // pop
  if ([performAction isEqualToString:@"pop"])
  {
    popAction = YES;
    [self popViewControllerAnimated:animated];
    return;
  }
  
  // popToRoot
  if ([performAction isEqualToString:@"popToRoot"])
  {
    [self popToRootViewControllerAnimated:animated];
    return;
  }
  
  // resetTo
  if ([performAction isEqualToString:@"resetTo"])
  {
    NSString *component = actionParams[@"component"];
    if (!component) return;
    
    NSDictionary *passProps = actionParams[@"passProps"];
    NSDictionary *navigatorStyle = actionParams[@"style"];
    
    RCCViewController *viewController = [[RCCViewController alloc] initWithComponent:component passProps:passProps navigatorStyle:navigatorStyle globalProps:nil bridge:bridge];
    
    BOOL animated = actionParams[@"animated"] ? [actionParams[@"animated"] boolValue] : YES;
    
    [self setViewControllers:@[viewController] animated:animated];
    return;
  }
  
  // setNavigatorEventID
  if ([performAction isEqualToString:@"setNavigatorEventID"])
  {
    self.navigatorEventID = actionParams[@"navigatorEventID"];
    return;
  }
  
  if ([performAction isEqualToString:@"setStyle"]){
    [self setParentStyle:actionParams];
    [[self topViewController] setParentStyle:actionParams];
  }
  
  if ([performAction isEqualToString:@"refresh"]){
    [[self topViewController] setProps:actionParams];
  }
  // toggleNavBar
  if ([performAction isEqualToString:@"setHidden"]) {
    NSNumber *animated = actionParams[@"animated"];
    BOOL animatedBool = animated ? [animated boolValue] : YES;
    
    NSNumber *setHidden = actionParams[@"hidden"];
    BOOL isHiddenBool = setHidden ? [setHidden boolValue] : NO;
  
    RCCViewController *topViewController = ((RCCViewController*)self.topViewController);
    topViewController.navigatorStyle[@"navBarHidden"] = setHidden;
    [topViewController setNavBarVisibilityChange:animatedBool];
    
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    RCCViewController* vc = [self topViewController];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (popAction){
      if ([vc respondsToSelector:@selector(onPop)]){
        [vc onPop];
      }
      }
      [self popViewControllerAnimated:YES];
    });
  popAction = NO;
  return YES;
}

@end
