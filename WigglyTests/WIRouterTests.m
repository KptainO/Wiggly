//
// This file is part of Wiggly project
//
// Created by JC on 06/09/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <SenTestingKit/SenTestingKit.h>

#import "WIRouter.h"
#import "WIRoute.h"

@interface WIRouterTests : SenTestCase
@property(nonatomic, strong)WIRouter    *router;
@end

@implementation WIRouterTests

- (void)setUp {
    WIRoute *route = [[WIRoute alloc] initWithPath:@"/slash/:titan"];
    self.router = [[WIRouter alloc] initWithRoute:route];
}

- (void)tearDown {
    self.router = nil;
}

- (void)testRoute {
    STAssertEqualObjects([self.router route:@{ @"titan": @"3" }], @"/slash/3", nil);
}

- (void)testMatch {
    STAssertEqualObjects([self.router match:@"/slash/3"], @{@"titan": @"3"}, nil);
}

@end
