class_name Vector2Util


const err_msg = "Vector operation on different types"


static func cw_multiply(a, b) -> Variant:
    match typeof(a):
        TYPE_VECTOR2:
            assert(b is Vector2, err_msg)
            return Vector2(a.x * b.x, a.y * b.y)
        TYPE_VECTOR2I:
            assert(b is Vector2i, err_msg)
            return Vector2i(a.x * b.x, a.y * b.y)
        _:
            assert(false, "Types must be vectors")
            return null


static func cw_divide(a, b) -> Variant:
    match typeof(a):
        TYPE_VECTOR2:
            assert(b is Vector2, err_msg)
            return Vector2(a.x / b.x, a.y / b.y)
        TYPE_VECTOR2I:
            assert(b is Vector2i, err_msg)
            return Vector2i(a.x / b.x, a.y / b.y)
        _:
            assert(false, "Types must be vectors")
            return null


static func cw_less_than(a, b) -> bool:
    match typeof(a):
        TYPE_VECTOR2:
            assert(b is Vector2, err_msg)
            return a.x < b.x and a.y < b.y
        TYPE_VECTOR2I:
            assert(b is Vector2i, err_msg)
            return a.x < b.x and a.y < b.y
        _:
            assert(false, "Types must be vectors")
            return false
