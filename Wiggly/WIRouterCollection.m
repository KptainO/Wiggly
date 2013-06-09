//
// This file is part of  Wiggly project
//
// Created by JC on 06/08/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouterCollection.h"

#import "WIRouter.h"
#import "WIRoute.h"
#import "WIRouterCollectionLockedNameException.h"

@interface WIRouterCollection () {
  NSMutableDictionary *routes_;
}

@property(nonatomic, strong)NSMutableArray  *routesOrder_;
@property(nonatomic, strong)NSDictionary    *routes;

@end

@implementation WIRouterCollection

@synthesize routes = routes_;

#pragma mark -
#pragma mark Initialization

+ (id)collection {
  return [[[self class] alloc] init];
}

- (id)init {
  if (!(self = [super init]))
    return nil;
  
  self.routesOrder_ = [NSMutableArray array];
  self.routes = [NSMutableDictionary dictionary];
  
  return self;
}

#pragma mark -
#pragma mark Collection insertion

- (void)add:(NSString *)routeName route:(WIRoute *)route {
  [self add:routeName router:[[WIRouter alloc] initWithRoute:route]];
}

- (void)add:(NSString *)routeName router:(WIRouter *)router {
  if (self.routes[routeName])
    @throw [WIRouterCollectionLockedNameException exceptionWithCollection:self routeName:routeName];
  
  routes_[routeName] = router;
  [self.routesOrder_ addObject:routeName];
}

- (void)add:(WIRouterCollection *)collection {
  for (NSString *routeName in collection)
    [self add:routeName router:collection.routes[routeName]];
}

#pragma mark -
#pragma mark Routing

- (NSString *)route:(NSString *)routeName {
  return [self route:routeName with:nil];
}

- (NSString *)route:(NSString *)routeName with:(id)object; {
  return [self.routes[routeName] route:object];
}

- (id)match:(NSString *)path {
  id result = nil;
  
  for (int i = 0; !result && i < self.routesOrder_.count; ++i)
    result = [self.routes[self.routesOrder_[i]] match:path];
  
  return result;
}

#pragma mark -
#pragma mark FastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
  return [self.routesOrder_ countByEnumeratingWithState:state objects:buffer count:len];
}

@end
