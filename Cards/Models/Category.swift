import Foundation
import RealmSwift

class Category: Object {
    
    
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let words = List<Word>()
}
