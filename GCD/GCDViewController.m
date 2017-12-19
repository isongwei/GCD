
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
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

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
    

    //当有多个处理, 想全部结束后进行处理, 就需要用这个
    //如果只有一个 serial queue 队列  可以实现
    //但是如果有多个  就不行了
    
    //现在可以进行  全部加到一个group中
    
    dispatch_queue_t queue20 = dispatch_get_global_queue(0, 0);
    dispatch_group_t  group = dispatch_group_create();
    
    
    dispatch_group_async(group, queue20, ^{
        NSLog(@"0");
    });
    dispatch_group_async(group, queue20, ^{
        NSLog(@"1");
    });
    
    dispatch_group_async(group, queue20, ^{
        NSLog(@"2");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //无论是并行还是串行  队列加处理
        
        //一旦执行结束就会加上这个处理
        
        NSLog(@"一定最后执行");
    });
    
    //顺序是乱序
    //带create 所需要 release
    dispatch_release(group);
    
    
    
    
#pragma mark - ===============dispatch_group_wait===============
    
    dispatch_queue_t  queue21 = dispatch_get_global_queue(0, 0  );
    dispatch_group_t  group1 = dispatch_group_create();
    
    dispatch_group_async(group1, queue21, ^{
        NSLog(@"0");
    });
    dispatch_group_async(group1, queue21, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group1, queue21, ^{
        NSLog(@"2");
    });
    
    
    //DISPATCH_TIME_FOREVER
    //只要属于该group的处理没有执行完就一直等待下去
    //因为一直等
    dispatch_group_wait(group1, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group1);
    
    
    dispatch_time_t time1 = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    
    
    long result = dispatch_group_wait(group1, time1);
    
    
    //经过指定时间后
    if (result == 0) {
        //属于该group 的全部执行完毕
    }else{
        //属于该group的还在执行中
    }
    
    
    
    //直接判断是否执行结束
    //不过可以直接使用notify
    long result1= dispatch_group_wait(group1, DISPATCH_TIME_NOW);
    
    
    
#pragma mark - ===============dispatch_barrier_async===============
    
    //前面的serial  可以避免数据竞争问题
    //但是如果只是读取的并行问题则可以  所以为了高效的读取  可以放到  concurrent queue
    
    
    //也就是读取追加到concurrent中
    //也就是写入追加到serial中
    
    //现在有更快捷方便的方法
    dispatch_queue_t queue30 = dispatch_queue_create("com.zsw.sss", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue30, ^{
        NSLog(@"reading0");
    });
    dispatch_async(queue30, ^{
        NSLog(@"reading1");
    });
    dispatch_async(queue30, ^{
        NSLog(@"reading2");
    });
    dispatch_async(queue30, ^{
        NSLog(@"reading3");
    });
    dispatch_async(queue30, ^{
        NSLog(@"reading4");
    });
    
    if (1) {
        dispatch_async(queue30, ^{NSLog(@"wtiting4.5");});
    }else{
        //此函数  会等待追加到 此queue上的并行执行的处理全部结束之后
        //再将制定的处理追加带此queue中
        //然后再由此函数 追加的处理执行完毕后
        //queue才恢复为一般的动作  追加到此queue的处理又开始执行
        
        //就是
        //前面和后面都是
        //并发
        
        dispatch_barrier_async(queue30, ^{ NSLog(@"writing4.5");});
    }
    
    
    dispatch_async(queue30, ^{
        NSLog(@"reading5");
    });
    dispatch_async(queue30, ^{
        NSLog(@"reading6");
    });
    
    dispatch_release(queue30);
    
    
    //如果在3 4 之间加入写入处理  那么根据并发的特性将会造成 读取到数据不符的情况
    //还有可能导致异常直接结束  如果追加多个写入就会发生更多问题  如数据竞争等
    
#pragma mark =============dispatch_sync=============
    //   dispatch_async 不做任何等待

    //   dispatch_sync 等待  就是同步追加到指定的queue上
    
    //就像上面的wait
    //等待就是当前线程停止
    
    //比如当前情况
    //执行  main queue 时   使用另外的线程global queue处理时,处理后  立即使用所得到的结果
    //这时可以使用 同步函数 (这不就是   主线程刷新)
    
    dispatch_queue_t  queue40 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue40, ^{
        
    //处理
    });
    //一旦调用该函数  那么在指定的处理执行结束之前 
    //  该函数不会返回
    
    //使用简单但是容易造成死锁
    
    //可以简化该函数  就是简易版的dispatch_group_wait(???)
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        //此代码是在main queue上 执行指定的block 并等待 执行结束
        //而实际 主线程正在执行这些源代码  所以无法追加到 main queue 的block
        
        NSLog(@"造成死锁,互相等待");
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // main queue 上执行的block  等待main queue 中要执行的block 结束  造成死锁
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"造成死锁,互相等待");
        });
    });
    
    
    //当然 serial 也会造成同样的问题
    dispatch_queue_t  queue41 =  dispatch_queue_create("com.zsw.ww", NULL);
    dispatch_async(queue41, ^{
        dispatch_sync(queue41, ^{
            //同一个线程的等待
            //造成死锁
        });
    });
    
    
