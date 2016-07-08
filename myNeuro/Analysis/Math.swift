//
//  Math.swift
//  myNeuro
//
//  Created by Charlie Aylward on 4/6/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation


func standardDeviation(arr : [Double]) -> Double
{
    let length = Double(arr.count)
    let avg = arr.reduce(0, combine: {$0 + $1}) / length
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
    return sqrt(sumOfSquaredAvgDiff / length)
}

func frequency(arr : [Double], duration : NSTimeInterval) -> Double
{
    let count = Double(arr.count)
    let freq = count/duration
    return freq
}

func average(arr : [Double]) -> Double
{
    let count = Double(arr.count)
    let sum = arr.reduce(0, combine: +)
    let avg = sum/count
    return avg
}

