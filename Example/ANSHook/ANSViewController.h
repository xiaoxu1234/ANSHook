//
//  ANSViewController.h
//  ANSHook
//
//  Created by xiaoxu1234 on 01/14/2021.
//  Copyright (c) 2021 xiaoxu1234. All rights reserved.
//

@import UIKit;

@interface ANSViewController : UIViewController
@property (nonatomic,strong) NSMutableArray *data;
- (NSArray *)getModuleData;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
