
// Internal Functions
func twoIntHash(a:UInt32, _ b:UInt32) -> UInt64 {
    let a = UInt64(a)
    let b = UInt64(b)
    
    return a<<32 | b
    
    // See http://stackoverflow.com/a/13871379
    // return a >= b ? a * a + a + b : a + b * b
}


let result: UInt64 = twoIntHash(UInt32.max, UInt32.max)
let string = String(result, radix: 2, uppercase: false)
string.characters.count
