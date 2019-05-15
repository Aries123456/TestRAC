//
//  ViewController.m
//  TestRac
//
//  Created by lk on 2019/5/14.
//  Copyright © 2019 lk. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import <RACReturnSignal.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *zhangHao;
@property (weak, nonatomic) IBOutlet UITextField *miMa;
@property (weak, nonatomic) IBOutlet UIButton *dengLu;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self RAC_Skip];
}

#pragma mark -- RAC 重用方法
#pragma mark -- Skip
//跳过几个数据
- (void)RAC_Skip
{
    RACSubject *sub = [RACSubject subject];
    //跳过几个数据
    [[sub skip:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [sub sendNext:@"1"];
    [sub sendNext:@"2"];
    [sub sendNext:@"3"];
    [sub sendNext:@"4"];
    [sub sendNext:@"5"];
}


#pragma mark -- DistinctUntilChanged
//忽略掉重复数据
- (void)RAC_DistinctUntilChanged
{
    RACSubject *sub = [RACSubject subject];
    //忽略掉重复数据
    [[sub distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [sub sendNext:@"1"];
    [sub sendNext:@"1"];
    [sub sendNext:@"1"];
    [sub sendNext:@"2"];
    [sub sendNext:@"2"];
}

#pragma mark -- TakeUntil
//中间穿插了标记进来,所以原数据就从这里断开了
- (void)RAC_TakeUntil
{
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [subscriber sendNext:@"1"];
//        [subscriber sendNext:@"2"];
//        [subscriber sendNext:@"3"];
//        [subscriber sendNext:@"4"];
//        [subscriber sendNext:@"5"];
//        [subscriber sendNext:@"6"];
//        [subscriber sendCompleted];
//
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"信号销毁了");
//        }];
//    }];
    
    //发送原数据的信号
    RACSubject *sub = [RACSubject subject];
    //发送标记的信号
    RACSubject *signal = [RACSubject subject];
    //给原信号加一个标记
    [[sub takeUntil:signal] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //原数据发送信号
    [sub sendNext:@"1"];
    [sub sendNext:@"2"];
    [sub sendNext:@"3"];
    [sub sendNext:@"4"];
    //中间穿插了标记进来,所以原数据就从这里断开了
//    [signal sendNext:@"随便发一个信号,只是标记"];
    [signal sendCompleted];
    [sub sendNext:@"5"];
    [sub sendNext:@"6"];
}


#pragma mark -- Take TakeLast
//指定从前往后拿几个数据
//指定从后往前拿几个数据 (注意一定要写结束 sendCompleted)
- (void)RAC_Take_TakeLast
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"4"];
        [subscriber sendNext:@"5"];
        [subscriber sendNext:@"6"];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }];
    
    //指定从前往后拿几个数据
//    [[signal take:3] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    
    //指定从后往前拿几个数据 (注意一定要写结束 sendCompleted)
    [[signal takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- Ignor
//忽略
- (void)rac_Ignore
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }];
    
    //因为忽略了 2 所以只能收到 1 和 3
    [[signal ignore:@"2"] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- Filter
//过滤
- (void)RAC_Filter
{
    [[self.zhangHao.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        //value 是过滤条件 返回NO 的时候不发送信号
        return value.length > 5;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark -- CombineLatest
//监听两个输入框
- (void)RAC_CombineLatest
{
    //监听账号密码不为空的时候按钮可以点击
    
    //    [[RACSignal combineLatest:@[self.zhangHao.rac_textSignal,self.miMa.rac_textSignal]]subscribeNext:^(RACTuple *x) {
    //        NSString *str1 = x[0];
    //        NSString *str2 = x[1];
    //        if (str1.length > 0 && str2.length > 0) {
    //            self.dengLu.enabled = YES;
    //        }else
    //        {
    //            self.dengLu.enabled = NO;
    //        }
    //    }];
    
    
    //    [[RACSignal combineLatest:@[self.zhangHao.rac_textSignal,self.miMa.rac_textSignal] reduce:^id _Nullable(NSString *zhanghao,NSString *mima){
    //        return @(zhanghao.length && mima.length);
    //    }] subscribeNext:^(id  _Nullable x) {
    //        self.dengLu.enabled = [x boolValue];
    //    }] ;
    
    RACSignal *signal = [RACSignal combineLatest:@[self.zhangHao.rac_textSignal,self.miMa.rac_textSignal] reduce:^id _Nullable(NSString *zhanghao,NSString *mima){
        return @(zhanghao.length && mima.length);
    }];
    RAC(self.dengLu,enabled) = signal;
}


#pragma mark -- Zip ZipWith
//将两个信号压缩为一个信号然后发送出去,接受到的是一个元祖,解析元祖能拿到所有的信号值
- (void)RAC_ZipWith
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 1 销毁了");
        }];
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 2"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 2 销毁了");
        }];
    }];
    
    RACSignal *signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 3 销毁了");
        }];
    }];
    
    RACSignal *signal4 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 4"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 4 销毁了");
        }];
    }];
    
    RACSignal *newSignal = [RACSignal zip:@[signal4,signal3,signal2,signal1]];
