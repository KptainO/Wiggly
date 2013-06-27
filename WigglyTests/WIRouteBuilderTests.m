//
// This file is part of Wiggly project
//
// Created by JC on 03/30/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//
#import <SenTestingKit/SenTestingKit.h>
#import <Kiwi/Kiwi.h>

#import "WIRoute.h"
#import "WIRouteBuilder.h"
#import "WIRegex.h"
#import "WIRegexSegment.h"

@interface WIRouteBuilderTests : SenTestCase
@end

@implementation WIRouteBuilderTests

- (void)testWithSegment {
  WIRegex *regex = [self _routeRegex:@"/blog/:page"
                        requirements:@{@"page": @"\\d+"}
                            defaults:nil];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\d+)", nil);
}

- (void)testWithTwoSegments {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/:id"
                        requirements:@{@"page": @"\\w+", @"id": @"[0-9]"}
                            defaults:nil];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\w+)/([0-9])", nil);
}

- (void)testWithTrailingBackslash {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/"
                        requirements:@{@"page": @"[0-9]{1,2}"}
                            defaults:nil];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/([0-9]{1,2})/", nil);
}

- (void)testWithStaticTextAtTheEnd {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show"
                        requirements:@{@"page" : @"\\d+"}
                            defaults:nil];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\d+)/show", nil);
}

- (void)testWithOptionalSegmentAtTheEnd {
  WIRegex *regex = [self _routeRegex:@"/blog/:page"
                        requirements:@{@"page": @"\\d+"}
                            defaults:@{@"page": @"1"}];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog(/(\\d+))?", nil);
}

- (void)testWithRequiredAndOptionalSegmentAtTheEnd {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show/:id/and/:foo"
                        requirements:@{@"page" : @"\\d+", @"id": @"\\d+", @"foo": @"\\d+"} defaults:@{@"foo": @1, @"id": @2}];
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\d+)/show/(\\d+)/and(/(\\d+))?", nil);
}

- (void)testWithOptionalSegmentsNotAtTheEnd {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show/:id/last"
                        requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                            defaults:@{@"id": @2}];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\d+)/show/(\\d+)/last", nil);
}

- (void)testWithStaticTextBetweenTwoOptionalSegments {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show/:id"
                        requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                            defaults:@{@"id": @2}];
  
  STAssertEqualObjects(regex.pattern.pattern, @"/blog/(\\d+)/show(/(\\d+))?", nil);
}

- (void)testSegmentsSetAsRequired {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show/:id"
                        requirements:nil
                            defaults:@{@"page": @1, @"id": @1}];
  
  STAssertTrue([regex.segments[0] required], nil);
}

- (void)testSegmentsAllSetAsRequired {
  WIRegex *regex = [self _routeRegex:@"/blog/:page/show/:id/foo"
                        requirements:nil
                            defaults:@{@"page": @1, @"id": @1}];
  
  for (WIRegexSegment *holder in regex.segments)
    STAssertTrue(holder.required, @"'%@' holder is not set to required", holder.name);
}



- (WIRegex *)_routeRegex:(NSString *)path
            requirements:(NSDictionary *)requirements
                defaults:(NSDictionary *)defaults {
  WIRoute *route = [WIRoute routeWithPath:path];
  
  for (id requirement in requirements)
    route.requirements[requirement] = requirements[requirement];
  
  for (id def in defaults)
    route.defaults[def] = defaults[def];
  
  WIRouteBuilder* builder = [[WIRouteBuilder alloc] init];
  
  return [builder build:route];
}

@end
