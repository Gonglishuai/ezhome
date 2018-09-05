//
//  ESSpringAnimation.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

let ESSpringAnimationDefaultMass: CGFloat = 5.0
let ESSpringAnimationDefaultDamping: CGFloat = 30.0
let ESSpringAnimationDefaultStiffness: CGFloat = 300.0
let ESSpringAnimationKeyframeStep: CGFloat = 0.001
let ESSpringAnimationMinimumThreshold: CGFloat = 0.0001

public class ESSpringAnimation: CAKeyframeAnimation {
    
    
    /// 刚度
    public var stiffness: CGFloat = ESSpringAnimationDefaultStiffness {
        didSet {
            self.needsRecalculation = true
        }
    }
    
    
    /// 阻尼
    public var damping: CGFloat = ESSpringAnimationDefaultDamping {
        didSet(value) {
            if value <= 0 {
                damping = 1.0
            }
            self.needsRecalculation = true
        }
    }
    
        
    /// 质量
    public var mass: CGFloat = ESSpringAnimationDefaultMass {
        didSet {
            self.needsRecalculation = true
        }
    }
    
    public var fromValue: NSNumber! {
        didSet {
            self.needsRecalculation = true
        }
    }
    public var toValue: NSNumber! {
        didSet {
            self.needsRecalculation = true
        }
    }
    
    override public var values: [Any]? {
        get {
            return self.interpolatedValues
        }
        set(newValues) {
            super.values = newValues
        }
    }
    
    override public var duration: CFTimeInterval {
        get {
            return CFTimeInterval(CGFloat(self.interpolatedValues!.count) * ESSpringAnimationKeyframeStep)
        }
        set(value) {
            super.duration = value
        }
    }
    
    private var _interpolatedValues: Array<NSValue>?
    private var interpolatedValues: Array<NSValue>? {
        get {
            if self.needsRecalculation || _interpolatedValues == nil {
                calculateInterpolatedValues()
            }
            return _interpolatedValues
        }
        set(value) {
            _interpolatedValues = value
        }
    }
    
    private var needsRecalculation: Bool = false
    
