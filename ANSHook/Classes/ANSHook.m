//
//  ANSHook.m
//  ANSHook
//
//  Created by xiao xu on 2021/1/14.
//

#import "ANSHook.h"
#import <objc/runtime.h>

static NSMutableDictionary *ans_method_order;
static NSMutableSet *ans_unHookMethodSet;

@implementation ANSHook

+ (instancetype)shareInstance {
    static ANSHook *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[ANSHook alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ans_method_order = [NSMutableDictionary dictionary];
        ans_unHookMethodSet = [NSMutableSet set];
    }
    return self;
}

- (void)ansHookInstanceSelector:(SEL)aSelector onClass:(Class)aClass order:(ANSSwizzleOrder)order isRecursive:(BOOL)recursive {
    //当前类能响应该方法
    Class hook_class = aClass;
    Method aMethod = class_getInstanceMethod(hook_class, aSelector);
    
    if (aMethod) {
        if (recursive) {
            //当前类或其父类实现了该aSelector
            //向父类遍历找到能响应方法的基类
            hook_class = [self findBaseClassRespondSelector:aSelector onClass:hook_class];
        } else {
            //当前类或其父类实现了该aSelector
            //向父类遍历找到能响应方法的最近子类
            hook_class = [self findLocalClassWithMethod:aMethod onClass:hook_class];
            
            if ([self isHookSelector:aSelector onClass:hook_class]) {
                [self setunHookSelector:aSelector onClass:hook_class];
                //当前子类可以hook，但父类可能已经hook了，需要取消父类的hook
                [self unHookSelector:aSelector onCurrentClass:hook_class];
            } else {
                return;
            }
        }
        
        
        SEL newSelector = NSSelectorFromString([NSString stringWithFormat:@"ans_%@",NSStringFromSelector(aSelector)]);
        const char *types = method_getTypeEncoding(aMethod);
        if (class_addMethod(hook_class, newSelector, class_getMethodImplementation([self class],newSelector), types)) {
            
            Method originMethod = class_getInstanceMethod(hook_class, aSelector);
            Method newMethod = class_getInstanceMethod(hook_class, newSelector);
            method_exchangeImplementations(originMethod, newMethod);
            
            [ans_method_order setValue:@(order) forKey:NSStringFromSelector(newSelector)];
            
            NSLog(@"在%@类中-方法:%@ hook成功",NSStringFromClass(hook_class),NSStringFromSelector(aSelector));
        } else {
            NSLog(@"在%@类中-方法:%@ 已hook",NSStringFromClass(hook_class),NSStringFromSelector(aSelector));
        }
        
    } else {
        //当前类或其父类没有实现了该aSelector
        NSLog(@"ANSHook 不能 hook:%@",NSStringFromSelector(aSelector));
    }
}

- (void)ansHookClassSelector:(SEL)aSelector onClass:(Class)aClass order:(ANSSwizzleOrder)order {
    
}

- (Class)findBaseClassRespondSelector:(SEL)aSelector onClass:(Class)aClass {
    Class tmpClass = aClass;
    while (tmpClass) {
        BOOL b = [tmpClass instancesRespondToSelector:aSelector];
        if (b) {
            tmpClass = class_getSuperclass(tmpClass);
        } else {
            break;
        }
    }
    return tmpClass;
}

- (Class)findLocalClassWithMethod:(Method)aMethod onClass:(Class)aClass {
    Class tmpClass = aClass;
    while (tmpClass) {
        BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:tmpClass];
        if (isLocal) {
            break;
        } else {
            tmpClass = class_getSuperclass(tmpClass);
        }
    }
    return tmpClass;
}

