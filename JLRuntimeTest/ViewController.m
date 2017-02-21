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
#import "JLRuntimeProxyObject+AddProperty.h"
#import "JLRuntimeSubProxyObject.h"
@interface ViewController ()
{
    NSString *value_myType;
}
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

NSString *getMyTypeIMP(id self,SEL _cmd)
{
    Ivar var = class_getInstanceVariable([self class],"value_myType");
    return object_getIvar(self,var);
}

void setMyTypeIMP(id self,SEL _cmd,NSString *value)
{
    Ivar var = class_getInstanceVariable([self class],"value_myType");
    id oldType = object_getIvar(self,var);
    if (oldType != value) {
        object_setIvar(self,var,value);
    }
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
    
    if (indexPath.row == 4) {
        [self typeEncodings];
    }
    
    if (indexPath.row == 5) {
        self.proxy.name = @"Jerry";
        NSLog(@"Proxy name %@",self.proxy.name);
    }
    
    if (indexPath.row == 6) {
        [self propertyList];
    }
    
    if (indexPath.row == 7) {
        [self addProperty];
    }
    
    if (indexPath.row == 8) {
        [self setClass];
    }
    if (indexPath.row == 9) {
        [self changeMethod];
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

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }else{
        return [self.proxy respondsToSelector:aSelector];
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    if ([super isKindOfClass:aClass]) {
        return YES;
    }else{
        return [self.proxy isKindOfClass:aClass];
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    /*
     <NSMethodSignature: 0x600000260500>
     number of arguments = 2
     frame size = 224
     is special struct return? NO
     return value: -------- -------- -------- --------
     type encoding (v) 'v'
     flags {}
     modifiers {}
     frame {offset = 0, offset adjust = 0, size = 0, size adjust = 0}
     memory {offset = 0, size = 0}
     argument 0: -------- -------- -------- --------
     type encoding (@) '@'
     flags {isObject}
     modifiers {}
     frame {offset = 0, offset adjust = 0, size = 8, size adjust = 0}
     memory {offset = 0, size = 8}
     argument 1: -------- -------- -------- --------
     type encoding (:) ':'
     flags {}
     modifiers {}
     frame {offset = 8, offset adjust = 0, size = 8, size adjust = 0}
     memory {offset = 0, size = 8}
     */
    
    NSMethodSignature *s = [super methodSignatureForSelector:aSelector];
    if (s == nil) {
        s = [self.proxy methodSignatureForSelector:aSelector];
    }
    return s;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    /*
     <NSInvocation: 0x600000275640>
     return value: {v} void
     target: {@} 0x7f84f1d09ce0
     selector: {:} proxySomething
     
     调用一个方法需要SEL（选择器）NSMethodSignature（方法签名） target 三个数据。
     选择器是方法名，用户获取方法实现（函数指针）以便调用。
     方法签名包含方法参数个数和类型以及返回值类型。方法被调用时使用此数据解析输入输出数据。
     target 为消息接收对象。
     */
    if ([self.proxy respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.proxy];
    }else{
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - Type Encodings

-(void)typeEncodings
{
    NSLog(@"int        : %s", @encode(int));
    NSLog(@"float      : %s", @encode(float));
    NSLog(@"float *    : %s", @encode(float*));
    NSLog(@"char       : %s", @encode(char));
    NSLog(@"char *     : %s", @encode(char *));
    NSLog(@"BOOL       : %s", @encode(BOOL));
    NSLog(@"void       : %s", @encode(void));
    NSLog(@"void *     : %s", @encode(void *));
    
    NSLog(@"NSObject * : %s", @encode(NSObject *));
    NSLog(@"NSObject   : %s", @encode(NSObject));
    NSLog(@"[NSObject] : %s", @encode(typeof([NSObject class])));
    NSLog(@"NSError ** : %s", @encode(typeof(NSError **)));
    
    int intArray[5] = {1, 2, 3, 4, 5};
    NSLog(@"int[]      : %s", @encode(typeof(intArray)));
    
    float floatArray[3] = {0.1f, 0.2f, 0.3f};
    NSLog(@"float[]    : %s", @encode(typeof(floatArray)));
    
    typedef struct _struct {
        short a;
        long long b;
        unsigned long long c;
    } Struct;
    NSLog(@"struct     : %s", @encode(typeof(Struct)));
}

#pragma mark - Property

- (void)propertyList
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self.proxy class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        const char * p_name = property_getName(property);
        fprintf(stdout, "%s %s\n",p_name, property_getAttributes(property));
        fprintf(stdout, "------------------\n");
        unsigned int paCount;
        objc_property_attribute_t *property_attributes = property_copyAttributeList(property, &paCount);
        for (int pi =0 ; pi < paCount; pi ++) {
            objc_property_attribute_t pa = property_attributes[pi];
            const char *pa_value = property_copyAttributeValue(property,pa.name);
            fprintf(stdout, "  pa name:%s pa value%s\n",pa.name,pa_value);
        }
        free(property_attributes);
    }
    
}

- (void)addProperty
{
    objc_property_attribute_t t1 = {"T","@\"NSString\""};
    objc_property_attribute_t t2 = {"&",""};
    objc_property_attribute_t t3 = {"D",""};
    objc_property_attribute_t t4 = {"N",""};
    objc_property_attribute_t t5 = {"V","value_myType"};
    objc_property_attribute_t attributes[] = {t1,t2,t3,t4,t5};
    if(class_addProperty([self class],"myType",attributes,4)){
        
//        class_addIvar([self class],"value_myType",sizeof(id),0,"@");//静态类无法动态添加示例变量
        SEL myTypeSEL = sel_registerName("myType");
        SEL setMyTypeSEL = sel_registerName("setMytype");
        /*
         class_addMethod 的第三个参数以字符串的格式描述了函数的接收与返回参数的类型。
         在此处@@:表述为返回参数为对象类型，第二个参数为self，第三个参数为_cmd
         如有其它参数则使用@encode函数编码后添加。
         详见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
             https://developer.apple.com/reference/objectivec/1418901-class_addmethod?language=objc
         */
        
        class_addMethod([self class],myTypeSEL,(IMP)getMyTypeIMP, "@@:");
        class_addMethod([self class],setMyTypeSEL,(IMP)setMyTypeIMP, "v@:");
        NSLog(@"add property done!");
        
        id my = self;
        [my performSelector:setMyTypeSEL withObject:@"wowww"];
        NSLog(@"the added property %@",[my performSelector:myTypeSEL]);
    }

}

- (void)setClass
{
    object_setClass(self.proxy,[JLRuntimeSubProxyObject class]);
    [self.proxy proxySomething];
}

- (void)changeMethod
{
    [self.proxy proxySomething3];
}
@end
