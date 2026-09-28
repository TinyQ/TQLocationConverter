// Approximate polygon contributed by songxiaoguang in 2016 (9074f57), retained for compatibility.
// This is a conversion heuristic, not an authoritative boundary. Keep the Obj-C table in sync.
enum ChinaRegion {
  static let vertices: [Coordinate] = [
    Coordinate(latitude: 49.1506690000, longitude: 87.4150810000),
    Coordinate(latitude: 48.3664501790, longitude: 85.7527085300),
    Coordinate(latitude: 47.0253058185, longitude: 85.3847443554),
    Coordinate(latitude: 45.2406550000, longitude: 82.5214000000),
    Coordinate(latitude: 44.8957121295, longitude: 79.9392351487),
    Coordinate(latitude: 43.1166843846, longitude: 80.6751253982),
    Coordinate(latitude: 41.8701690000, longitude: 79.6882160000),
    Coordinate(latitude: 39.2896190000, longitude: 73.6171080000),
    Coordinate(latitude: 34.2303430000, longitude: 78.9155300000),
    Coordinate(latitude: 31.0238860000, longitude: 79.0627080000),
    Coordinate(latitude: 27.9989800000, longitude: 88.7028920000),
    Coordinate(latitude: 27.1793590000, longitude: 88.9972480000),
    Coordinate(latitude: 28.0969170000, longitude: 89.7331400000),
    Coordinate(latitude: 26.9157800000, longitude: 92.1615830000),
    Coordinate(latitude: 28.1947640000, longitude: 96.0986050000),
    Coordinate(latitude: 27.4094760000, longitude: 98.6742270000),
    Coordinate(latitude: 23.9085500000, longitude: 97.5703890000),
    Coordinate(latitude: 24.0775830000, longitude: 98.7846100000),
    Coordinate(latitude: 22.1375640000, longitude: 99.1893510000),
    Coordinate(latitude: 21.1398950000, longitude: 101.7649720000),
    Coordinate(latitude: 22.2746220000, longitude: 101.7281780000),
    Coordinate(latitude: 23.2641940000, longitude: 105.3708430000),
    Coordinate(latitude: 22.7191200000, longitude: 106.6954480000),
    Coordinate(latitude: 21.9945711661, longitude: 106.7256731791),
    Coordinate(latitude: 21.4847050000, longitude: 108.0200530000),
    Coordinate(latitude: 20.4478440000, longitude: 109.3814530000),
    Coordinate(latitude: 18.6689850000, longitude: 108.2408210000),
    Coordinate(latitude: 17.4017340000, longitude: 109.9333720000),
    Coordinate(latitude: 19.5085670000, longitude: 111.4051560000),
    Coordinate(latitude: 21.2716775175, longitude: 111.2514995205),
    Coordinate(latitude: 21.9936323233, longitude: 113.4625292629),
    Coordinate(latitude: 22.1818312942, longitude: 113.4258358111),
    Coordinate(latitude: 22.2249729295, longitude: 113.5913115000),
    Coordinate(latitude: 22.4501912753, longitude: 113.8946844490),
    Coordinate(latitude: 22.5959159322, longitude: 114.3623797842),
    Coordinate(latitude: 22.4334610000, longitude: 114.5194740000),
    Coordinate(latitude: 22.9680954377, longitude: 116.8326939975),
    Coordinate(latitude: 25.3788220000, longitude: 119.9667980000),
    Coordinate(latitude: 28.3261276204, longitude: 121.7724402562),
    Coordinate(latitude: 31.9883610000, longitude: 123.8808230000),
    Coordinate(latitude: 39.8759700000, longitude: 124.4695370000),
    Coordinate(latitude: 41.7350890000, longitude: 126.9531720000),
    Coordinate(latitude: 41.5142160000, longitude: 128.3145720000),
    Coordinate(latitude: 42.9842081790, longitude: 131.0676468344),
    Coordinate(latitude: 45.2690810000, longitude: 131.8468530000),
    Coordinate(latitude: 45.0608370000, longitude: 133.0610740000),
    Coordinate(latitude: 48.4480260000, longitude: 135.0111880000),
    Coordinate(latitude: 48.0054800000, longitude: 131.6628800000),
    Coordinate(latitude: 50.2270740000, longitude: 127.6890640000),
    Coordinate(latitude: 53.3516070000, longitude: 125.3710040000),
    Coordinate(latitude: 53.4176040000, longitude: 119.9254040000),
    Coordinate(latitude: 47.5590810000, longitude: 115.1421070000),
    Coordinate(latitude: 47.1339370000, longitude: 119.1159230000),
    Coordinate(latitude: 44.8256460000, longitude: 111.2786750000),
    Coordinate(latitude: 42.5293560000, longitude: 109.2549720000),
    Coordinate(latitude: 43.2598160000, longitude: 97.2967290000),
    Coordinate(latitude: 45.4247620000, longitude: 90.9680590000),
    Coordinate(latitude: 47.8075570000, longitude: 90.6737020000),
  ]

  static func contains(_ point: Coordinate) -> Bool {
    guard (17...54).contains(point.latitude), (73...136).contains(point.longitude) else {
      return false
    }
    var inside = false
    var previous = vertices[vertices.count - 1]
    for current in vertices {
      let dx = current.longitude - previous.longitude
      let dy = current.latitude - previous.latitude
      let cross =
        (point.longitude - previous.longitude) * dy - (point.latitude - previous.latitude) * dx
      // Include points on a segment, with a tiny tolerance for floating-point arithmetic.
      if abs(cross) <= 1e-12,
        point.longitude >= min(previous.longitude, current.longitude) - 1e-12,
        point.longitude <= max(previous.longitude, current.longitude) + 1e-12,
        point.latitude >= min(previous.latitude, current.latitude) - 1e-12,
        point.latitude <= max(previous.latitude, current.latitude) + 1e-12
      {
        return true
      }
      if (current.latitude > point.latitude) != (previous.latitude > point.latitude),
        point.longitude < dx * (point.latitude - previous.latitude) / dy + previous.longitude
      {
        inside.toggle()
      }
      previous = current
    }
    return inside
  }
}