- (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

//子类的方法需要hook，但是父类已经hook完成需要将父类的hook取消
- (void)unHookSelector:(SEL)aSelector onCurrentClass:(Class)aClass {
    SEL newSelector = NSSelectorFromString([NSString stringWithFormat:@"ans_%@",NSStringFromSelector(aSelector)]);
    Class tmpClass = class_getSuperclass(aClass);
    while (tmpClass) {
        BOOL b = [tmpClass instancesRespondToSelector:aSelector];
        if (b) {
            IMP swizzleIMP = class_getMethodImplementation([self class], newSelector);
            IMP originIMP = class_getMethodImplementation(tmpClass, aSelector);
            if (swizzleIMP == originIMP) {
                Method originMethod = class_getInstanceMethod(tmpClass, aSelector);
                Method swizzleMethod = class_getInstanceMethod(tmpClass, newSelector);
                method_exchangeImplementations(originMethod, swizzleMethod);
                
                [ans_method_order removeObjectForKey:NSStringFromSelector(newSelector)];
                
                NSLog(@"取消%@类中-方法:%@ hook",NSStringFromClass(tmpClass),NSStringFromSelector(aSelector));
            }
        }
        tmpClass = class_getSuperclass(tmpClass);
    }
}

//判断当前的类、方法 是否能hook(父类 和 子类 同时实现的方法，父类是不能参与hook的)
- (BOOL)isHookSelector:(SEL)aSelector onClass:(Class)aClass {
    if ([ans_unHookMethodSet containsObject:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(aClass),NSStringFromSelector(aSelector)]]) {
        return NO;
    } else {
        return YES;
    }
}
//将不允许hook的类、方法 加入黑名单
- (void)setunHookSelector:(SEL)aSelector onClass:(Class)aClass {
    Class tmpClass = class_getSuperclass(aClass);
    while (tmpClass) {
        BOOL b = [tmpClass instancesRespondToSelector:aSelector];
        if (b) {
            [ans_unHookMethodSet addObject:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(tmpClass),NSStringFromSelector(aSelector)]];
        }
        tmpClass = class_getSuperclass(tmpClass);
    }
}

#pragma mark 私有 HOOK API

- (void)ans_viewDidLoad {
    if ([[ans_method_order objectForKey:@"ans_viewDidLoad"] integerValue] == ANSSwizzleOrderBefore) {
        [ANSHook shareInstance].viewDidLoad(NSStringFromClass([self class]));
        [self ans_viewDidLoad];
    } else if ([[ans_method_order objectForKey:@"ans_viewDidLoad"] integerValue] == ANSSwizzleOrderAfter) {
        [self ans_viewDidLoad];
        [ANSHook shareInstance].viewDidLoad(NSStringFromClass([self class]));
    } else {
        [self ans_viewDidLoad];
    }
}

- (UITableViewCell *)ans_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[ans_method_order objectForKey:@"ans_tableView:cellForRowAtIndexPath:"] integerValue] == ANSSwizzleOrderBefore) {
        [ANSHook shareInstance].cellForRow(tableView, indexPath);
        UITableViewCell *cell = [self ans_tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else if ([[ans_method_order objectForKey:@"ans_tableView:cellForRowAtIndexPath:"] integerValue] == ANSSwizzleOrderAfter) {
        UITableViewCell *cell = [self ans_tableView:tableView cellForRowAtIndexPath:indexPath];
        [ANSHook shareInstance].cellForRow(tableView, indexPath);
        return cell;
    } else {
        UITableViewCell *cell = [self ans_tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }
}

- (void)ans_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[ans_method_order objectForKey:@"ans_tableView:didSelectRowAtIndexPath:"] integerValue] == ANSSwizzleOrderBefore) {
        [ANSHook shareInstance].didSelectRow(tableView, indexPath);
        [self ans_tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else if ([[ans_method_order objectForKey:@"ans_tableView:didSelectRowAtIndexPath:"] integerValue] == ANSSwizzleOrderAfter) {
        [self ans_tableView:tableView didSelectRowAtIndexPath:indexPath];
        [ANSHook shareInstance].didSelectRow(tableView, indexPath);
    } else {
        [self ans_tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
@end
