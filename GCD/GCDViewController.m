
//  GCDViewController.m
//  GCD
//
//  Created by 张松伟 on 2017/12/18.
//  Copyright © 2017年 iSong. All rights reserved.
//

#import "GCDViewController.h"
#import <dispatch/object.h>
@interface GCDViewController ()

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //常用的介绍
    
    dispatch_queue_t queue = dispatch_get_global_queue(1, 1);
    
    dispatch_async(queue, ^{
    //长时间处理
        
        //ar画像识别
        
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
       //只在主线程执行
    });
    
#pragma mark -GCD-----API
#pragma mark =============创建queue=============

    //创建queue
    
    //1 serial dispatch queue  单个有序执行可以多个并行
    //一般只在为了防止多个线程更新相同资源导致数据争夺时使用
    
    //第一个参数指定名称 当然可以设置成NULL但是在调试的时候  是没有显示的
    //
    dispatch_queue_t queue1 = dispatch_queue_create("标识", NULL);
    
    dispatch_async(queue1, ^{
        
    });
    //3 通过create生成的queue 必须手动释放
    dispatch_release(queue1);
    //2 当不想执行不发生数据竞争的问题是可以使用concurrent dispatch queue
    //而且不管生成多少, 由于XNU志使用有效管理的线程, 因此不会发生哪些问题
    
    
    //第二个参数设置为DISPATCH_QUEUE_CONCURRENT  即是
    dispatch_queue_t queue2 = dispatch_queue_create("com.zsw.sw", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue2, ^{
        
    });
    //3 通过create生成的queue 必须手动释放
    dispatch_release(queue2);
    
    
    //系统提供的几个queue
    //1 main   当然属于serial dispatch queue
    //追加到这里当然就是在主程序的runloop中
    dispatch_queue_t main = dispatch_get_main_queue();

    
    
    
    //这个就是属于第二种了
    //第一个参数就是优先级的使用   4种
    //flag作为保留字段备用（一般为0）
    /*
    
#define DISPATCH_QUEUE_PRIORITY_HIGH 2
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
     
    */
    
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    
    
#pragma mark =============dispatch_set_target_queue=============
    
    dispatch_queue_t SERIAL = dispatch_queue_create("com.zsw.zsw", NULL);
    
    dispatch_queue_t GLOBAL_BACK = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //指定要变更优先级的第一个参数
    dispatch_set_target_queue(SERIAL, GLOBAL_BACK);
    
    //  将必须不可并行执行的处理追加到多个serial 的queue
    //使用该方法  将目标指定为某一个serial queue  即可防止处理并行处理
    
    
#pragma mark =============dispatch_after=============
    
    dispatch_time_t  time = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time), dispatch_get_main_queue(), ^{
        
            //相当于 大致3秒后一步添加到主线程执行
    });
    
#pragma mark =============Dispatch Group=============
    

    
    
    
    
    
}



@end
