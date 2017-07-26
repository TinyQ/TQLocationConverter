TQLocationConverter
===================

## Location converter

Used to convert different coordinate system standards to each other

(GCJ-02 Mars coordinates)

(WGS-84 normal GPS coordinates)

(Baidu coordinates)


## How to use


```objective-c

    // latitiude and longitude
    CLLocationCoordinate2D location = (CLLocationCoordinate2D){
        .latitude  = 0.0,
        .longitude = 0.0
    };
    
    // determine if in China
    if (![TQLocationConverter isLocationOutOfChina:location])
    {
        // convert WGS-84 to GCJ-02 (Mars coordinates)
        location = [TQLocationConverter transformFromWGSToGCJ:location];
        
        // convert GCJ-02 (Mars coordinates) into Baidu coordinates
        location = [TQLocationConverter transformFromGCJToBaidu:location];
        
        // convert Baidu coordinates into GCJ-02 (Mars coordinates)
        location = [TQLocationConverter transformFromBaiduToGCJ:location];
        
        // convert GCJ-02 (Mars coordinates) to WGS-84 (normal GPS coordinates)
        location = [TQLocationConverter transformFromGCJToWGS:location];
    }
    
    NSLog(@"%f,%f",location.latitude,location.longitude);
    
```
