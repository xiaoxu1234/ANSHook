//
//  CVCViewController.m
//  ANSHook_Example
//
//  Created by xiao xu on 2021/1/14.
//  Copyright © 2021 xiaoxu1234. All rights reserved.
//

#import "CVCViewController.h"

@interface CVCViewController ()

@end

@implementation CVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:@"全埋点"]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:@"全埋点"]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
