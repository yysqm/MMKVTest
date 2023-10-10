//
//  Cache.h
//  MMKV-Test
//
//  Created by 岳云石 on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cache : NSObject

+ (void)storageObject:(id)data filePath:(nullable NSString *)filePath;

+ (NSObject *)loadObjectWithFilePath:(nullable NSString *)filePath;

+ (NSString *)cacheStoragePathWithFileName:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
