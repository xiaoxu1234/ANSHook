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

@interface ANSHook : NSObject

@property (nonatomic,copy) CellForRow cellForRow;
@property (nonatomic,copy) DidSelectRow didSelectRow;
@property (nonatomic,copy) ViewDidLoad viewDidLoad;


+ (instancetype)shareInstance;
+ (void)ansHookInstanceSelector:(SEL)aSelector onClass:(Class)aClass;
+ (void)ansHookClassSelector:(SEL)aSelector onClass:(Class)aClass;
@end

NS_ASSUME_NONNULL_END
