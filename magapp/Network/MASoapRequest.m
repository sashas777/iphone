//
//  SNMadgexSoapRequest.m
//  ScienceNews
//
//  Created by Administrator on 4/15/14.
//  Copyright (c) 2014 aaas. All rights reserved.
//

#import "MASoapRequest.h"
#import "AFNetworking.h"
#import "TBXML.h"
#import "MANetworkActivityWatcher.h"
#import "TBXML+NSDictionary.h"
#import "NVJSON.h"

@interface MASoapRequestSerializer : AFHTTPResponseSerializer

@end

@implementation MASoapRequestSerializer

+ (instancetype)serializer {
    MASoapRequestSerializer *serializer = [[self alloc] init];
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error) {
            return nil;
        }
    }
    TBXML *xml = [TBXML newTBXMLWithXMLData:data error:nil];
    NSDictionary *responseDict = [TBXML dictionaryWithXMLNode:xml.rootXMLElement];
    NSDictionary *envelope = [responseDict objectForKey:@"SOAP-ENV:Envelope"];
    NSDictionary *envelopeBody = nil;
    if ([envelope isKindOfClass:[NSDictionary class]]) {
        envelopeBody = [envelope objectForKey:@"SOAP-ENV:Body"];
        if ([envelopeBody isKindOfClass:[NSDictionary class]]) {
            NSDictionary *errorDict = [envelopeBody objectForKey:@"SOAP-ENV:Fault"];
            if ([errorDict isKindOfClass:[NSDictionary class]]) {
                *error = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:[errorDict jsonIntegerForKey:@"faultcode"] userInfo:@{@"message": [errorDict jsonStringForKey:@"faultstring"]}];
            }
        } else {
            *error = [NSError errorWithDomain:AFURLResponseSerializationErrorDomain code:666 userInfo:@{@"message": NSLocalizedString(@"Unexpected server error", nil)}];
        }
    }
    return envelopeBody;
}

@end

@interface MASoapRequest ()

@property (nonatomic, strong) NSMutableArray *requests;

@end

@implementation MASoapRequest

- (instancetype)initStandard {
    if (self = [super init]) {
        self.requests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)cancelRequests {
    for (AFHTTPRequestOperation *operation in self.requests) {
        [operation cancel];
    }
    [self.requests removeAllObjects];
}

- (void)cancelRequest:(AFHTTPRequestOperation*)operation {
    [operation cancel];
    [self.requests removeObject:operation];
}

- (void)dealloc {
    [self cancelRequests];
}

- (BOOL)hasRequests {
    return self.requests.count > 0;
}

- (AFHTTPRequestOperation*)performRequest:(NSString*)method body:(NSString*)body URLString:(NSString*)urlString completionHandler:(void (^) (AFHTTPRequestOperation *request, id responseData))completionBlock error:(void (^) (NSError *error, id responseData))errorBlock finally:(void (^) (id responseData))finalBlock {
    NSString *fullBody = [NSString stringWithFormat:
                          @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
                          "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:typens=\"urn:Magento\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\" xmlns:tns=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" >"
                          "<SOAP-ENV:Body>"
                          "<mns:%@ xmlns:mns=\"urn:Magento\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">%@</mns:%@>"
                          "</SOAP-ENV:Body></SOAP-ENV:Envelope>", method, body, method];
    NSData *bodyData = [fullBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/index.php/api/v2_soap/index/", urlString]];
    NSMutableURLRequest *reqest = [[NSMutableURLRequest alloc] initWithURL:currentURL];
    [reqest setHTTPMethod:@"POST"];
    [reqest addValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [reqest addValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    [reqest setHTTPBody:bodyData];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:reqest];
    operation.responseSerializer = [MASoapRequestSerializer serializer];
    [self.requests addObject:operation];
    __weak MASoapRequest *weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[MANetworkActivityWatcher sharedWatcher] decrementActivity];
        [weakSelf.requests removeObject:operation];
        if (completionBlock) {
            completionBlock(operation, responseObject);
        }
        if (finalBlock) {
            finalBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[MANetworkActivityWatcher sharedWatcher] decrementActivity];
        [weakSelf.requests removeObject:operation];
        if (errorBlock && !operation.isCancelled) {
            errorBlock(error, operation.responseString);
        }
        if (finalBlock) {
            finalBlock(error);
        }
    }];
    [operation start];
    [[MANetworkActivityWatcher sharedWatcher] incrementActivity];
    return operation;
}

