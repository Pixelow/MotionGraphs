//
//  APLDocument.m
//  MotionGraphs
//
//  Created by Msm on 11/06/2017.
//
//

#import "APLDocument.h"

@implementation APLDocument

//重写父类方法

/*
 保存时调用该方法
 typeName：文档文件类型后缀
 outError：错误信息输出
 @return：文档数据
 */
- (id)contentsForType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError{
    if (self.data) {
        return [self.data copy];
    }
    return [NSData data];
}

/*
 读取时调用该方法
 contents：文档数据
 typeName：文档文件类型后缀
 outError：错误信息输出
 return：读取是否成功
 */
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError{
    NSData *theData = contents;
    self.data = theData;
    return true;
}

@end
