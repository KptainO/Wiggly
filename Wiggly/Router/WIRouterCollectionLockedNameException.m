//
// This file is part of  Wiggly project
//
// Created by JC on 06/09/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouterCollectionLockedNameException.h"

@interface WIRouterCollectionLockedNameException ()
@property(nonatomic, strong)NSString            *routeName;
@property(nonatomic, strong)WIRouterCollection  *routerCollection;
@end

@implementation WIRouterCollectionLockedNameException

#pragma mark -
#pragma mark Initialization

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo {
  CtorNotInherited
}

+ (id)exceptionWithCollection:(WIRouterCollection *)routerCollection routeName:(NSString *)routeName {
  return [[[self class] alloc] initWithCollection:routerCollection routeName:routeName];
}

- (id)initWithCollection:(WIRouterCollection *)routerCollection routeName:(NSString *)routeName {
  NSString *reason = [NSString stringWithFormat:@"route named %@ is already in used inside collection", routeName];
  
  if (!(self = [super initWithName:NSStringFromClass([self class]) reason:reason userInfo:nil]))
    return nil;
  
  self.routerCollection = routerCollection;
  self.routeName = self.routeName;
  
  return self;
}

@end
