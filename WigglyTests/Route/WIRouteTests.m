//
// This file is part of  Wiggly project
//
// Created by JC on 06/16/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <SenTestingKit/SenTestingKit.h>

#import "WIRoute.h"
#import "WIRouteConstraintURL.h"

@interface WIRouteTests : SenTestCase
@property(nonatomic, strong)WIRoute *route;
@end

@implementation WIRouteTests

- (void)setUp {
  self.route = [[WIRoute alloc] initWithPath:@"/root"];
}

- (void)tearDown {
  self.route = nil;
}

- (void)testMerge {
  WIRouteConstraintURL *constraint = [[WIRouteConstraintURL alloc] init];
  
  constraint.path = @"/prefix";
  
  [self.route merge:constraint];
  
  STAssertEqualObjects(self.route.path, @"/prefix/root", nil);
}

@end
