// Copyright (c) 2014 TinyQ. MIT License; see LICENSE.
#import "TQLocationConverter.h"
#import <math.h>

NSErrorDomain const TQLocationConverterErrorDomain = @"TQLocationConverterErrorDomain";
static const double TQAxis = 6378245.0;
static const double TQEccentricitySquared = 0.00669342162296594323;
static const double TQInverseTolerance = 1e-9;
static const NSUInteger TQInverseIterationLimit = 24;

// Approximate polygon contributed by songxiaoguang in 2016 (9074f57).
// Keep Sources/TQLocationConverter/ChinaRegion.swift in sync. No UIKit or heap allocation.
static const CLLocationCoordinate2D TQMainlandPolygon[] = {
    {49.1506690000, 87.4150810000},
    {48.3664501790, 85.7527085300},
    {47.0253058185, 85.3847443554},
    {45.2406550000, 82.5214000000},
    {44.8957121295, 79.9392351487},
    {43.1166843846, 80.6751253982},
    {41.8701690000, 79.6882160000},
    {39.2896190000, 73.6171080000},
    {34.2303430000, 78.9155300000},
    {31.0238860000, 79.0627080000},
    {27.9989800000, 88.7028920000},
    {27.1793590000, 88.9972480000},
    {28.0969170000, 89.7331400000},
    {26.9157800000, 92.1615830000},
    {28.1947640000, 96.0986050000},
    {27.4094760000, 98.6742270000},
    {23.9085500000, 97.5703890000},
    {24.0775830000, 98.7846100000},
    {22.1375640000, 99.1893510000},
    {21.1398950000, 101.7649720000},
    {22.2746220000, 101.7281780000},
    {23.2641940000, 105.3708430000},
    {22.7191200000, 106.6954480000},
    {21.9945711661, 106.7256731791},
    {21.4847050000, 108.0200530000},
    {20.4478440000, 109.3814530000},
    {18.6689850000, 108.2408210000},
    {17.4017340000, 109.9333720000},
    {19.5085670000, 111.4051560000},
    {21.2716775175, 111.2514995205},
    {21.9936323233, 113.4625292629},
    {22.1818312942, 113.4258358111},
    {22.2249729295, 113.5913115000},
    {22.4501912753, 113.8946844490},
    {22.5959159322, 114.3623797842},
    {22.4334610000, 114.5194740000},
    {22.9680954377, 116.8326939975},
    {25.3788220000, 119.9667980000},
    {28.3261276204, 121.7724402562},
    {31.9883610000, 123.8808230000},
    {39.8759700000, 124.4695370000},
    {41.7350890000, 126.9531720000},
    {41.5142160000, 128.3145720000},
    {42.9842081790, 131.0676468344},
    {45.2690810000, 131.8468530000},
    {45.0608370000, 133.0610740000},
    {48.4480260000, 135.0111880000},
    {48.0054800000, 131.6628800000},
    {50.2270740000, 127.6890640000},
    {53.3516070000, 125.3710040000},
    {53.4176040000, 119.9254040000},
    {47.5590810000, 115.1421070000},
    {47.1339370000, 119.1159230000},
    {44.8256460000, 111.2786750000},
    {42.5293560000, 109.2549720000},
    {43.2598160000, 97.2967290000},
    {45.4247620000, 90.9680590000},
    {47.8075570000, 90.6737020000},
};

static BOOL TQIsValid(CLLocationCoordinate2D p) {
    return isfinite(p.latitude) && isfinite(p.longitude)
        && p.latitude >= -90 && p.latitude <= 90 && p.longitude >= -180 && p.longitude <= 180;
}

