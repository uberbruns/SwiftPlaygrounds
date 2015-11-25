//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let value: Double = 1.0
let max: Double = 1.0
let min: Double = 0
var result: Double = 0

if (value >= max) {
    result = max;
} else if (value <= min) {
    result = min;
}
let pos: Double = (value - min) / (max - min);
let factor: Double = log10(pos * -0.99 + 1.0) / -2.0;
result = min + ((max - min) * factor);


