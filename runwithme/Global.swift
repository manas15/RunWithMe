
import Foundation
import Firebase

let root = "https://featherrunwithme.firebaseio.com/"

class Global {
    var rootUrl = Firebase(url: "\(root)")
    var online = Firebase(url: "\(root)Online")
    var running = Firebase(url: "\(root)Running")
    
}
