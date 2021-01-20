//
//  ANSHook.h
//  ANSHook
//
//  Created by xiao xu on 2021/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CellForRow)(UITableView *tableView, NSIndexPath *indexPath);
typedef void(^DidSelectRow)(UITableView *tableView, NSIndexPath *indexPath);
typedef void(^ViewDidLoad)(NSString *vc);

//  交换方法时，SDK方法与系统方法的先后执行顺序
typedef NS_ENUM(NSInteger, ANSSwizzleOrder) {
    ANSSwizzleOrderBefore,  // SDK在前，系统在后
    ANSSwizzleOrderAfter  // 系统在前，SDK在后
};

@interface ANSHook : NSObject

@property (nonatomic,copy) CellForRow cellForRow;
@property (nonatomic,copy) DidSelectRow didSelectRow;
@property (nonatomic,copy) ViewDidLoad viewDidLoad;


+ (instancetype)shareInstance;
- (void)ansHookInstanceSelector:(SEL)aSelector onClass:(Class)aClass order:(ANSSwizzleOrder)order isRecursive:(BOOL)recursive;
- (void)ansHookClassSelector:(SEL)aSelector onClass:(Class)aClass order:(ANSSwizzleOrder)order;
@end

NS_ASSUME_NONNULL_END
