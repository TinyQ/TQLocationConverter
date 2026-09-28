// Copyright (c) 2014 TinyQ. MIT License; see LICENSE.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// Geographic coordinates in decimal degrees. BD09 denotes BD-09LL, not BD-09MC.
typedef NS_ENUM(NSInteger, TQCoordinateSystem) {
    TQCoordinateSystemWGS84,
    TQCoordinateSystemGCJ02,
    TQCoordinateSystemBD09,
};

/// The mainland polygon is an approximation, not an authoritative geographic boundary.
typedef NS_ENUM(NSInteger, TQRegionPolicy) {
    /// Check the input once. Points outside the polygon pass through unchanged for every pair.
    TQRegionPolicyMainlandChina,
    /// Always apply the formulas. Use when the source provider has established applicability.
    TQRegionPolicyUnrestricted,
};

FOUNDATION_EXPORT NSErrorDomain const TQLocationConverterErrorDomain;
typedef NS_ERROR_ENUM(TQLocationConverterErrorDomain, TQConversionError) {
    TQConversionErrorInvalidCoordinate = 1,
    TQConversionErrorInvalidResult,
    TQConversionErrorNonConvergent,
    TQConversionErrorInvalidOption,
};

/// Stateless, offline conversion. No location permissions, SDK keys or network requests.
@interface TQLocationConverter : NSObject

/// Converts with validation and an explicit region policy.
/// Returns kCLLocationCoordinate2DInvalid and sets error on failure.
/// Identity conversions still validate input. Success clears a supplied error pointer.
/// Near polygon edges use Unrestricted when applicability is known; offsets can cross edges.
/// Numerical convergence is relative to this library's formulas, not surveyed ground truth.
+ (CLLocationCoordinate2D)convertCoordinate:(CLLocationCoordinate2D)coordinate
                                      from:(TQCoordinateSystem)source
                                        to:(TQCoordinateSystem)destination
                              regionPolicy:(TQRegionPolicy)regionPolicy
                                     error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(convert(_:from:to:regionPolicy:error:)) NS_SWIFT_NOTHROW;

/// Legacy name: returns YES outside the approximate mainland polygon, or for invalid input.
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

/// Legacy methods preserve unrestricted regional behavior. Call isLocationOutOfChina: yourself
/// or prefer the checked API above. Invalid input/output or non-convergence returns the invalid sentinel.
/// WGS-84 → GCJ-02.
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
/// GCJ-02 → BD-09LL.
+ (CLLocationCoordinate2D)transformFromGCJToBaidu:(CLLocationCoordinate2D)p;
/// BD-09LL → GCJ-02, refined to invert the forward model.
+ (CLLocationCoordinate2D)transformFromBaiduToGCJ:(CLLocationCoordinate2D)p;
/// GCJ-02 → WGS-84, using bounded residual iteration.
+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D)p;
/// WGS-84 → BD-09LL, composed through GCJ-02.
+ (CLLocationCoordinate2D)transformFromWGSToBaidu:(CLLocationCoordinate2D)p;
/// BD-09LL → WGS-84, composed through GCJ-02.
+ (CLLocationCoordinate2D)transformFromBaiduToWGS:(CLLocationCoordinate2D)p;
@end

NS_ASSUME_NONNULL_END
