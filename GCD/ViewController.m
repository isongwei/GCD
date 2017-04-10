//
//  ViewController.m
//  GCD
//
//  Created by iSongWei on 2017/4/10.
//  Copyright © 2017年 iSong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
//GCD的简单使用
/*
 同步 (Synchronous)
 
 在当前线程中执行任务，不具备开启新线程的能力
 提交的任务在执行完成后才会返回
 同步函数: dispatch_sync()
 
 
 
 异步 (Asynchronous)
 
 在新线程中执行任务，具备开启新线程的能力
 提交的任务立刻返回，在后台队列中执行
 异步函数: dispatch_async()
 */

/*
 1.所有的执行都放到队列中(queue)，队列的特点是FIFO（先提交的先执行）
 2.必须在主线程访问 UIKit 的类
 3.并发队列只在异步函数下才有效
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //#基本使用
//    [self test1];
    
    
//    //延时执行 dispatch_after()
//    [self test2];

//    //一次性执行 dispatch_once()
//    [self test3];
    
//        //提交
//    //把一项任务提交到队列中多次执行，具体是并行执行还是串行执行由队列本身决定
//    //dispatch_apply不会立刻返回，在执行完毕后才会返回，是同步的调用。
//        [self test4];
    
//    //串行队列
//    [self test5];
    
    
//    //并行队列
//    [self test6];

    
//    //异步函数_并发队列
//    [self test7];
    
    
    
//    //异步函数_串行队列
//    [self test8];
    
    
    //同步函数_串行队列
    [self test9];
    
}


-(void)test1{
    NSLog(@"当前线程: %@", [NSThread currentThread]);
    //获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    //获取全局并发队列
    dispatch_queue_t otherQueue =   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //同步函数(在当前线程中执行,不具备开启新线程的能力)
    dispatch_sync(otherQueue, ^{
        NSLog(@"同步 %@", [NSThread currentThread]);
    });
    
    //异步函数(在另一条线程中执行,具备开启新线程的能力)
    dispatch_async(otherQueue, ^{
        NSLog(@"异步 %@", [NSThread currentThread]);
    });
    
}


-(void)test2{
    
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    
    //GCD延时调用(主线程)(主队列)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"GCD延时(主线程) %@", [NSThread currentThread]);
    });
    
    //GCD延时调用(其他线程)(全局并发队列)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"GCD延时(其他线程) %@", [NSThread currentThread]);
    });
    
}

-(void)test3{
    
    for (NSInteger i = 0; i < 10; i++) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"GCD一次性执行(默认线程是安全的)");
        });
        
    }
    
    //输出:   GCD一次性执行(默认线程是安全的)
    
    /*
     //使用GCD初始化单例
     + (instancetype)sharedManager {
     
     static PhotoManager *sharedPhotoManager = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
     sharedPhotoManager = [[PhotoManager alloc] init];
     });
     
     return sharedPhotoManager;
     }
     */
    
}

-(void)test4{
    //把一项任务提交到队列中多次执行，具体是并行执行还是串行执行由队列本身决定
    //dispatch_apply不会立刻返回，在执行完毕后才会返回，是同步的调用。
    //队列
#if 0
    //任务1,任务2依次执行,所有任务都执行成功后回到主线程 (效率不高)
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //全局并发队列
        for (NSInteger i = 0; i < 5000; i++) {
            NSLog(@"任务1 %@", [NSThread currentThread]);
        }
        
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"任务2 %@", [NSThread currentThread]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //主队列
            NSLog(@"主线程执行(刷新UI) %@", [NSThread currentThread]);
        });
        
    });
#else
    
    //任务1,任务2同时执行,所有任务都执行成功后回到主线程 (效率高)
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    
    //(1)创建一个队列组
    dispatch_group_t group= dispatch_group_create();
    
    //(2)开启任务1
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"任务1 %@", [NSThread currentThread]);
        }
        
    });
    
    //(3)开启任务2
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"任务2 %@", [NSThread currentThread]);
        }
        
    });
    
    //(4)所有任务执行完毕,回到主线程
//    NSLog(@"主线程(刷新UI) %@", [NSThread currentThread]);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSLog(@"主线程(刷新UI) %@", [NSThread currentThread]);
        
    });
    
#endif
}

-(void)test5{
    
//    一个任务执行完毕后，再执行下一个任务
//    主队列是GCD自带的一种特殊的串行队列,放在主队列中的任务,都会放到主线程中执行
    //(1)使用dispatch_queue_create函数创建串行队列
    //参数1: 队列名称
    //参数2: 队列属性 (一般用NULL)
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", NULL);
    
    //(2)使用主队列（跟主线程相关联的队列）
    dispatch_queue_t serialMainQueue = dispatch_get_main_queue();
    
}

-(void)test6{
    
//    多个任务并发执行（自动开启多个线程同时执行任务）
//    并发功能只有在异步（dispatch_async）函数下才有效!!!
//    GCD默认已经提供了全局的并发队列，供整个应用使用，不需要手动创建
    
//    并发队列优先级                                                     快捷值                     优先级
//    DISPATCH_QUEUE_PRIORITY_HIGH                            2                           高
//    DISPATCH_QUEUE_PRIORITY_DEFAULT                      0                      中(默认)
//    DISPATCH_QUEUE_PRIORITY_LOW                           (-2)                         低
//    DISPATCH_QUEUE_PRIORITY_BACKGROUND	     INT16_MIN                     后台
    //(1)使用dispatch_get_global_queue函数获得全局的并发队列
    //参数1: 优先级
    //参数2: 暂时无用参数 (传0)
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

-(void)test7{
//    (开启新线程,并发执行任务)
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"任务1 %@", [NSThread currentThread]);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"任务3 %@", [NSThread currentThread]);
    });
    
    
}

-(void)test8{
    
    //(开启新线程,串行执行任务)
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", NULL);
    
    dispatch_async(serialQueue, ^{
        NSLog(@"任务1 %@", [NSThread currentThread]);
    });
    
    dispatch_async(serialQueue, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    
    dispatch_async(serialQueue, ^{
        NSLog(@"任务3 %@", [NSThread currentThread]);
        
    });
    
}

-(void)test9{
    
    
    //(不会开启新线程,串行执行任务)
    NSLog(@"当前线程 %@", [NSThread currentThread]);
    //创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", NULL);
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务1 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务3 %@", [NSThread currentThread]);
    });
}






























@end
