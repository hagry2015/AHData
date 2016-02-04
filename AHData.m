//
//  AHData.h
//  
//
//  Created by Amr El-Hagry on 1/31/16.
//  Copyright © 2016 Xcode Developer. All rights reserved.
//

#import "AHData.h"
#import <sqlite3.h>



sqlite3 *database = nil;
sqlite3_stmt *statement = nil;

@implementation AHData
// Create a Database
-(BOOL)createDB:(NSString*)databaseName{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *str=[NSString stringWithFormat:@"%@.db",databaseName];
  NSString  *databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: str]];
    NSLog(@"%@",databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            return isSuccess;
        }
        else
        {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}
// Create a Table
- (BOOL) createTable:(NSString*)databaseName withStmt:(NSString*)statement;
{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *str=[NSString stringWithFormat:@"%@.db",databaseName];
    NSString  *databasePath = [[NSString alloc] initWithString:
                               [docsDir stringByAppendingPathComponent: str]];
    BOOL isSuccess = YES;

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =[statement UTF8String];
            //"create table if not exists studentsDetail (regno integer
           // primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}
// Insert a Record in a Database
-(BOOL) saveRecord:(NSString*)databaseName withStmt:(NSString*)stmt;
{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *str=[NSString stringWithFormat:@"%@.db",databaseName];
    NSString  *databasePath = [[NSString alloc] initWithString:
                               [docsDir stringByAppendingPathComponent: str]];

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"%@",stmt];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}
// Delete a Record from a Database
-(BOOL) deleteRecord:(NSString*)databaseName withStmt:(NSString*)stmt
{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *str=[NSString stringWithFormat:@"%@.db",databaseName];
    NSString  *databasePath = [[NSString alloc] initWithString:
                               [docsDir stringByAppendingPathComponent: str]];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"%@",stmt];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}
// Return an Array of Dictionaries of Data
-(NSArray*) fetch:(NSString*)databaseName withStmt:(NSString*)stmt
{
    int rc;
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    NSString *str=[NSString stringWithFormat:@"%@.db",databaseName];
    NSString  *databasePath = [[NSString alloc] initWithString:
                               [docsDir stringByAppendingPathComponent: str]];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        if ((rc = sqlite3_prepare_v2(database, [stmt UTF8String], -1, &statement, NULL)) != SQLITE_OK)
        {
            NSLog(@"select failed %d: %s", rc, sqlite3_errmsg(database));
        }
    }
    
    NSMutableArray *returnArray = [NSMutableArray array];
    NSInteger columnCount = sqlite3_column_count(statement);
    
    id value;
    
    while ((rc = sqlite3_step(statement)) == SQLITE_ROW) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSInteger i = 0; i < columnCount; i++) {
            NSString *columnName   = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
            switch (sqlite3_column_type(statement, i)) {
                case SQLITE_NULL:
                    value = [NSNull null];
                    break;
                case SQLITE_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, i)];
                    break;
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int64(statement, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(statement, i));
                    break;
                case SQLITE_BLOB:
                {
                    NSInteger length  = sqlite3_column_bytes(statement, i);
                    const void *bytes = sqlite3_column_blob(statement, i);
                    value = [NSData dataWithBytes:bytes length:length];
                    break;
                }
                default:
                    NSLog(@"unknown column type");
                    value = [NSNull null];
                    break;
            }
            dictionary[columnName] = value;
        }
        
        [returnArray addObject:dictionary];
    }
    
    if (rc != SQLITE_DONE) {
        NSLog(@"error returning results %d %s", rc, sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    return returnArray;
}

@end
