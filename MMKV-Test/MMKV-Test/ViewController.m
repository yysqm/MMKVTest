//
//  ViewController.m
//  MMKV-Test
//
//  Created by 岳云石 on 2023/9/18.
//



#import "ViewController.h"
#import "Cache.h"
#import "MMKV_Test-Swift.h"
@import MMKV;
@import CocoaLumberjack;

@interface ViewController ()

@property (nonatomic, assign) BOOL canStart;

@property (nonatomic, assign) BOOL testDataHasSetted;

@property (nonatomic, strong) UILabel *lab;

@end

#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canStart = YES;
    self.testDataHasSetted = [[NSUserDefaults standardUserDefaults] boolForKey:@"test"];
    [self.view addSubview:self.lab];
 
// 注释掉init方法会提升数据丢失概率
    [MMKV initializeMMKV:nil logLevel:MMKVLogDebug handler:self];
    
    if (self.testDataHasSetted) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self writeAsyncThread];
        });

        dispatch_async(dispatch_get_main_queue(), ^{
            [self writeMainThread];
        });

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self readAsyncThread];
        });

        dispatch_async(dispatch_get_main_queue(), ^{
            [self readMainThread];
        });
    } else {
        [self controlGroup];
    }
}

- (void)mmkvLogWithLevel:(MMKVLogLevel)level file:(const char *)file line:(int)line func:(const char *)funcname message:(NSString *)message {
    const char *levelDesc = "null";
    switch (level) {
        case MMKVLogDebug:
            levelDesc = "D";
            break;
            case MMKVLogInfo:
            levelDesc = "I";
            break;
        case MMKVLogWarning:
            levelDesc = "W";
            break;
        case MMKVLogError:
            levelDesc = "E";
            break;
        default:
            levelDesc = "N";
            break;
    }
    DDLogInfo(@"[%s] <%s:%d::%s> %@", levelDesc, file, line, funcname, message);
//    NSLog(@"[%s] <%s:%d::%s> %@", levelDesc, file, line, funcname, message);
}

/// 设置对照组数据
- (void)controlGroup
{
    NSString *path = [Cache cacheStoragePathWithFileName:@"Test"];
    [Cache storageObject:@{@"MMKV_OSX.cpp.test123123" : @"MMKV_OSX.cpp.test1223"} filePath:path];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"test"];
}

/// 对照组数据是否丢失
- (void)exception
{
    NSString *path = [Cache cacheStoragePathWithFileName:@"Test"];
    id ret = [Cache loadObjectWithFilePath:path];
    if (![ret isKindOfClass:[NSDictionary class]]) {
        self.canStart = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            //开启提示
            self.lab.text = @"MMKV数据丢失";
            self.lab.textColor = [UIColor redColor];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //开启提示
            self.lab.text = @"MMKV数据正常";
            self.lab.textColor = [UIColor greenColor];
        });
    }
}

int count1 = 0;
- (void)writeAsyncThread
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Test put];
        if (count1 < 10000 && self.canStart) {
            count1++;
            [self exception];
            [self writeAsyncThread];
        }
    });
}

int count2 = 0;
- (void)readAsyncThread
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id ret = [Test get];
        if (ret == nil) {
            self.canStart = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.backgroundColor = [UIColor redColor];
            });
        }
        if (count2 < 10000 && self.canStart) {
            count2++;
            [self exception];
            [self readAsyncThread];
        }
    });
}

int count3 = 0;
- (void)writeMainThread
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [Cache cacheStoragePathWithFileName:[NSString stringWithFormat:@"Test--%d", count3]];
        NSDictionary *dic = @{@"Test" : [NSString stringWithFormat:@"Test--%d", count3]};
        [Cache storageObject:dic filePath:path];
        if (count3 < 10000 && self.canStart) {
            count3++;
            [self exception];
            [self writeMainThread];
        }
    });
}

int count4 = 0;
- (void)readMainThread
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [Cache cacheStoragePathWithFileName:[NSString stringWithFormat:@"Test--%d", count4]];
        id ret = [Cache loadObjectWithFilePath:path];
        [self exception];
        if (count4 < 10000 && self.canStart) {
            count4++;
            [self exception];
            [self readMainThread];
        }
    });
}

- (UILabel *)lab
{
    if (!_lab) {
        _lab = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
        _lab.font = [UIFont systemFontOfSize:25];
    }
    return _lab;
}

@end


