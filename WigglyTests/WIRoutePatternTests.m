//
// This file is part of Wiggly project
//
// Created by JC on 03/30/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//
#import <SenTestingKit/SenTestingKit.h>

#import "WIRoute.h"
#import "WIRoutePattern.h"

@interface WIRoutePatternTests : SenTestCase
@end

@implementation WIRoutePatternTests

- (void)testWithPlaceholder {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(pattern.pattern, @"/blog/\\d+", nil);
}

- (void)testWithTwoPlaceholders {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page/:id"
                                   requirements:@{@"page": @"\\w+", @"id": @"[0-9]"}
                                       defaults:nil];

  STAssertEqualObjects(pattern.pattern, @"/blog/\\w+/[0-9]", nil);
}

- (void)testWithTrailingBackslash {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page/"
                                   requirements:@{@"page": @"[0-9]{1,2}"}
                                       defaults:nil];

  STAssertEqualObjects(pattern.pattern, @"/blog/[0-9]{1,2}/", nil);
}

- (void)testWithStaticTextAtTheEnd {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page/show"
                                   requirements:@{@"page" : @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(pattern.pattern, @"/blog/\\d+/show", nil);
}

- (void)testWithOptionalPlaceholderAtTheEnd {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:@{@"page": @"1"}];

  STAssertEqualObjects(pattern.pattern, @"/blog(/\\d+)?", nil);
}

- (void)testWithRequiredAndOptionalPlaceholderAtTheEnd {
  WIRoutePattern *pattern = [self _routePattern:@"/blog/:page/show/:id/and/:foo"
                                   requirements:@{@"page" : @"\\d+", @"id": @"\\d+", @"foo": @"\\d+"} defaults:@{@"foo": @1, @"id": @2}];
  STAssertEqualObjects(pattern.pattern, @"/blog/\\d+/show/\\d+/and(/\\d+)?", nil);
}

- (void)testWithOptionalPlaceholdersNotAtTheEnd {
  WIRoutePattern  *pattern = [self _routePattern:@"/blog/:page/show/:id/last"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(pattern.pattern, @"/blog/\\d+/show/\\d+/last", nil);
}

- (void)testWithStaticTextBetweenTwoOptionalPlaceholders {
  WIRoutePattern  *pattern = [self _routePattern:@"/blog/:page/show/:id"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(pattern.pattern, @"/blog/\\d+/show(/\\d+)?", nil);
}

- (WIRoutePattern *)_routePattern:(NSString *)path
                     requirements:(NSDictionary *)requirements
                         defaults:(NSDictionary *)defaults {
  WIRoute *route = [WIRoute routeWithPath:path];

  for (id requirement in requirements)
    route.requirements[requirement] = requirements[requirement];

  for (id def in defaults)
    route.defaults[def] = defaults[def];

  return [[WIRoutePattern alloc] initWithRoute:route];
}

@end
