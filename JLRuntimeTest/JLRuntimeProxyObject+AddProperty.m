//
//  JLRuntimeProxyObject+AddProperty.m
//  JLRuntimeTest
//
//  Created by Julian Song on 17/2/17.
//  Copyright © 2017年 Julian Song. All rights reserved.
//

#import "JLRuntimeProxyObject+AddProperty.h"
#import <objc/objc-runtime.h>

static  NSString * const JLRuntimeProxyObject_name = @"JLRuntimeProxyObject_name";

@implementation JLRuntimeProxyObject (AddProperty)

+ (void)initialize
{
//    IMP fromeIMP = class_getMethodImplementation([self class], @selector(proxySomething3_replace));
//    IMP toIMP = class_getMethodImplementation([self class], @selector(proxySomething3));
    
//    class_replaceMethod([self class], @selector(proxySomething3),fromeIMP,"v@:");
//    class_replaceMethod([self class], @selector(proxySomething3_replace), toIMP,"v@:");
    
    Method from = class_getInstanceMethod([self class], @selector(proxySomething3));
    
    Method to = class_getInstanceMethod([self class], @selector(proxySomething3_replace));
    char *te = method_getTypeEncoding(to);
    method_exchangeImplementations(to,from);
    
    
}
- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, (__bridge const void *)(JLRuntimeProxyObject_name), name, OBJC_ASSOCIATION_COPY);
}

- (NSString *)name
{
    return objc_getAssociatedObject(self,(__bridge const void *)(JLRuntimeProxyObject_name));
}

- (void)proxySomething3_replace
{
    NSLog(@"my cmd is %@",NSStringFromSelector(_cmd));
    [self proxySomething3_replace];
}

@end
