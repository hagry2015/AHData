//
//  AHData.h.h
//
//  Created by Amr El-Hagry on 1/31/16.
//  Copyright © 2016 Xcode Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface AHData : NSObject

-(BOOL) createDB:(NSString*)databaseName;
-(BOOL) saveRecord:(NSString*)databaseName withStmt:(NSString*)stmt;
-(BOOL) deleteRecord:(NSString*)databaseName withStmt:(NSString*)stmt;

-(BOOL) createTable:(NSString*)databaseName withStmt:(NSString*)stmt;
-(NSArray*) fetch:(NSString*)databaseName withStmt:(NSString*)stmt;
@end
