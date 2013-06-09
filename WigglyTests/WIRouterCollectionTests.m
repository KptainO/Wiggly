//
// This file is part of  Wiggly project
//
// Created by JC on 06/08/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <SenTestingKit/SenTestingKit.h>

#import "WIRouterCollection.h"
#import "WIRouter.h"
#import "WIRoute.h"
#import "WIRouterCollectionLockedNameException.h"

@interface WIRouterCollectionTests : SenTestCase
@property(nonatomic, strong)WIRouterCollection  *collection;
@property(nonatomic, strong)WIRouter             *root;
@end

@implementation WIRouterCollectionTests

- (void)setUp {
  WIRoute *route = [WIRoute routeWithPath:@"/"];
  
  self.collection = [[WIRouterCollection alloc] init];
  self.root = [[WIRouter alloc] initWithRoute:route];
}

- (void)tearDown {
  self.collection = nil;
  self.root = nil;
}

- (void)testAddRoute {
  STAssertEquals((int)self.collection.routes.count, 0, nil);
  
  [self.collection add:@"root" router:self.root];
  STAssertEquals((int)self.collection.routes.count, 1, nil);
}

- (void)testAddRouteException {
  [self.collection add:@"root" router:self.root];
  STAssertThrowsSpecific([self.collection add:@"root" router:self.root], WIRouterCollectionLockedNameException, nil);
}

- (void)testAddRouteCollection {
  WIRouterCollection *collection = [WIRouterCollection collection];
  
  [collection add:@"root" router:self.root];
  [collection add:@"homepage" route:[WIRoute routeWithPath:@"/home"]];
  
  [self.collection add:collection];
  
  STAssertEquals((int)self.collection.routes.count, 2, nil);
  STAssertEqualObjects(self.collection.routes, collection.routes, nil);
}

- (void)testAddRouteCollectionException {
  WIRouterCollection *collection = [WIRouterCollection collection];
  
  [self.collection add:@"root" router:self.root];
  
  [collection add:@"root" router:self.root];
  STAssertThrowsSpecific([self.collection add:collection], WIRouterCollectionLockedNameException, nil);
}

- (void)testRoute {
  NSString *path = @"/home";
  
  [self.collection add:@"homepage" route:[WIRoute routeWithPath:path]];
  STAssertEqualObjects([self.collection route:@"homepage"], path, nil);
}

- (void)testMatchPriority {
  NSString *path = @"/photo/:id";
  
  // Set 2 routes which are exactly the same but with parameter names different
  // Only first one should match
  [self.collection add:@"photo_show" route:[WIRoute routeWithPath:path]];
  [self.collection add:@"photo" route:[WIRoute routeWithPath:@"/photo/:show"]];
  [self.collection add:@"root" router:self.root];
  
  STAssertEqualObjects([self.collection match:@"/photo/5"], @{@"id": @"5"}, nil);
}

- (void)testMatch2SameRoutesRequirementsDiff {
  NSString *path = @"/photos/:album/:page";
  WIRoute *route1 = [WIRoute routeWithPath:path];
  WIRoute *route2 = [WIRoute routeWithPath:path];
  
  route1.requirements[@"album"] = @"[a-z]+";
  route1.requirements[@"page"] = @"\\d+";
  
  route2.requirements[@"album"] = @"[a-z]+";
  route2.requirements[@"page"] = @"[a-z]+";
  
  [self.collection add:@"route1" route:route1];
  [self.collection add:@"route2" route:route2];
  
  STAssertEqualObjects([self.collection match:@"/photos/animes/3"], (@{ @"album": @"animes", @"page": @"3"}), nil);
  STAssertEqualObjects([self.collection match:@"/photos/animes/snk"], (@{ @"album": @"animes", @"page": @"snk"}), nil);
}


@end
