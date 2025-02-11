//
//  CoreDataHelper.m
//  graduate
//
//  Created by luck-mac on 15/1/26.
//  Copyright (c) 2015年 nju.excalibur. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper
@synthesize managedObjectModel=_managedObjectModel;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

CoreDataHelper* coreDataHelper = nil;

+(CoreDataHelper *)getInstance
{
    @synchronized(self){
        if(coreDataHelper == nil){
            coreDataHelper = [[self alloc] init];
        }
    }
    return coreDataHelper;
}


//托管对象
-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel!=nil) {
        return _managedObjectModel;
    }
    _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:nil] ;
    for (NSEntityDescription *desc in _managedObjectModel.entities)
    {
        NSLog(@"%@",desc.name);
    }
    return _managedObjectModel;
}
//托管对象上下文
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext!=nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator* coordinator=[self persistentStoreCoordinator];
    if (coordinator!=nil) {
        _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//持久化存储协调器
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator!=nil) {
        return _persistentStoreCoordinator;
    }
    //    NSURL* storeURL=[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreaDataExample.CDBStore"];
    //    NSFileManager* fileManager=[NSFileManager defaultManager];
    //    if(![fileManager fileExistsAtPath:[storeURL path]])
    //    {
    //        NSURL* defaultStoreURL=[[NSBundle mainBundle] URLForResource:@"CoreDataExample" withExtension:@"CDBStore"];
    //        if (defaultStoreURL) {
    //            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
    //        }
    //    }
    NSString* docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSURL* storeURL=[NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"CoreDataExample.sqlite"]];
    NSLog(@"path is %@",storeURL);
    NSError* error=nil;
    _persistentStoreCoordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    return _persistentStoreCoordinator;
}


+ (NSArray*) query:(id)sender tableName:(NSString*)tableName
{
    CoreDataHelper* helper = [CoreDataHelper getInstance];
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* trace=[NSEntityDescription entityForName:tableName inManagedObjectContext:helper.managedObjectContext];
    [request setEntity:trace];
    if (sender) {
        [request setPredicate:sender];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"myDay" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[helper.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
   
    if (mutableFetchResult==nil) {
        NSLog(@"Error:%@",error);
    }
    NSLog(@"The count of %@ entry: %i",tableName,[mutableFetchResult count]);
    return mutableFetchResult;
}


@end
