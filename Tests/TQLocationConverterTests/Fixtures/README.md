# Forward reference fixtures / 正向参考样本

`forward.json` contains deterministic inputs and outputs from
[wandergis/coordtransform](https://github.com/wandergis/coordtransform/blob/606c6f3b57b6f1d60458793fea39928d2b11b637/index.js),
commit `606c6f3b57b6f1d60458793fea39928d2b11b637` (MIT), retrieved 2026-09-28.
The input is `{ latitude, longitude }`; upstream output arrays are `[longitude, latitude]`.
`wgsToGCJ` and `gcjToBD` each apply to the **input pair**, independently.

These are independent implementation regression values, not official provider or surveyed ground truth.
Reverse tests recover the original input rather than copying the upstream one-step inverse result.

这些固定值来自上述版本的独立实现，用于验证公式一致性，不代表官方地图精度。
输入显式标明经纬度；结果数组沿用上游的「经度、纬度」顺序。
两个正向结果分别以原始输入为起点，不是连续转换。反向测试验证还原输入，不照搬单次近似逆变换的结果。
