//
//  ViewController.m
//  JLRumtimeTest
//
//  Created by Julian Song on 17/2/15.
//  Copyright © 2017年 Julian Song. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc-runtime.h>
#import "JLRuntimeProxyObject.h"
@interface ViewController ()
@property(nonatomic,strong)NSString *mydata;
@property(nonatomic,strong)NSMutableDictionary *dataContainer;
@property(nonatomic,strong)JLRuntimeProxyObject *proxy;
@end

void setMyDataIMP(ViewController *self,SEL _cmd,NSString *data)
{
    [self.dataContainer setObject:data forKey:@"mydata"];
}

NSString *getMyDataIMP(ViewController *self,SEL _cmd)
{
    return [self.dataContainer objectForKey:@"mydata"];
}

@implementation ViewController
@dynamic mydata;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataContainer = [[NSMutableDictionary alloc] init];
    self.proxy = [[JLRuntimeProxyObject alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self sendMsg];
    }
    if (indexPath.row == 1) {
        [self getMethodAndCall];
    }
    if (indexPath.row == 2) {
        self.mydata = @"dynamic data";
        NSLog(@"Dynamic Method Resolution:%@",self.mydata);
    }
    if (indexPath.row == 3) {
        id my = self;
        [my proxySomething];
    }
}

#pragma mark - Send msg

- (void)sendMsg
{
    SEL doSh = @selector(doSomething);
    objc_msgSend(self,doSh);
    
    SEL doShWithArg = @selector(doSomethingWithArg:);
    NSString *returnVal = objc_msgSend(self,doShWithArg,@"oh");
    NSLog(@"Return:%@",returnVal);
}

- (void)getMethodAndCall
{
    void (*doSh)(id,SEL)= (void (*)(id,SEL))[self methodForSelector:@selector(doSomething)];
    doSh(self,@selector(doSomething));
    
    NSString *(*doShWithArg)(id,SEL,NSString *) = (NSString *(*)(id,SEL,NSString *))[self methodForSelector:@selector(doSomethingWithArg:)];
    NSString *returnVal = doShWithArg(self,@selector(doSomethingWithArg:),@"wow!");
    NSLog(@"Return:%@",returnVal);
}

- (void)doSomething
{
    NSLog(@"do something");
}

- (NSString *)doSomethingWithArg:(NSString *)arg
{
    NSLog(@"do something with arg:%@",arg);
    return [NSString stringWithFormat:@"Done with:%@",arg];
}

#pragma mark - Dynamic Method Resolution

+(BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(mydata)) {
        class_addMethod([self class],sel,(IMP)getMyDataIMP,"v@:");
        return YES;
    }
    
    if (sel == @selector(setMydata:)) {
        class_addMethod([self class],sel,(IMP)setMyDataIMP,"v@:");
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

#pragma mark - Message Forward

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *s = [super methodSignatureForSelector:aSelector];
    if (s == nil) {
        s = [self.proxy methodSignatureForSelector:aSelector];
    }
    return s;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.proxy respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.proxy];
    }else{
        [super forwardInvocation:anInvocation];
    }
}
@end
