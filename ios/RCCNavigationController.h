#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>

@interface RCCNavigationController : UINavigationController

@property (copy, nonatomic) id navigatorEventID;

- (instancetype)initWithProps:(NSDictionary *)props children:(NSArray *)children globalProps:(NSDictionary*)globalProps bridge:(RCTBridge *)bridge;
- (void)performAction:(NSString*)performAction actionParams:(NSDictionary*)actionParams bridge:(RCTBridge *)bridge;

@end