static BOOL TQIsInMainland(CLLocationCoordinate2D p) {
    if (!TQIsValid(p) || p.latitude < 17 || p.latitude > 54 || p.longitude < 73 || p.longitude > 136) return NO;
    const NSUInteger count = sizeof(TQMainlandPolygon) / sizeof(TQMainlandPolygon[0]);
    BOOL inside = NO;
    CLLocationCoordinate2D previous = TQMainlandPolygon[count - 1];
    for (NSUInteger i = 0; i < count; i++) {
        CLLocationCoordinate2D current = TQMainlandPolygon[i];
        double dx = current.longitude - previous.longitude;
        double dy = current.latitude - previous.latitude;
        double cross = (p.longitude - previous.longitude) * dy - (p.latitude - previous.latitude) * dx;
        if (fabs(cross) <= 1e-12
            && p.longitude >= fmin(previous.longitude, current.longitude) - 1e-12
            && p.longitude <= fmax(previous.longitude, current.longitude) + 1e-12
            && p.latitude >= fmin(previous.latitude, current.latitude) - 1e-12
            && p.latitude <= fmax(previous.latitude, current.latitude) + 1e-12) return YES;
        if ((current.latitude > p.latitude) != (previous.latitude > p.latitude)
            && p.longitude < dx * (p.latitude - previous.latitude) / dy + previous.longitude) inside = !inside;
        previous = current;
    }
    return inside;
}

static CLLocationCoordinate2D TQWGSToGCJ(CLLocationCoordinate2D p) {
    double x = p.longitude - 105, y = p.latitude - 35;
    double lat = -100 + 2*x + 3*y + 0.2*y*y + 0.1*x*y + 0.2*sqrt(fabs(x));
    lat += (20*sin(6*x*M_PI) + 20*sin(2*x*M_PI))*2/3;
    lat += (20*sin(y*M_PI) + 40*sin(y/3*M_PI))*2/3;
    lat += (160*sin(y/12*M_PI) + 320*sin(y*M_PI/30))*2/3;
    double lon = 300 + x + 2*y + 0.1*x*x + 0.1*x*y + 0.1*sqrt(fabs(x));
    lon += (20*sin(6*x*M_PI) + 20*sin(2*x*M_PI))*2/3;
    lon += (20*sin(x*M_PI) + 40*sin(x/3*M_PI))*2/3;
    lon += (150*sin(x/12*M_PI) + 300*sin(x/30*M_PI))*2/3;
    double radians = p.latitude/180*M_PI;
    double sine = sin(radians);
    double magic = 1 - TQEccentricitySquared*sine*sine;
    double root = sqrt(magic);
    lat = lat*180/((TQAxis*(1-TQEccentricitySquared))/(magic*root)*M_PI);
    lon = lon*180/(TQAxis/root*cos(radians)*M_PI);
    return CLLocationCoordinate2DMake(p.latitude + lat, p.longitude + lon);
}

static CLLocationCoordinate2D TQGCJToBD(CLLocationCoordinate2D p) {
    double xPi = M_PI*3000/180;
    double z = sqrt(p.longitude*p.longitude + p.latitude*p.latitude) + 0.00002*sin(p.latitude*xPi);
    double theta = atan2(p.latitude, p.longitude) + 0.000003*cos(p.longitude*xPi);
    return CLLocationCoordinate2DMake(z*sin(theta) + 0.006, z*cos(theta) + 0.0065);
}

static CLLocationCoordinate2D TQApproximateBDToGCJ(CLLocationCoordinate2D p) {
    double xPi = M_PI*3000/180;
    double x = p.longitude - 0.0065, y = p.latitude - 0.006;
    double z = sqrt(x*x + y*y) - 0.00002*sin(y*xPi);
    double theta = atan2(y, x) - 0.000003*cos(x*xPi);
    return CLLocationCoordinate2DMake(z*sin(theta), z*cos(theta));
}

static CLLocationCoordinate2D TQFail(TQConversionError code, NSError **error) {
    if (error) {
        NSString *message;
        switch (code) {
            case TQConversionErrorInvalidCoordinate: message = @"Coordinate must be finite and within latitude/longitude ranges."; break;
            case TQConversionErrorInvalidResult: message = @"The formula produced an invalid coordinate."; break;
            case TQConversionErrorNonConvergent: message = @"Inverse conversion did not converge."; break;
            default: message = @"Unknown coordinate system or region policy."; break;
        }
        *error = [NSError errorWithDomain:TQLocationConverterErrorDomain code:code
                                userInfo:@{NSLocalizedDescriptionKey: message}];
    }
    return kCLLocationCoordinate2DInvalid;
}

