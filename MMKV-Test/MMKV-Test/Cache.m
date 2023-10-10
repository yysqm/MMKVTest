//
//  Cache.m
//  MMKV-Test
//
//  Created by 岳云石 on 2023/9/18.
//

#import "Cache.h"
@import FCFileManager;
@import MMKV;

static MMKV *_defaultDataCacheMMKV;
static NSData *SNB_DATA_CACHE_AES_KEY;

@implementation Cache

+ (MMKV *)mmkv
{
    if (_defaultDataCacheMMKV == nil) {
        _defaultDataCacheMMKV = [MMKV mmkvWithID:@"com.yys.dataCache" cryptKey:self.AESKey];
    }
    return _defaultDataCacheMMKV;
}

+ (NSData *)AESKey
{
    if (SNB_DATA_CACHE_AES_KEY == nil) {
        SNB_DATA_CACHE_AES_KEY = [@"com.yys.aes" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return SNB_DATA_CACHE_AES_KEY;
}

+ (void)storageObject:(id)data filePath:(nullable NSString *)filePath
{
    [self storageObject:data filePath:filePath encrypted:YES];
}

+ (void)storageObject:(id)data filePath:(nullable NSString *)filePath encrypted:(BOOL)encrypted
{
    if ([data conformsToProtocol:@protocol(NSCoding)]) {
        /// 由于旧实现是基于文件存储，故这里优先获取 lastPathComponent 作为 key (节省长度），获取不到在使用完整 filepath
        NSString *key = filePath.lastPathComponent ?: filePath;
        /// mmkv 内部已经加锁保证线程安全，只管使用就行
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
        [self.mmkv setData:archivedData forKey:key];
    }
}

+ (NSObject *)loadObjectWithFilePath:(nullable NSString *)filePath
{
    return [self loadObjectWithFilePath:filePath encrypted:NO];
}

+ (NSObject *)loadObjectWithFilePath:(nullable NSString *)filePath encrypted:(BOOL)encrypted
{
    NSData *data = [self loadDataWithFilePath:filePath encrypted:encrypted];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSData *)loadDataWithFilePath:(nullable NSString *)filePath encrypted:(BOOL)encrypted
{
    __block NSString *key = filePath.lastPathComponent ?: filePath;
    __block NSData *data = [self.mmkv getDataForKey:key];
    return data;
}

+ (NSString *)configsPathWithFileName:(NSString *)filename
{
    NSString *configPath = [[self documentDirectoryPathWithName:@"configs"] stringByAppendingPathComponent:filename];
    return configPath;
}

+ (NSString *)cacheStoragePathWithFileName:(NSString *)filename
{
    NSString *cachePath = [[self cacheDirectoryPathWithName:@"cache"] stringByAppendingPathComponent:filename];
    return cachePath;
}

+ (NSString *)cacheDirectoryPathWithName:(NSString *)name
{
    NSString *cachePath = [FCFileManager pathForCachesDirectoryWithPath:name];
    NSError *error = nil;
    [FCFileManager createDirectoriesForPath:cachePath error:&error];
    if (error) {
    }
    return cachePath;
}

+ (NSString *)documentDirectoryPathWithName:(NSString *)name
{
    NSString *cachePath = [FCFileManager pathForDocumentsDirectoryWithPath:name];
    NSError *error = nil;
    [FCFileManager createDirectoriesForPath:cachePath error:&error];
    [self snb_addSkipBackupAttributeToItemAtPath:cachePath];
    [self snb_addProtectionAttributeAtPath:cachePath];
    if (error) {
    }
    return cachePath;
}

+ (BOOL)snb_addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (BOOL)snb_addProtectionAttributeAtPath:(NSString *)path
{
    NSFileManager *fm = NSFileManager.defaultManager;
    if ([fm fileExistsAtPath:path]) {
        NSDictionary *attributes = [fm attributesOfItemAtPath:path error:nil];
        NSString *fileProtection = [attributes objectForKey:NSFileProtectionKey];
        if ([fileProtection isEqualToString:NSFileProtectionCompleteUntilFirstUserAuthentication] || [fileProtection isEqualToString:NSFileProtectionNone]) {
            return true;
        }
        NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
        [newAttributes setObject:NSFileProtectionCompleteUntilFirstUserAuthentication forKey:NSFileProtectionKey];
        [fm setAttributes:newAttributes ofItemAtPath:path error:nil];
    }
    return true;
}

@end
