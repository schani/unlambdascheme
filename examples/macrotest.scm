(defmacro tester list)

(defmacro (func a b)
    (tester a b))

(test
 (func 1 2 3)
 (func 1 2)
 (func 1)
 (func))
