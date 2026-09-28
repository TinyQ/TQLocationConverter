# ``TQLocationConverter``

Offline WGS-84, GCJ-02 and BD-09LL coordinate conversion in native Swift.

## Overview

The library uses named latitude/longitude values, explicit coordinate systems and a configurable
region policy. It does not access device location or make network requests. The inverse solver
checks its forward residual and reports failure rather than returning an unconverged estimate.

A small numerical residual describes consistency with the library's approximation formulas,
not real-world map or survey accuracy. Read the region policy before converting boundary points.

本库提供原生 Swift 经纬度转换。小数值残差仅表示与本库正向公式一致，并非真实地图精度。
默认地域策略采用近似轮廓，边界附近应由调用方明确适用范围。

## Topics

### Getting started / 快速开始

- <doc:GettingStarted>
- <doc:GettingStarted-zh-CN>

### Coordinates and conversion

- ``Coordinate``
- ``CoordinateSystem``
- ``LocationConverter``

### Behavior and errors

- ``RegionPolicy``
- ``ConversionError``
