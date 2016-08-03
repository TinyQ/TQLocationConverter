//
//  ViewController.m
//  Test
//
//  Created by qfu on 8/3/16.
//  Copyright © 2016 qfu. All rights reserved.
//

#import "ViewController.h"
#import "TQLocationConverter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test1];
    [self test2];
    [self test3];
}

- (void)test1
{
    NSLog(@"Test1");
    
    //我是个经纬度
    CLLocationCoordinate2D location = (CLLocationCoordinate2D){
        .latitude  = 39.7398995536,
        .longitude = 116.4761557871
    };
    
    NSLog(@"原始坐标 %f,%f",location.latitude,location.longitude);
    
    CLLocationCoordinate2D result1;
    CLLocationCoordinate2D result2;
    
    //将WGS-84转为GCJ-02(火星坐标)
    result1 = [TQLocationConverter transformFromWGSToGCJ:location];
    NSLog(@"WGS-84 to 火星 %f,%f,",result1.latitude,result1.longitude);
    //将GCJ-02(火星坐标)转为WGS-84
    result2 = [TQLocationConverter transformFromGCJToWGS:result1];
    NSLog(@"火星 to WGS-84 %f,%f,",result2.latitude,result2.longitude);
    NSLog(@"\n");
}

- (void)test2
{
    NSLog(@"Test2");
    
    //我是个经纬度
    CLLocationCoordinate2D location = (CLLocationCoordinate2D){
        .latitude  = 39.7398995536,
        .longitude = 116.4761557871
    };
    
    NSLog(@"原始坐标 %f,%f",location.latitude,location.longitude);
    
    CLLocationCoordinate2D result1;
    CLLocationCoordinate2D result2;
    
    //将GCJ-02(火星坐标)转为百度坐标
    result1 = [TQLocationConverter transformFromGCJToBaidu:location];
    NSLog(@"GCJ-02 to baidu %f,%f,",result1.latitude,result1.longitude);
    
    //将百度坐标转为GCJ-02(火星坐标)
    result2 = [TQLocationConverter transformFromBaiduToGCJ:result1];
    NSLog(@"baidu to GCJ-02 %f,%f,",result2.latitude,result2.longitude);
    NSLog(@"\n");
}

- (void)test3
{
    NSLog(@"Test3");
    
    //我是个经纬度
    CLLocationCoordinate2D location = (CLLocationCoordinate2D){
        .latitude  = 39.7398995536,
        .longitude = 116.4761557871
    };
    
    NSLog(@"原始坐标 %f,%f",location.latitude,location.longitude);
    
    CLLocationCoordinate2D result1;
    CLLocationCoordinate2D result2;
    
    //将GCJ-02(火星坐标)转为WGS-84
    result1 = [TQLocationConverter transformFromGCJToWGS:location];
    NSLog(@"GCJToWGS %f,%f,",result1.latitude,result1.longitude);
    
    //将WGS-84(火星坐标)转为GCJ-02
    result2 = [TQLocationConverter transformFromWGSToGCJ:result1];
    NSLog(@"WGSToGCJ %f,%f,",result2.latitude,result2.longitude);
    NSLog(@"\n");
}

@end
