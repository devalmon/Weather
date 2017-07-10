//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var addSomeText: (String) -> (String) = { text in
    return text + " " + str
}

addSomeText("Tratata")

var doubleValue: (Int) -> (Int) = { x in
    return 2 * x
}

doubleValue(3)

var printSwifty: () -> (String) = {
    return "I \u{1F498} Swift!"
}

let dic = ["alex" : 23, "max" : 34]
let doubleValue = dic.map {$1 * 2}
doubleValue