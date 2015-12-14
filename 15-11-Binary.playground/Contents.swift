let r: UInt16 = 255 / 16
let g: UInt16 = 10  / 16
let b: UInt16 = 201 / 16

let rBits = String(r, radix: 2)
let gBits = String(g, radix: 2)
let bBits = String(b, radix: 2)

let rShifted = r << 8
let gShifted = g << 4
let bShifted = b << 0
let rgb = rShifted | gShifted | bShifted

String(rShifted, radix: 2)
String(gShifted, radix: 2)
String(bShifted, radix: 2)
String(rgb, radix: 2)

let rr = (rgb & 0xF00) >> 8
let gg = (rgb & 0x0F0) >> 4
let bb = (rgb & 0x00F)




