import Foundation

class UnitConvPace: UnitConverter {
  private let coeff: Double
  
  init(coeff: Double) {
    self.coeff = coeff
  }
  
  override func baseUnitValue(fromValue value: Double) -> Double {
    return reciprocal(value * coeff)
  }
  
  override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
    return reciprocal(baseUnitValue * coeff)
  }
  
  private func reciprocal(_ value: Double) -> Double {
    guard value != 0 else { return 0 }
    return 1.0 / value
  }
}

extension UnitSpeed {
  class var secondsPerMeter: UnitSpeed {
    return UnitSpeed(symbol: "sec/m", converter: UnitConvPace(coeff: 1.0))
  }
  class var minutesPerKilometer: UnitSpeed {
    return UnitSpeed(symbol: "min/km", converter: UnitConvPace(coeff: 60.0 / 1000.0))
  }
  class var minutesPerMile: UnitSpeed {
    return UnitSpeed(symbol: "min/mi", converter: UnitConvPace(coeff: 60.0 / 1609.34))
  }
}
