//
// This file is part of Wiggly project
//
// Created by JC on 06/17/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Kiwi.h>

#import "WIRegex.h"
#import "WIRegexSegment.h"
#import "WIRoute.h"

SPEC_BEGIN(WIRegexTests)

describe(@"test", ^{
  __block WIRegex *regex;
  __block WIRegexSegment *article;
  __block WIRegexSegment *comment;
  
  beforeEach(^{
    article = [WIRegexSegment nullMock];
    comment = [WIRegexSegment nullMock];
    
    [article stub:@selector(name) andReturn:@"article"];
    [article stub:@selector(required) andReturn:theValue(YES)];
    
    [comment stub:@selector(name) andReturn:@"comment"];
    [comment stub:@selector(required) andReturn:theValue(NO)];
    
    regex = [[WIRegex alloc] initWithRoute:[WIRoute mock] format:@"{%@}"];
    [regex setStringPattern:@"/blog/article/([0-9]+)(/comment/([0-9a-z]+))?"];

    regex.atomicPath = @"/blog/article/{article}";
    regex.path = @"/blog/article/{article}/comment/{comment}";
    regex.segments = [NSMutableArray arrayWithArray:@[article, comment]];
  });
  
  afterEach(^{
    regex = nil;
    article = nil;
  });
  
  context(@"should generate", ^{
    context(@"short URLS", ^{
      beforeEach(^{
        [article stub:@selector(matchConditions:) andReturn:theValue(YES)];
        
        [article stub:@selector(defaults) andReturn:@1];
      });
      
      it(@"with defaults", ^{
        [[[regex generate:nil] should] equal:@"/blog/article/1"];
      });
      
      it(@"with defaults as arguments", ^{
        [[[regex generate:@{ @"article": @"1" }] should] equal:@"/blog/article/1"];
      });
      
      it(@"with arguments", ^{
        [[[regex generate:@{ @"article": @"5" }] should] equal:@"/blog/article/5"];
      });
      
      it(@"missing value exception", ^{
        [article stub:@selector(defaults) andReturn:nil];

        [[regex should] raiseWithName:NSInvalidArgumentException reason:nil whenSent:@selector(generate)];
      });
    });
    
    describe(@"long URLS", ^{
      beforeEach(^{
        [article stub:@selector(matchConditions:) andReturn:theValue(YES)];
        [comment stub:@selector(matchConditions:) andReturn:theValue(YES)];
        
        [comment stub:@selector(defaults) andReturn:@3];
      });
      
      afterEach(^{
        comment = nil;
      });
      
      it(@"with arguments", ^{
        [[[regex generate:@{@"article": @"4", @"comment": @"5"}] should] equal:@"/blog/article/4/comment/5"];
      });
           
      it(@"requirement fail exception", ^{
        [article stub:@selector(matchConditions:) andReturn:theValue(NO)];

        [[regex should] raiseWhenSent:@selector(generate)];
      });
    });
  });
  
  context(@"should match", ^{
    beforeEach(^{
      [comment stub:@selector(defaults) andReturn:@6];
    });
    
    it(@"simple path", ^{
      [[[regex match:@"/blog/article/4/comment/z3"] should] equal:(@{ @"article": @"4", @"comment": @"z3" })];
    });
    
    it(@"fail match pattern", ^{
      [[regex match:@"/blog/article/string/comment/z3"] shouldBeNil];
    });
    
    it(@"atomic path", ^{
      [[[regex match:@"/blog/article/4"] should] equal:@{ @"article": @"4", @"comment": @"6" }];
    });
  });
});

SPEC_END
