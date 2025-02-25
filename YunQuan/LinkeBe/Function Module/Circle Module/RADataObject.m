
//The MIT License (MIT)
//
//Copyright (c) 2013 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RADataObject.h"

@implementation RADataObject


- (id)initWithName:(NSString *)name count:(int)count orgId:(NSInteger)orgId children:(NSArray *)children arrowPoint:(BOOL)flag
{
  self = [super init];
  if (self) {
    self.children = children;
    self.name = name;
    self.count = count;
    self.orgId = orgId;
    self.isExpand = flag;
  }
  return self;
}

+ (id)dataObjectWithName:(NSString *)name count:(int)count orgId:(NSInteger)orgId children:(NSArray *)children arrowPoint:(BOOL)flag
{
    return [[[self alloc] initWithName:name count:count orgId:(NSInteger)orgId children:children arrowPoint:flag] autorelease];
}

- (void)dealloc
{
    self.children = nil;
    self.name = nil;
    [super dealloc];
}
@end