    public convenience init(fromValue: NSNumber, toValue: NSNumber, keyPath path: String?) {
        self.init(keyPath: path)
        self.fromValue = fromValue
        self.toValue = toValue
    }
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ESSpringAnimation
        copy.interpolatedValues = self.interpolatedValues;
        copy.duration = CFTimeInterval(CGFloat((self.interpolatedValues?.count)!) * ESSpringAnimationKeyframeStep)
        copy.fromValue = self.fromValue;
        copy.stiffness = self.stiffness;
        copy.toValue = self.toValue;
        copy.damping = self.damping;
        copy.mass = self.mass;
        return copy
    }
    
    private func calculateInterpolatedValues() {
        
        let fromType = self.fromValue.es_type()
        let toType = self.fromValue.es_type()
        assert(fromType == toType, "fromValue and toValue must be of the same type.")
        assert(fromType != .ESValueTypeUnknown, "Type of value could not be determined. Please ensure the value types are supported.")
        
        var values = Array<NSValue>()
        
        if fromType == .ESValueTypeNumber {
            values = valuesfromNumbers([self.fromValue], toNumbers: [self.toValue], map: { (valuesP, count) -> NSValue in
                let num = NSNumber(value: Float(valuesP[0]))
                return num as NSValue
            })
        } else if fromType == .ESValueTypePoint {
            let f = self.fromValue.es_pointValue()
            let t = self.toValue.es_pointValue()
                
            values = valuesfromNumbers([NSNumber(value: Float(f.x)),
                                        NSNumber(value: Float(f.y))],
                                       toNumbers: [NSNumber(value: Float(t.x)),
                                                   NSNumber(value: Float(t.y))], map: { (valuesP, count) -> NSValue in
                return NSValue.es_value(point: CGPoint(x: valuesP[0], y: valuesP[1]))
            })
            
        } else if fromType == .ESValueTypeSize {
            let f = self.fromValue.es_sizeValue()
            let t = self.toValue.es_sizeValue()
                
            values = valuesfromNumbers([NSNumber(value: Float(f.width)),
                                        NSNumber(value: Float(f.height))],
                                       toNumbers: [NSNumber(value: Float(t.width)),
                                                   NSNumber(value: Float(t.width))], map: { (valuesP, count) -> NSValue in
                return NSValue.es_value(size: CGSize(width: valuesP[0], height: valuesP[1]))
            })
            
        } else if fromType == .ESValueTypeRect {
            let f = self.fromValue.es_rectValue()
            let t = self.toValue.es_rectValue()
                
            let fromArray = [NSNumber(value: Float(f.origin.x)),
                             NSNumber(value: Float(f.origin.y)),
                             NSNumber(value: Float(f.size.width)),
                             NSNumber(value: Float(f.size.height))]
            let toArray = [NSNumber(value: Float(t.origin.x)),
                           NSNumber(value: Float(t.origin.y)),
                           NSNumber(value: Float(t.size.width)),
                           NSNumber(value: Float(t.size.height))]
            
            values = valuesfromNumbers(fromArray, toNumbers:toArray , map: { (valuesP, count) -> NSValue in
                return NSValue.es_value(rect: CGRect(x: valuesP[0], y: valuesP[1], width: valuesP[2], height: valuesP[3]))
            })
            
        } else if fromType == .ESValueTypeAffineTransform {
            let f = self.fromValue.es_affineTransformValue()
            let t = self.toValue.es_affineTransformValue()
            
            var fromArray = Array<NSNumber>()
            fromArray.append(NSNumber(value: Float(f.a)))
            fromArray.append(NSNumber(value: Float(f.b)))
            fromArray.append(NSNumber(value: Float(f.c)))
            fromArray.append(NSNumber(value: Float(f.d)))
            fromArray.append(NSNumber(value: Float(f.tx)))
            fromArray.append(NSNumber(value: Float(f.ty)))
            
            var toArray = Array<NSNumber>()
            toArray.append(NSNumber(value: Float(t.a)))
            toArray.append(NSNumber(value: Float(t.b)))
            toArray.append(NSNumber(value: Float(t.c)))
            toArray.append(NSNumber(value: Float(t.d)))
            toArray.append(NSNumber(value: Float(t.tx)))
            toArray.append(NSNumber(value: Float(t.ty)))
            
            values = valuesfromNumbers(fromArray, toNumbers: toArray, map: { (valuesP, count) -> NSValue in
                var transform = CGAffineTransform.identity
                transform.a = valuesP[0]
                transform.b = valuesP[1]
                transform.c = valuesP[2]
                transform.d = valuesP[3]
                transform.tx = valuesP[4]
                transform.ty = valuesP[5]
                return NSValue.es_value(transform: transform)
            })
            
        } else if fromType == .ESValueTypeTransform3D {
            let f = self.fromValue.caTransform3DValue
            let t = self.toValue.caTransform3DValue
            var fromArray = Array<NSNumber>()
            fromArray.append(NSNumber(value: Float(f.m11)))
            fromArray.append(NSNumber(value: Float(f.m12)))
            fromArray.append(NSNumber(value: Float(f.m13)))
            fromArray.append(NSNumber(value: Float(f.m14)))
            fromArray.append(NSNumber(value: Float(f.m21)))
            fromArray.append(NSNumber(value: Float(f.m22)))
            fromArray.append(NSNumber(value: Float(f.m23)))
            fromArray.append(NSNumber(value: Float(f.m24)))
            fromArray.append(NSNumber(value: Float(f.m31)))
            fromArray.append(NSNumber(value: Float(f.m32)))
            fromArray.append(NSNumber(value: Float(f.m33)))
            fromArray.append(NSNumber(value: Float(f.m34)))
            fromArray.append(NSNumber(value: Float(f.m41)))
            fromArray.append(NSNumber(value: Float(f.m42)))
            fromArray.append(NSNumber(value: Float(f.m43)))
            fromArray.append(NSNumber(value: Float(f.m44)))
            
            var toArray = Array<NSNumber>()
            toArray.append(NSNumber(value: Float(t.m11)))
            toArray.append(NSNumber(value: Float(t.m12)))
            toArray.append(NSNumber(value: Float(t.m13)))
            toArray.append(NSNumber(value: Float(t.m14)))
            toArray.append(NSNumber(value: Float(t.m21)))
            toArray.append(NSNumber(value: Float(t.m22)))
            toArray.append(NSNumber(value: Float(t.m23)))
            toArray.append(NSNumber(value: Float(t.m24)))
            toArray.append(NSNumber(value: Float(t.m31)))
            toArray.append(NSNumber(value: Float(t.m32)))
            toArray.append(NSNumber(value: Float(t.m33)))
            toArray.append(NSNumber(value: Float(t.m34)))
            toArray.append(NSNumber(value: Float(t.m41)))
            toArray.append(NSNumber(value: Float(t.m42)))
            toArray.append(NSNumber(value: Float(t.m43)))
            toArray.append(NSNumber(value: Float(t.m44)))
            
            values = valuesfromNumbers(fromArray, toNumbers: toArray, map: { (valuesP, count) -> NSValue in
                var transform = CATransform3DIdentity
                transform.m11 = valuesP[0]
                transform.m12 = valuesP[1]
                transform.m13 = valuesP[2]
                transform.m14 = valuesP[3]
                transform.m21 = valuesP[4]
                transform.m22 = valuesP[5]
                transform.m23 = valuesP[6]
                transform.m24 = valuesP[7]
                transform.m31 = valuesP[8]
                transform.m32 = valuesP[9]
                transform.m33 = valuesP[10]
                transform.m34 = valuesP[11]
                transform.m41 = valuesP[12]
                transform.m42 = valuesP[13]
                transform.m43 = valuesP[14]
                transform.m44 = valuesP[15]
                return NSValue.es_value(transform3D: transform)
            })
        }
        
        self._interpolatedValues = values
        self.needsRecalculation = false
    }
    
    private func valuesfromNumbers(_ fromNumbers: Array<NSNumber>, toNumbers: Array<NSNumber>, map: (_ values: UnsafeMutablePointer<CGFloat>, _ count: Int) -> NSValue) -> Array<NSValue> {
        
        assert(fromNumbers.count == toNumbers.count, "count of from and to numbers must be equal")

        let count = fromNumbers.count
        if count < 1 {
            return Array()
        }
        
        let distancesRP: UnsafeMutableRawPointer = calloc(count, MemoryLayout<CGFloat>.size)
        let distances: UnsafeMutablePointer<CGFloat> = distancesRP.assumingMemoryBound(to: type(of: CGFloat()))
        let thresholdsRP: UnsafeMutableRawPointer! = calloc(count, MemoryLayout<CGFloat>.size)
        let thresholds: UnsafeMutablePointer<CGFloat> = thresholdsRP.assumingMemoryBound(to: type(of: CGFloat()))
        
        for i in 0 ..< count {
            distances[i] = CGFloat(toNumbers[i].floatValue - fromNumbers[i].floatValue)
            thresholds[i] = ESSpringAnimationThreshold(fabs(distances[i]))
        }
        
        let step: CFTimeInterval = CFTimeInterval(ESSpringAnimationKeyframeStep)
        var elapsed: CFTimeInterval = 0
        
        let stepValuesRP: UnsafeMutableRawPointer = calloc(count, MemoryLayout<CGFloat>.size)
        let stepValues: UnsafeMutablePointer<CGFloat> = calloc(count, MemoryLayout<CGFloat>.size).assumingMemoryBound(to: type(of: CGFloat()))
        let stepProposedValuesRP: UnsafeMutableRawPointer = calloc(count, MemoryLayout<CGFloat>.size)
        let stepProposedValues: UnsafeMutablePointer<CGFloat> = calloc(count, MemoryLayout<CGFloat>.size).assumingMemoryBound(to: type(of: CGFloat()))
        
        var valuesMapped = Array<NSValue>()
        
        while true {
            var thresholdReached = true
            
            for i in 0 ..< count {
                stepProposedValues[i] = ESAbsolutePosition(distances[i], CGFloat(elapsed), 0, self.damping, self.mass, self.stiffness, CGFloat(fromNumbers[i].floatValue));
                
                if thresholdReached {
                    thresholdReached = ESThresholdReached(stepValues[i], stepProposedValues[i], CGFloat(toNumbers[i].floatValue), thresholds[i])
                }
            }
            
            if thresholdReached {
                break
            }
            
            for i in 0 ..< count {
                stepValues[i] = stepProposedValues[i]
            }
            
            valuesMapped.append(map(stepValues, count))
            elapsed += step
        }
        
        free(distancesRP)
        free(thresholdsRP)
        free(stepValuesRP)
        free(stepProposedValuesRP)
        
        return valuesMapped
    }
    
    private func ESThresholdReached(_ previousValue: CGFloat, _ proposedValue: CGFloat, _ finalValue: CGFloat, _ threshold: CGFloat) -> Bool {
        let previousDifference = fabs(proposedValue - previousValue)
        let finalDifference = fabs(previousValue - finalValue)
        if (previousDifference <= threshold && finalDifference <= threshold) {
            return true
        }
        return false
    }
    
    private func ESCalculationsAreComplete(_ value1: CGFloat, _ proposedValue1: CGFloat, _ to1:CGFloat, _ value2:CGFloat, _ proposedValue2: CGFloat, _ to2: CGFloat, _ value3: CGFloat, _ proposedValue3: CGFloat, _ to3: CGFloat) -> Bool {
        return ((fabs(proposedValue1 - value1) < ESSpringAnimationKeyframeStep)
            && (fabs(value1 - to1) < ESSpringAnimationKeyframeStep)
            && (fabs(proposedValue2 - value2) < ESSpringAnimationKeyframeStep)
            && (fabs(value2 - to2) < ESSpringAnimationKeyframeStep)
            && (fabs(proposedValue3 - value3) < ESSpringAnimationKeyframeStep)
            && (fabs(value3 - to3) < ESSpringAnimationKeyframeStep))
    }
    
    // MARK: Damped Harmonic Oscillation
    private func ESAngularFrequency(_ k: CGFloat, _ m: CGFloat, _ b: CGFloat) -> CGFloat {
        let w0 = sqrt(k / m)
        var frequency = sqrt(pow(w0, 2) - (pow(b, 2) / (4*pow(m, 2))))
        if __inline_isnanf(Float(frequency)) >= 1 {
            frequency = 0
        }
        return frequency
    }
    
    private func ESRelativePosition(_ A: CGFloat, _ t: CGFloat, _ phi: CGFloat, _ b: CGFloat, _ m: CGFloat, _ k: CGFloat) -> CGFloat {
        if A == 0 {
            return A
        }
        let ex = (-b / (2 * m) * t);
        let freq = ESAngularFrequency(k, m, b)
        return A * exp(ex) * cos(freq*t + phi)
    }
    
    private func ESAbsolutePosition(_ A: CGFloat, _ t: CGFloat, _ phi: CGFloat, _ b: CGFloat, _ m: CGFloat, _ k: CGFloat, _ from: CGFloat) -> CGFloat {
        return from + A - ESRelativePosition(A, t, phi, b, m, k)
    }
    
    // This feels a bit hacky. I'm sure there's a better way to accomplish this.
    private func ESSpringAnimationThreshold(_ magnitude: CGFloat) -> CGFloat {
        return ESSpringAnimationMinimumThreshold * magnitude
    }
}

