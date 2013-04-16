//
// This file is part of Wiggly project
//
// Created by JC on 03/30/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//
#import <SenTestingKit/SenTestingKit.h>

#import "WIRoute.h"
#import "WIRouteBuilder.h"
#import "WIRoutePlaceholder.h"

@interface WIRouteBuilderTests : SenTestCase
@end

@implementation WIRouteBuilderTests

- (void)testWithPlaceholder {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(builder.pattern, @"/blog/\\d+", nil);
}

- (void)testWithTwoPlaceholders {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page/:id"
                                   requirements:@{@"page": @"\\w+", @"id": @"[0-9]"}
                                       defaults:nil];

  STAssertEqualObjects(builder.pattern, @"/blog/\\w+/[0-9]", nil);
}

- (void)testWithTrailingBackslash {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page/"
                                   requirements:@{@"page": @"[0-9]{1,2}"}
                                       defaults:nil];

  STAssertEqualObjects(builder.pattern, @"/blog/[0-9]{1,2}/", nil);
}

- (void)testWithStaticTextAtTheEnd {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page/show"
                                   requirements:@{@"page" : @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(builder.pattern, @"/blog/\\d+/show", nil);
}

- (void)testWithOptionalPlaceholderAtTheEnd {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:@{@"page": @"1"}];

  STAssertEqualObjects(builder.pattern, @"/blog(/\\d+)?", nil);
}

- (void)testWithRequiredAndOptionalPlaceholderAtTheEnd {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page/show/:id/and/:foo"
                                   requirements:@{@"page" : @"\\d+", @"id": @"\\d+", @"foo": @"\\d+"} defaults:@{@"foo": @1, @"id": @2}];
  STAssertEqualObjects(builder.pattern, @"/blog/\\d+/show/\\d+/and(/\\d+)?", nil);
}

- (void)testWithOptionalPlaceholdersNotAtTheEnd {
  WIRouteBuilder  *builder = [self _routePattern:@"/blog/:page/show/:id/last"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(builder.pattern, @"/blog/\\d+/show/\\d+/last", nil);
}

- (void)testWithStaticTextBetweenTwoOptionalPlaceholders {
  WIRouteBuilder  *builder = [self _routePattern:@"/blog/:page/show/:id"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(builder.pattern, @"/blog/\\d+/show(/\\d+)?", nil);
}

- (void)testShortPathEqualLongPath {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page"
                                   requirements:nil
                                       defaults:nil];

  STAssertEqualObjects(builder.shortPath, builder.path, nil);
}

- (void)testShortPathShorterThanLongPath {
  WIRouteBuilder *builder = [self _routePattern:@"/blog/:page"
                                   requirements:nil
                                       defaults:@{@"page": @1}];

  STAssertEqualObjects(builder.shortPath, @"/blog", nil);
}

- (void)testPlaceholdersSetAsRequired {
  WIRouteBuilder  *builder = [self _routePattern:@"/blog/:page/show/:id"
                                    requirements:nil
                                        defaults:@{@"page": @1, @"id": @1}];

  STAssertTrue(((WIRoutePlaceholder *)builder.placeholders[0]).required, nil);
}

- (void)testPlaceholdersAllSetAsRequired {
  WIRouteBuilder  *builder = [self _routePattern:@"/blog/:page/show/:id/foo"
                                    requirements:nil
                                        defaults:@{@"page": @1, @"id": @1}];

  for (WIRoutePlaceholder *holder in builder.placeholders)
    STAssertTrue(holder.required, @"'%@' holder is not set to required", holder.name);
}

- (WIRouteBuilder *)_routePattern:(NSString *)path
                     requirements:(NSDictionary *)requirements
                         defaults:(NSDictionary *)defaults {
  WIRoute *route = [WIRoute routeWithPath:path];

  for (id requirement in requirements)
    route.requirements[requirement] = requirements[requirement];

  for (id def in defaults)
    route.defaults[def] = defaults[def];

  return [[WIRouteBuilder alloc] initWithRoute:route];
}

@end
