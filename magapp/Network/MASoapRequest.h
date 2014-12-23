//
//  SNMadgexSoapRequest.h
//  ScienceNews
//
//  Created by Administrator on 4/15/14.
//  Copyright (c) 2014 aaas. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum {
//    SNJobSearchSortOrderStartDate = 1,
//    SNJobSearchSortOrderStartDateDesc = -1,
//    SNJobSearchSortOrderSalary = 2,
//    SNJobSearchSortOrderSalaryDesc = -2,
//    SNJobSearchSortOrderRelevance = 3,
//    SNJobSearchSortOrderRelevanceDesc = -3,
//    SNJobSearchSortOrderProximity = 4,
//    SNJobSearchSortOrderProximityDesc = -4,
//    SNJobSearchSortRandom = 5,
//} SNJobSearchSortOrder;

@class AFHTTPRequestOperation;

@interface MASoapRequest : NSObject

- (void)cancelRequests;
- (void)cancelRequest:(AFHTTPRequestOperation*)operation;
- (instancetype)initStandard;
- (BOOL)hasRequests;

- (AFHTTPRequestOperation*)loginWithUsername:(NSString*)username pass:(NSString*)pas URLString:(NSString*)urlString completionHandler:(void (^) (AFHTTPRequestOperation *request, NSString *sessionID))completionBlock error:(void (^) (NSError *error, id responseData))errorBlock finally:(void (^) (id responseData))finalBlock;
//- (AFHTTPRequestOperation*)getJobsWithCriteria:(SNMadgexSearchCriteria*)criteria page:(int)page count:(int)count order:(NSString*)order completion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;
//
//- (AFHTTPRequestOperation*)updateJob:(SNJob*)job completion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;
//
//- (AFHTTPRequestOperation*)getCategoriesWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;
//
//- (AFHTTPRequestOperation*)getCategoriesHierarchyForCategory:(SNMadgexCategory*)category withCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;
//
//- (AFHTTPRequestOperation*)getLocationsWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;
//
//- (AFHTTPRequestOperation*)getDisciplinesWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock;

@end
