//
//  BVCViewController.m
//  ANSHook_Example
//
//  Created by xiao xu on 2021/1/14.
//  Copyright © 2021 xiaoxu1234. All rights reserved.
//

#import "BVCViewController.h"
#import "CVCViewController.h"

static NSString *const visual_general_ui = @"常用控件";
static NSString *const visual_table_view = @"列表布局";
static NSString *const visual_collection_view = @"网格布局";

@interface BVCViewController ()

@end

@implementation BVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    CVCViewController *cvc = [[CVCViewController alloc] init];
    [self.navigationController pushViewController:cvc animated:YES];

}

- (NSArray *)getModuleData {
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"main_module" ofType:@"json"];
    //获取文件内容
    NSString *jsonStr  = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //将文件内容转成数据
    NSData *jaonData   = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //将数据转成数组
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jaonData options:NSJSONReadingMutableContainers error:nil];
    
    __block NSMutableArray * ret;
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:@"可视化"]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:@"可视化"]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