#pragma mark - API calls

- (AFHTTPRequestOperation*)loginWithUsername:(NSString*)username pass:(NSString*)pass URLString:(NSString*)urlString completionHandler:(void (^) (AFHTTPRequestOperation *request, NSString *sessionID))completionBlock error:(void (^) (NSError *error, id responseData))errorBlock finally:(void (^) (id responseData))finalBlock {
    NSString *body = [NSString stringWithFormat:
                      @"<username xsi:type=\"xsd:string\">%@</username>"
                      "<apiKey xsi:type=\"xsd:string\">%@</apiKey>", username, pass];
    return [self performRequest:@"login" body:body URLString:urlString completionHandler:^(AFHTTPRequestOperation *request, NSDictionary *responseData) {
        NSDictionary *loginData = [responseData objectForKey:@"ns1:loginResponse"];
        NSString *session = nil;
        if ([loginData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *value = [loginData objectForKey:@"loginReturn"];
            if ([value isKindOfClass:[NSDictionary class]]) {
                session = [value jsonStringForKey:@"text"];
            }
        }
        if (completionBlock) {
            completionBlock(request, session);
        }
    } error:errorBlock finally:finalBlock];
}
//
//- (AFHTTPRequestOperation*)getJobsWithCriteria:(SNMadgexSearchCriteria*)criteria page:(int)page count:(int)count order:(NSString*)order completion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//    NSString *body = [NSString stringWithFormat:
//                      @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                      "<soap:Body>"
//                      "<GetJobs xmlns=\"http://jobboard.webservice.madgex.co.uk\">"
//                      "<uiSecurityToken>%@</uiSecurityToken>"
//                      "<searchCriteria>%@</searchCriteria>"
//                      "<sortOrder>%@</sortOrder>"
//                      "<pageSize>%d</pageSize>"
//                      "<pageNumber>%d</pageNumber>"
//                      "</GetJobs>"
//                      "</soap:Body>"
//                      "</soap:Envelope>", [SNMadgexToken sharedToken].tokenValue, criteria, order, count, page];
//    return [self performRequest:@"GetJobs" body:body completionHandler:^(NSURLRequest *request, id response) {
//        NSMutableArray *jobs = [NSMutableArray array];
//        TBXML *xml = [TBXML newTBXMLWithXMLData:response error:nil];
//        TBXMLElement *firstResult = xml.rootXMLElement->firstChild->firstChild->firstChild->firstChild;
//        if (firstResult) {
//            do {
//                SNJob *job = [[SNJob alloc] initWithXML:firstResult];
//                [jobs addObject:job];
//            } while ((firstResult = firstResult->nextSibling));
//        }
//        completionBlock(request, jobs);
//    } error:errorBlock finally:finalBlock];
//}
//
//- (AFHTTPRequestOperation*)updateJob:(SNJob*)job completion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//    NSString *body = [NSString stringWithFormat:
//                      @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                      "<soap:Body>"
//                      "<GetJobDetails xmlns=\"http://jobboard.webservice.madgex.co.uk\">"
//                      "<uiSecurityToken>%@</uiSecurityToken>"
//                      "<jobID>%lld</jobID>"
//                      "</GetJobDetails>"
//                      "</soap:Body>"
//                      "</soap:Envelope>", [SNMadgexToken sharedToken].tokenValue, job.jobID];
//    __weak SNJob *weakJob = job;
//    return [self performRequest:@"GetJobDetails" body:body completionHandler:^(NSURLRequest *request, id responseData) {
//        TBXML *xml = [TBXML newTBXMLWithXMLData:responseData error:nil];
//        TBXMLElement *firstResult = xml.rootXMLElement->firstChild->firstChild->firstChild;
//        if (firstResult) {
//            [weakJob updateDetailsWithXML:firstResult];
//        }
//        completionBlock(request, weakJob);
//    } error:errorBlock finally:finalBlock];
//}
//
//- (AFHTTPRequestOperation*)getCategoriesWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//    NSString *body = [NSString stringWithFormat:
//                      @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                      "<soap:Body>"
//                      "<GetCategories xmlns=\"http://jobboard.webservice.madgex.co.uk\">"
//                      "<uiSecurityToken>%@</uiSecurityToken>"
//                      "</GetCategories>"
//                      "</soap:Body>"
//                      "</soap:Envelope>", [SNMadgexToken sharedToken].tokenValue];
//    return [self performRequest:@"GetCategories" body:body completionHandler:^(NSURLRequest *request, id response) {
//        TBXML *xml = [TBXML newTBXMLWithXMLData:response error:nil];
//        TBXMLElement *firstCategory = xml.rootXMLElement->firstChild->firstChild->firstChild->firstChild;
//        NSMutableDictionary *categories = [NSMutableDictionary dictionary];
//        if (firstCategory) {
//            do {
//                SNMadgexCategory *cat = [[SNMadgexCategory alloc] initWithXML:firstCategory];
//                [categories setObject:cat forKey:cat.name];
//            } while ((firstCategory = firstCategory->nextSibling));
//        }
//        completionBlock(request, categories);
//    } error:errorBlock finally:finalBlock];
//}
//
//- (AFHTTPRequestOperation*)getCategoriesHierarchyForCategory:(SNMadgexCategory*)category withCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//    NSString *body = [NSString stringWithFormat:
//                      @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                      "<soap:Body>"
//                      "<GetHeirarchicalCategoryTerms xmlns=\"http://jobboard.webservice.madgex.co.uk\">"
//                      "<uiSecurityToken>%@</uiSecurityToken>"
//                      "<sCategoryID>%@</sCategoryID>"
//                      "</GetHeirarchicalCategoryTerms>"
//                      "</soap:Body>"
//                      "</soap:Envelope>", [SNMadgexToken sharedToken].tokenValue, [NSString stringWithFormat:@"%d", category.objectID]];
//    return [self performRequest:@"GetHeirarchicalCategoryTerms" body:body completionHandler:^(NSURLRequest *request, id responseData) {
//        TBXML *xml = [TBXML newTBXMLWithXMLData:responseData error:nil];
//        TBXMLElement *firstLocation = xml.rootXMLElement->firstChild->firstChild->firstChild->firstChild;
//        NSMutableArray *locations = [NSMutableArray array];
//        if (firstLocation) {
//            do {
//                SNMadgexSearchTerm *term = [[SNMadgexSearchTerm alloc] initWithXML:firstLocation];
//                term.termName = category.name;
//                [locations addObject:term];
//            } while ((firstLocation = firstLocation->nextSibling));
//        }
//        completionBlock(request, locations);
//    } error:errorBlock finally:finalBlock];
//}
//
//- (AFHTTPRequestOperation*)getLocationsWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//        return [self getCategoriesHierarchyForCategory:[[SNMadgexCategoriesStorage sharedStorage] categoryWithName:MADGEX_LOCATION_TERM_NAME] withCompletion:completionBlock error:errorBlock finally:finalBlock];
//}
//
//- (AFHTTPRequestOperation*)getDisciplinesWithCompletion:(SNNetworkRequestSuccessBlock)completionBlock error:(SNNetworkRequestErrorBlock)errorBlock finally:(SNNetworkRequestFinalBlock)finalBlock {
//    return [self getCategoriesHierarchyForCategory:[[SNMadgexCategoriesStorage sharedStorage] categoryWithName:MADGEX_DISCIPLINE_TERM_NAME] withCompletion:completionBlock error:errorBlock finally:finalBlock];
//}

@end
