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
#import "WIRouteParameter.h"

@interface WIRouteBuilderTests : SenTestCase
@end

@implementation WIRouteBuilderTests

- (void)testWithPlaceholder {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(builder.regex, @"/blog/(\\d+)", nil);
}

- (void)testWithTwoPlaceholders {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/:id"
                                   requirements:@{@"page": @"\\w+", @"id": @"[0-9]"}
                                       defaults:nil];

  STAssertEqualObjects(builder.regex, @"/blog/(\\w+)/([0-9])", nil);
}

- (void)testWithTrailingBackslash {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/"
                                   requirements:@{@"page": @"[0-9]{1,2}"}
                                       defaults:nil];

  STAssertEqualObjects(builder.regex, @"/blog/([0-9]{1,2})/", nil);
}

- (void)testWithStaticTextAtTheEnd {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/show"
                                   requirements:@{@"page" : @"\\d+"}
                                       defaults:nil];

  STAssertEqualObjects(builder.regex, @"/blog/(\\d+)/show", nil);
}

- (void)testWithOptionalPlaceholderAtTheEnd {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                   requirements:@{@"page": @"\\d+"}
                                       defaults:@{@"page": @"1"}];

  STAssertEqualObjects(builder.regex, @"/blog(/(\\d+))?", nil);
}

- (void)testWithRequiredAndOptionalPlaceholderAtTheEnd {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/show/:id/and/:foo"
                                   requirements:@{@"page" : @"\\d+", @"id": @"\\d+", @"foo": @"\\d+"} defaults:@{@"foo": @1, @"id": @2}];
  STAssertEqualObjects(builder.regex, @"/blog/(\\d+)/show/(\\d+)/and(/(\\d+))?", nil);
}

- (void)testWithOptionalPlaceholdersNotAtTheEnd {
  WIRouteBuilder  *builder = [self _routeRegex:@"/blog/:page/show/:id/last"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(builder.regex, @"/blog/(\\d+)/show/(\\d+)/last", nil);
}

- (void)testWithStaticTextBetweenTwoOptionalPlaceholders {
  WIRouteBuilder  *builder = [self _routeRegex:@"/blog/:page/show/:id"
                                    requirements:@{@"page": @"\\d+", @"id": @"\\d+"}
                                        defaults:@{@"id": @2}];

  STAssertEqualObjects(builder.regex, @"/blog/(\\d+)/show(/(\\d+))?", nil);
}

//- (void)testShortPathEqualLongPath {
//  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
//                                   requirements:nil
//                                       defaults:nil];
//
//  STAssertEqualObjects(builder.path, builder.path, nil);
//}
//
//- (void)testShortPathShorterThanLongPath {
//  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
//                                   requirements:nil
//                                       defaults:@{@"page": @1}];
//
//  STAssertEqualObjects(builder.path, @"/blog", nil);
//}

- (void)testPlaceholdersSetAsRequired {
  WIRouteBuilder  *builder = [self _routeRegex:@"/blog/:page/show/:id"
                                    requirements:nil
                                        defaults:@{@"page": @1, @"id": @1}];

  STAssertTrue(((WIRouteParameter *)builder.placeholders[0]).required, nil);
}

- (void)testPlaceholdersAllSetAsRequired {
  WIRouteBuilder  *builder = [self _routeRegex:@"/blog/:page/show/:id/foo"
                                    requirements:nil
                                        defaults:@{@"page": @1, @"id": @1}];

  for (WIRouteParameter *holder in builder.placeholders)
    STAssertTrue(holder.required, @"'%@' holder is not set to required", holder.name);
}

- (void)testMatch {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:nil
                                     defaults:nil];


  NSDictionary *matches = [builder match:@"/blog/5"];

  STAssertEquals((int)matches.count, 1, nil);
  STAssertEqualObjects(matches[@"page"], @"5", nil);
}

- (void)testDontMatchRequirements {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:@{@"page": @"\\d+"}
                                     defaults:nil];

  STAssertNil([builder match:@"/blog/foo"], nil);
}

- (void)testMatchComplexRequirement {
  WIRouteBuilder *builder = [self _routeRegex:@"/photos/:id"
                                 requirements:@{@"id": @"[A-Z]\\d{5}"}
                                     defaults:nil];
  
  STAssertEqualObjects([builder match:@"/photos/A12345"], @{@"id": @"A12345"}, nil);
  STAssertEqualObjects([builder match:@"/photos/A123"], nil, nil);
}

- (void)testMatchOptionalSegment {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/:show/:id"
                                 requirements:nil
                                     defaults:@{@"show": @1, @"id": @2}];
  NSDictionary *matches = [builder match:@"/blog/5"];

  STAssertEqualObjects(matches[@"page"], @"5", nil);
  STAssertEqualObjects(matches[@"show"], @1, nil);
  STAssertEqualObjects(matches[@"id"], @2, nil);
}

- (void)testDontMatch {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:nil
                                     defaults:nil];

  STAssertEquals((int)[builder match:@"/blog"], 0, nil);
}

- (void)testGenerate {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:nil
                                     defaults:nil];
  NSString *url = [builder generate:@{@"page": @5}];

  STAssertEqualObjects(url, @"/blog/5", nil);
}

- (void)testGenerateShort {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/:id"
                                 requirements:nil
                                     defaults:@{ @"id": @1 }];

  NSString *url = [builder generate:@{ @"page": @5}];
  STAssertEqualObjects(url, @"/blog/5", nil);
}

- (void)testGenerateDefaults {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/:id"
                                 requirements:nil
                                     defaults:@{ @"id": @1 }];

  NSString *url = [builder generate:@{ @"page": @5, @"id": @6 }];
  STAssertEqualObjects(url, @"/blog/5/6", nil);
}

- (void)testGenerateShortWithDefaultsPassed {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page/:id"
                                 requirements:nil
                                     defaults:@{ @"id": @6, @"page": @"hello" }];

  NSString *url = [builder generate:@{ @"page": @"hello", @"id": @"6" }];
  STAssertEqualObjects(url, @"/blog", nil);
}

- (void)testGenerateRequirementsException {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:@{ @"page": @"\\d+" }
                                     defaults:nil];

  STAssertThrows([builder generate:@{ @"page": @"hello"}], nil);
}

- (void)testGenerateMissingValueException {
  WIRouteBuilder *builder = [self _routeRegex:@"/blog/:page"
                                 requirements:nil
                                     defaults:nil];

  STAssertThrows([builder generate:nil], nil);
}

- (WIRouteBuilder *)_routeRegex:(NSString *)path
                     requirements:(NSDictionary *)requirements
                         defaults:(NSDictionary *)defaults {
  WIRoute *route = [WIRoute routeWithPath:path];
  WIRouteBuilder *builder;

  for (id requirement in requirements)
    route.requirements[requirement] = requirements[requirement];

  for (id def in defaults)
    route.defaults[def] = defaults[def];

  builder = [[WIRouteBuilder alloc] initWithRoute:route];

  return builder;
}

@end