static CLLocationCoordinate2D TQChecked(CLLocationCoordinate2D p, NSError **error) {
    return TQIsValid(p) ? p : TQFail(TQConversionErrorInvalidResult, error);
}

typedef CLLocationCoordinate2D (*TQForward)(CLLocationCoordinate2D);
static CLLocationCoordinate2D TQInverse(CLLocationCoordinate2D target, CLLocationCoordinate2D initial,
                                       TQForward forward, NSError **error) {
    CLLocationCoordinate2D estimate = initial;
    for (NSUInteger i = 0; i < TQInverseIterationLimit; i++) {
        if (!TQIsValid(estimate)) return TQFail(TQConversionErrorInvalidResult, error);
        CLLocationCoordinate2D projected = forward(estimate);
        if (!TQIsValid(projected)) return TQFail(TQConversionErrorInvalidResult, error);
        double dLat = projected.latitude - target.latitude;
        double dLon = projected.longitude - target.longitude;
        if (fmax(fabs(dLat), fabs(dLon)) <= TQInverseTolerance) return estimate;
        estimate = CLLocationCoordinate2DMake(estimate.latitude - dLat, estimate.longitude - dLon);
    }
    return TQFail(TQConversionErrorNonConvergent, error);
}

@implementation TQLocationConverter
+ (CLLocationCoordinate2D)convertCoordinate:(CLLocationCoordinate2D)p
                                      from:(TQCoordinateSystem)source
                                        to:(TQCoordinateSystem)destination
                              regionPolicy:(TQRegionPolicy)regionPolicy
                                     error:(NSError **)error {
    if (error) *error = nil;
    if (source < TQCoordinateSystemWGS84 || source > TQCoordinateSystemBD09
        || destination < TQCoordinateSystemWGS84 || destination > TQCoordinateSystemBD09
        || (regionPolicy != TQRegionPolicyMainlandChina && regionPolicy != TQRegionPolicyUnrestricted)) {
        return TQFail(TQConversionErrorInvalidOption, error);
    }
    if (!TQIsValid(p)) return TQFail(TQConversionErrorInvalidCoordinate, error);
    if (source == destination || (regionPolicy == TQRegionPolicyMainlandChina && !TQIsInMainland(p))) return p;
    CLLocationCoordinate2D gcj = p;
    switch (source) {
        case TQCoordinateSystemWGS84: gcj = TQChecked(TQWGSToGCJ(p), error); break;
        case TQCoordinateSystemGCJ02: break;
        case TQCoordinateSystemBD09: gcj = TQInverse(p, TQApproximateBDToGCJ(p), TQGCJToBD, error); break;
    }
    if (!TQIsValid(gcj)) return gcj;
    switch (destination) {
        case TQCoordinateSystemWGS84: return TQInverse(gcj, gcj, TQWGSToGCJ, error);
        case TQCoordinateSystemGCJ02: return gcj;
        case TQCoordinateSystemBD09: return TQChecked(TQGCJToBD(gcj), error);
    }
    return TQFail(TQConversionErrorInvalidOption, error);
}

+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)p { return !TQIsInMainland(p); }

+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemWGS84 to:TQCoordinateSystemGCJ02
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
+ (CLLocationCoordinate2D)transformFromGCJToBaidu:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemGCJ02 to:TQCoordinateSystemBD09
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
+ (CLLocationCoordinate2D)transformFromBaiduToGCJ:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemBD09 to:TQCoordinateSystemGCJ02
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemGCJ02 to:TQCoordinateSystemWGS84
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
+ (CLLocationCoordinate2D)transformFromWGSToBaidu:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemWGS84 to:TQCoordinateSystemBD09
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
+ (CLLocationCoordinate2D)transformFromBaiduToWGS:(CLLocationCoordinate2D)p {
    return [self convertCoordinate:p from:TQCoordinateSystemBD09 to:TQCoordinateSystemWGS84
                     regionPolicy:TQRegionPolicyUnrestricted error:NULL];
}
@end
