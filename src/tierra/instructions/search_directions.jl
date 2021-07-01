abstract type SearchDirection end
struct SearchBackward <: SearchDirection end
struct SearchForward <: SearchDirection end
struct SearchBoth <: SearchDirection end