enum ESValueType: Int {
    case ESValueTypeNumber = 0
    case ESValueTypePoint = 1
    case ESValueTypeSize = 2
    case ESValueTypeRect = 3
    case ESValueTypeAffineTransform = 4
    case ESValueTypeTransform3D = 5
    case ESValueTypeUnknown = 6
}

extension NSValue {
    func es_rectValue() -> CGRect {
        return self.cgRectValue
    }
    
    func es_sizeValue() -> CGSize {
        return self.cgSizeValue
    }
    
    func es_pointValue() -> CGPoint {
        return self.cgPointValue
    }
    
    func es_affineTransformValue() -> CGAffineTransform {
        return self.cgAffineTransformValue
    }
    
    static func es_value(rect: CGRect) -> NSValue {
        return NSValue(cgRect: rect)
    }
    
    static func es_value(point: CGPoint) -> NSValue {
        return NSValue(cgPoint: point)
    }
    
    static func es_value(size: CGSize) -> NSValue {
        return NSValue(cgSize: size)
    }
    
    static func es_value(transform: CGAffineTransform) -> NSValue {
        return NSValue(cgAffineTransform: transform)
    }
    
    static func es_value(transform3D: CATransform3D) -> NSValue {
        return NSValue(caTransform3D: transform3D)
    }
    
    func es_type() -> ESValueType {
        let type = self.objCType
        let numberTypes = ["i", "s", "l", "q", "I", "S", "L", "Q", "f", "d"]
        for numberType in numberTypes {
            if strcmp(type, numberType) == 0 {
                return .ESValueTypeNumber
            }
        }
        if strcmp(type, NSValue.es_value(point: CGPoint.zero).objCType) == 0 {
            return .ESValueTypePoint
        }else if strcmp(type, NSValue.es_value(size: CGSize.zero).objCType) == 0 {
            return .ESValueTypeSize
        }else if strcmp(type, NSValue.es_value(rect: CGRect.zero).objCType) == 0 {
            return .ESValueTypeRect
        }else if strcmp(type, NSValue.es_value(transform: CGAffineTransform.init()).objCType) == 0 {
            return .ESValueTypeAffineTransform
        }else if strcmp(type, NSValue.es_value(transform3D: CATransform3D.init()).objCType) == 0 {
            return .ESValueTypeTransform3D
        }else {
            return .ESValueTypeUnknown
        }
    }
}
