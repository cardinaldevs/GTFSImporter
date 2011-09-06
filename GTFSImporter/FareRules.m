//
//  FareRules.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Adobe Systems Inc. All rights reserved.
//

#import "FareRules.h"
#import "CSVParser.h"
#import "FMDatabase.h"


@implementation FareRules
@synthesize fare_id,route_id,origin_id,destination_id,contains_id;

- (id) initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
		db = [fmdb retain];
	}
	return self;
}

- (void)addFareRules:(FareRules *)value {
    if (db==nil) {
        db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                                           stringByAppendingPathComponent:@"vta_gtfs.db"]];
        if (![db open]) {
            NSLog(@"Could not open db.");
            [db release];
            return;
        }
    }
    
    [db executeUpdate:@"INSERT into fare_rules(fare_id,route_id,origin_id,destination_id,contains_id) values(?, ?, ?, ?, ?)",
     value.fare_id,
     value.route_id,
     value.origin_id,
     value.destination_id,
     value.contains_id];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
}

- (void) cleanupAndCreate
{
    if (db==nil) {
        db = [FMDatabase databaseWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                                           stringByAppendingPathComponent:@"vta_gtfs.db"]];
        if (![db open]) {
            NSLog(@"Could not open db.");
            [db release];
            return;
        }
    }
    
    //Drop table if it exists
    NSString *drop = @"DROP TABLE IF EXISTS fare_rules";
    
    [db executeUpdate:drop];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'fare_rules' ('fare_id' INT(11) NOT NULL, 'route_id' INT(11) NOT NULL, 'origin_id' INT(11) NOT NULL, 'destination_id' INT(11) NOT NULL, 'contains_id' INT(11) NOT NULL)";
    
    [db executeUpdate:create];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
}

- (void) receiveRecord:(NSDictionary *)aRecord
{
    FareRules *fareRulesRecord = [[[FareRules alloc] init] autorelease];
    [fareRulesRecord setValuesForKeysWithDictionary:aRecord];
    [self addFareRules:fareRulesRecord];
}

- (void) dealloc
{
    [db release];
    [fare_id release];
    [route_id release];
    [origin_id release];
    [destination_id release];
    [contains_id release];
    [super dealloc];
}

@end
