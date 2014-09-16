TQLocationConverter
===================

Converter location to WGS-84 GCJ-02 


##How to use


```objective-c

    //我是个经纬度
    CLLocationCoordinate2D location = (CLLocationCoordinate2D){
        .latitude = 0.0,
        .longitude =0.0
    };
    
    //判断是否在中国
    if ([TQLocationConverter isLocationOutOfChina:location])
    {
        //将WGS-84转为GCJ-02(火星坐标)
        location = [TQLocationConverter transformFromBaiduToGCJ:location];
        
        //将GCJ-02(火星坐标)转为百度坐标
        location = [TQLocationConverter transformFromGCJToBaidu:location];
        
        //将百度坐标转为GCJ-02(火星坐标)
        location = [TQLocationConverter transformFromBaiduToGCJ:location];
        
        //将GCJ-02(火星坐标)转为WGS-84
        location = [TQLocationConverter transformFromGCJToWGS:location];
    }
    
    NSLog(@"%f,%f",location.latitude,location.longitude);
    
```
