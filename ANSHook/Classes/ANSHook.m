//
//  ANSHook.m
//  ANSHook
//
//  Created by xiao xu on 2021/1/14.
//

#import "ANSHook.h"
#import <objc/runtime.h>

@implementation ANSHook

+ (instancetype)shareInstance {
    static ANSHook *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[ANSHook alloc] init] ;
    });
    return instance;
}

+ (void)ansHookInstanceSelector:(SEL)aSelector onClass:(Class)aClass {
    //当前类能响应该方法
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    
    if (aMethod) {
        //当前类或其父类实现了该aSelector
        //向父类遍历找到能响应方法的基类
        aClass = [self findBaseClassRespondSelector:aSelector onClass:aClass];
        
        SEL newSelector = NSSelectorFromString([NSString stringWithFormat:@"ans_%@",NSStringFromSelector(aSelector)]);
        const char *types = method_getTypeEncoding(aMethod);
        if (class_addMethod(aClass, newSelector, class_getMethodImplementation(self,newSelector), types)) {
            
            Method originMethod = class_getInstanceMethod(aClass, aSelector);
            Method newMethod = class_getInstanceMethod(aClass, newSelector);
            method_exchangeImplementations(originMethod, newMethod);
            
            NSLog(@"在%@类中-方法:%@ hook成功",NSStringFromClass(aClass),NSStringFromSelector(aSelector));
        } else {
            NSLog(@"在%@类中-方法:%@ 已hook",NSStringFromClass(aClass),NSStringFromSelector(aSelector));
        }
        
    } else {
        //当前类或其父类没有实现了该aSelector
        NSLog(@"ANSHook 不能 hook:%@",NSStringFromSelector(aSelector));
    }
}

+ (void)ansHookClassSelector:(SEL)aSelector onClass:(Class)aClass {
    
}

+ (Class)findBaseClassRespondSelector:(SEL)aSelector onClass:(Class)aClass {
    Class tmpClass = class_getSuperclass(aClass);
    Class retClass = aClass;
    while (tmpClass) {
        BOOL b = [tmpClass instancesRespondToSelector:aSelector];
        if (b) {
            retClass = tmpClass;
        } else {
            
        }
        tmpClass = class_getSuperclass(tmpClass);
    }
    return retClass;
}

#pragma mark 私有 HOOK API

- (void)ans_viewDidLoad {
    [self ans_viewDidLoad];
    [ANSHook shareInstance].viewDidLoad(NSStringFromClass([self class]));
}

- (UITableViewCell *)ans_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self ans_tableView:tableView cellForRowAtIndexPath:indexPath];
    [ANSHook shareInstance].cellForRow(tableView, indexPath);
    return cell;
}

- (void)ans_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [ANSHook shareInstance].didSelectRow(tableView, indexPath);
    [self ans_tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
