#import "TQLocationConverter.h"
#import <math.h>
#import <stdio.h>
#import <stdlib.h>

#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "Failed: %s (line %d)\n", #condition, __LINE__); exit(1); \
} } while (0)

static BOOL near(CLLocationCoordinate2D a, CLLocationCoordinate2D b) {
    return fabs(a.latitude - b.latitude) < 1e-8 && fabs(a.longitude - b.longitude) < 1e-8;
}

int main(void) {
    @autoreleasepool {
        CLLocationCoordinate2D gps = CLLocationCoordinate2DMake(39.915, 116.404);
        CLLocationCoordinate2D gcj = [TQLocationConverter transformFromWGSToGCJ:gps];
        CHECK(near(gcj, CLLocationCoordinate2DMake(39.91640428150164, 116.41024449916938)));
        CHECK(near([TQLocationConverter transformFromGCJToWGS:gcj], gps));
        CLLocationCoordinate2D bd = [TQLocationConverter transformFromGCJToBaidu:gcj];
        CHECK(near([TQLocationConverter transformFromBaiduToGCJ:bd], gcj));
        CHECK(near([TQLocationConverter transformFromWGSToBaidu:gps], bd));
        CHECK(near([TQLocationConverter transformFromBaiduToWGS:bd], gps));
        CHECK(![TQLocationConverter isLocationOutOfChina:gps]);
        CLLocationCoordinate2D london = CLLocationCoordinate2DMake(51.5074, -0.1278);
        CHECK([TQLocationConverter isLocationOutOfChina:london]);
        // Preserve legacy unrestricted behavior, while the checked mainland policy passes through.
        CHECK(!near([TQLocationConverter transformFromWGSToGCJ:london], london));
        NSError *error = [NSError errorWithDomain:@"previous" code:1 userInfo:nil];
        CLLocationCoordinate2D result = [TQLocationConverter convertCoordinate:london
            from:TQCoordinateSystemWGS84 to:TQCoordinateSystemBD09
            regionPolicy:TQRegionPolicyMainlandChina error:&error];
        CHECK(near(result, london));
        CHECK(error == nil);
        for (NSInteger from = 0; from < 3; from++) {
            for (NSInteger to = 0; to < 3; to++) {
                result = [TQLocationConverter convertCoordinate:CLLocationCoordinate2DMake(NAN, 0)
                    from:(TQCoordinateSystem)from to:(TQCoordinateSystem)to
                    regionPolicy:TQRegionPolicyMainlandChina error:&error];
                CHECK(!CLLocationCoordinate2DIsValid(result));
                CHECK(error.code == TQConversionErrorInvalidCoordinate);
                CHECK([error.domain isEqualToString:TQLocationConverterErrorDomain]);
            }
        }
        for (NSInteger which = 0; which < 3; which++) {
            result = [TQLocationConverter convertCoordinate:gps
                from:(which == 0 ? (TQCoordinateSystem)999 : TQCoordinateSystemWGS84)
                to:(which == 1 ? (TQCoordinateSystem)999 : TQCoordinateSystemGCJ02)
                regionPolicy:(which == 2 ? (TQRegionPolicy)999 : TQRegionPolicyMainlandChina) error:&error];
            CHECK(!CLLocationCoordinate2DIsValid(result));
            CHECK(error.code == TQConversionErrorInvalidOption);
        }
        result = [TQLocationConverter convertCoordinate:CLLocationCoordinate2DMake(90, 100)
            from:TQCoordinateSystemWGS84 to:TQCoordinateSystemGCJ02
            regionPolicy:TQRegionPolicyUnrestricted error:&error];
        CHECK(!CLLocationCoordinate2DIsValid(result));
        CHECK(error.code == TQConversionErrorInvalidResult);
        CHECK(!CLLocationCoordinate2DIsValid([TQLocationConverter transformFromGCJToWGS:CLLocationCoordinate2DMake(INFINITY, 0)]));
        CHECK([TQLocationConverter isLocationOutOfChina:kCLLocationCoordinate2DInvalid]);
        puts("Objective-C: legacy APIs, checked errors, region behavior and manual integration passed.");
    }
    return 0;
}