//    RACSignal *newSignal = [signal1 zipWith:signal2];
    [newSignal subscribeNext:^(RACTwoTuple *x) {
        NSLog(@"%@",x);
    }];

}


#pragma mark -- Merge
//组合信号
- (void)RAC_Merge
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 1 销毁了");
        }];
    }];

    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 2"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 2 销毁了");
        }];
    }];

    RACSignal *signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 3 销毁了");
        }];
    }];

    RACSignal *signal4 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送了数据 4"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 4 销毁了");
        }];
    }];
    
    RACSignal *newSignal = [RACSignal merge:@[signal4,signal2,signal1,signal3]];
    [newSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- Then
//信号 2 依赖信号 1  ,信号 1 执行完之后执行信号 2,只关心信号 2 的结果,信号 1 的值忽略掉了
- (void)RAC_Then
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 1 发送数据了"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 1 销毁了");
        }];
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 2 发送数据了"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 2 销毁了");
        }];
    }];
    
    RACSignal *signal = [signal1 then:^RACSignal * _Nonnull{
        return signal2;
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- Concat
//组合信号
- (void)RAC_Concat
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 1 发送数据了"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 1 销毁了");
        }];
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 2 发送数据了"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 2 销毁了");
        }];
    }];
    
    RACSignal *signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 3 发送数据了"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 3 销毁了");
        }];
    }];
    
//    RACSignal *concatSignal = [[signal3 concat:signal2] concat:signal1];
    RACSignal *concatSignal = [RACSignal concat:@[signal2,signal3,signal1]];

    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- Map
//映射处理数据
- (void)RAC_Map
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送原始数据"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }];
    
    [[signal map:^id _Nullable(id  _Nullable value) {
        return [NSString stringWithFormat:@"处理过后的值--%@",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark -- FlattenMap
//映射处理数据
- (void)RAC_FlattenMap
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送原始数据"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号释放了");
        }];
    }];
    
    RACSignal *bindSignal = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        value = [NSString stringWithFormat:@"字典转模型--%@",value];
        return [RACReturnSignal return:value];
    }];
    
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
//    [sub sendNext:@"发送原始数据"];
}


#pragma mark -- Bind
//绑定数据
- (void)RAC_Bind
{
    RACSubject *sub = [RACSubject subject];
    
    RACSignal *bingSignal = [sub bind:^RACSignalBindBlock _Nonnull{
        return ^ RACSignal * (id value, BOOL *stop) {
            NSLog(@"原始数据--%@",value);
            return [RACReturnSignal return:[NSString stringWithFormat:@"字典转模型之后的值-->%@",value]];
        };
    }];
    
    [bingSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"来了--%@",x);
    }];
    
    [sub sendNext:@"123"];
}


#pragma mark -- Command
//发送命令
- (void)RAC_Command
{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"-->%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"网络请求完成了,我发送了字典转模型的 model"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [command.executing subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue])
        {
            NSLog(@"正在执行");
        }else
        {
            NSLog(@"已经结束了 || 还没有开始执行");
        }
    }];
    
    [[command execute:@"执行"] subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收到网络请求完传递过来的 model %@",x);
    }];
}


#pragma mark -- LiftSelector
//两个信号都执行完之后拿到值
- (void)RAC_liftSelector
{
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 1 发送数据了"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 1 销毁了");
        }];
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"信号 2 发送数据了"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 2 销毁了");
        }];
    }];
    
    [self rac_liftSelector:@selector(dataWithSignal1:signal2:) withSignals:signal1,signal2, nil];
    
}

- (void)dataWithSignal1:(NSString *)signal1 signal2:(NSString *)signal2
{
    NSLog(@"%@--%@",signal1,signal2);
}

@end
