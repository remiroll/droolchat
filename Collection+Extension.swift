import Foundation

extension Collection {
    
    subscript(optional i: Index) -> Iterator.Element? {
        return (self.startIndex ..< self.endIndex).contains(i) ? self[i] : nil
    }
    
}