#pragma mark =============dispatch_apply=============
    
    //这个函数是将同步函数和 group 关联的API
    ///按照指定的次数  将指定的block 追加到指定的queue中  并等待全部处理执行结束
    
    dispatch_queue_t  queue50 = dispatch_get_global_queue(0, 0  );
    
    dispatch_apply(10, queue50, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    
    NSLog(@"done");//(结果是10 个数的随机组合  最后执行done) 因为他会等待执行结束
    
    //可以通过此函数来便利 array
    
    dispatch_apply(@[@"",@"",@"",@"",].count, queue50, ^(size_t index) {
        
        //随机便利
        NSLog(@"%@",@[@"",@"",@"",@"",][index]);
    });
    
    //由于此函数会等待  处理执行结束  因此推荐 在dispatch_async 函数中非同步的 执行dispatch_apply
    
    dispatch_async(queue50, ^{
        dispatch_apply(@[@"",@"",@"",@"",].count, queue50, ^(size_t index) {
            //并列处理 包含在arr 中的全部对象
            NSLog(@"%@",@[@"",@"",@"",@"",][index]);
        });
        
        //处理结束
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            //在主线程中执行  处理
            
            NSLog(@"done");
            
        });
        
        
    });
    
    
#pragma mark =============dispatch_suspend/dispatch_resume=============

    //档有大量处理被追加到queue 中时   在追加处理的过程中   有时希望不执行已经追加的处理
    //
    
    //这种情况下 只要挂起 queue即可  档可以执行时再恢复
    
    
    //dispatch_suspend 函数挂起指定的queue
    //对已经执行的处理没有影响  追加到queue中尚未执行的处理再次之后停止执行
    dispatch_suspend(queue);
    //恢复指定的queue
    //被挂起的继续执行
    dispatch_resume(queue);
    
    
#pragma mark =============Dispatch Semaphone=============
    
    //发生情形
    //当并行执行的处理更新数据时, 会产生数据不一致的情况  有时还会异常结束
    
    //serial 和 dispatch_barrier_async 可以避免该问题 但是还是需要更细粒度的处理
    
    
    //比如下面的一种情况
    //不考虑顺序  将所有数据追加到array中
    
    dispatch_queue_t  queue60 = dispatch_queue_create("com.zsw.zz", DISPATCH_QUEUE_CONCURRENT);
    
    
    
    NSMutableArray * ARR = [NSMutableArray array];
    
    for (int i = 0 ; i < 10000; i ++) {
        dispatch_async(queue60, ^{
            [ARR addObject:[NSNumber numberWithInt:1]];
        });
    }
    
    //因为改代码使用 并行队列 更新arr对象  ,  所以执行后由内存错误导致应用程序一场结束的概率很高
    //此时就应当使用Dispatch Semaphone
    
    
    //Dispatch Semaphone 是持有计数的信号
    //该计数是多线程编程中的技术类型信号
    //计数为0时等待    计数为1或大于1时减去1 而不等待
    
    //用法
    
    //计数初始值为 1
    dispatch_semaphore_t semaphone = dispatch_semaphore_create(1);
    
    
    
    //dispatch_semaphore_wait 函数等待semaphone 的数值达到大于或等于1
    
    
    //当计数值大于等于1,  或者在待机中计数值大于等于1 时   对该计数进行减法并从 dispatch_semaphone_wait 函数返回
    //第二个参数 与dispatch_group_wait 函数相同
    //由dispatch_time_t 指定等待时间
    //另外其返回值  也与group_wait相似
    //可以通过返回值进行分别处理
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    

    dispatch_time_t time2 = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
    long result2 = dispatch_semaphore_wait(semaphone, time2);
    
    if (result2 == 0) {
        //由于semaphore 的数值大于等于1
        //或者在待机中的指定时间内
        
        //disoatch semaphore 的计数值减去1
        //可执行需要进行排他控制的处理
        
    }else{
        //由于semaphore的计数值为0
        //因此到达指定时间  等待
        
    }
    
    //到实际情况下进行查看
    
    dispatch_semaphore_t  semaphore = dispatch_semaphore_create(1);
    NSMutableArray * array = [NSMutableArray array];
    
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue60, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            //由于是大于1的 所以执行
            [array addObject:[NSNumber numberWithInt:1]];
            //加一个信号
            dispatch_semaphore_signal(semaphore);
            
        });
    }
    
    //之后进行释放
    dispatch_release(semaphore);
    
    //在没有 Serial dispatch queue和 dispatch barrier async函数那么大粒度且一部分处理需要进行排他控制的情况下, Dispatch semaphore便可发挥威力。
    

    
#pragma mark =============dispatch_once=============
    
    //只执行一次的API
    static int initialized = NO;
    if (initialized == NO) {
        //初始化
        initialized = YES;
    }
    
    //如果 once
    //即使在多线程下执行也是百分百安全
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        //初始化
    });
    
#pragma mark =============Dispatch I/O=============
///如果文件较大可以分割成较小文件进行读取
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ NSLog(@"reading1") ;});
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ NSLog(@"reading2"); });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ NSLog(@"reading3") ;});
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ NSLog(@"reading4"); });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ NSLog(@"reading5"); });
    
    
    
    
    
}



@end
