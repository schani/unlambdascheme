# UnlambdaScheme

[Unlambda](http://www.eleves.ens.fr:8080/home/madore/programs/unlambda/)
is an obfuscated functional programming language. This is a compiler
for a small, pure subset of the Scheme programming language, which
generates Unlambda code. In addition, implemented in this Scheme
subset is an interpreter for a very simple Lambda-calculus-like
virtual machine, which makes it possible to overcome the exponential
code growth resulting from abstraction elimination. The following is a
description of the basic concepts of this Compiler/Interpreter pair:

The basic building blocks in the Unlambda programming language are the
functions S, K, I, and the application operator `` ` ``
(backtick). Translated to Scheme, the function I is

    (lambda (x) x)

i.e., the identity function. The function K takes two arguments (all
functions in Unlambda are curried, which means that K really takes one
argument and returns a function which takes a second argument) and
returns the first one:

    (lambda (x y) x)

S is a little bit more complicated. It takes three arguments X, Y, Z
and applies X to Z, then Y to Z and then the result of the former
application to the result of the latter, i.e:

    (lambda (x y z) ((x z) (y z)))

The application operator `` ` `` uses an infix syntax. It takes a
function, an argument (which is, like every value in Unlambda, a
function as well) and applies the function to the argument, i.e.,
`` `XY `` is the same in Unlambda as `(X Y)` is in Scheme.

Unlambda provides other primitives as well, which are mainly useful
for I/O and as shortcuts for more complicated constructs.

One thing Unlambda completely lacks is a concept of variables. There
is no `lambda` or `let` operator or anything else that
would give a name (or anything similar) to a value. Luckily, it's
possible to "emulate" the `lambda` operator with the functions
S, K, and I, by a process called "Abstraction Elimination". It is
described on the
[Unlambda Home Page](http://www.eleves.ens.fr:8080/home/madore/programs/unlambda/),
so I won't repeat it here. What I will repeat, though, is that it has
the unfortunate side effect of blowing a program up by a factor
roughly proportional to the deepest nesting depth of `lambda`
operators, which is obviously a big problem. We will see later how it
is possible to overcome it.

Abstraction elimination gives us the `lambda` operator with one
argument, but apart from that, we have very little yet. The first
thing we can do is to extend `lambda` to support more than one
argument, like in Scheme. To do this, we simply curry all functions,
i.e., transform them to functions with one argument, like this:

    (lambda (x y z) body) => (lambda (x) (lambda (y) (lambda (z) body)))

Function calls must be transformed similarly:

    (f x y z) => (((f x) y) z)

Next on the list is the `let` operator, which gives names to
values. The `let` operator can be transformed into a `lambda` operator
and an application:

    (let ((x x-val) (y y-val)) body) => ((lambda (x y) body) x-val y-val)

The `letrec` operator allows the definition of recursive
functions. Because its implementation is a bit unwieldy, I'll first
discuss the simpler `lambda*` operator, which can be used to generate
a single anonymous recursive function (`lambda*` is not a part of the
Scheme programming language, but a feature of this dialect). As an
example, here's a function for computing the factorial of a number:

    (lambda* fac (n)
	  (if (<= n 2)
		n
		(* n (fac (- n 1))))))

The name `fac` is only visible within the function itself. This
function can be transformed to eliminate the `lambda*` operator to
this semantically equivalent function:

    ((lambda (x) (x x))
	 (lambda (fac n)
	   (if (<= n 2)
		 n
		 (* n (fac fac (- n 1)))))))

Note that the upper `lambda` expression applies the function below to
itself, thereby giving it a way to refer to itself. Also note that
when the function calls itself recursively, it must again pass itself
as an argument to itself. Note even further that this example would
not run in standard Scheme, because Scheme does not curry. In Scheme,
the function would have to look like this:

    ((lambda (x) (x x))
	 (lambda (fac)
	   (lambda (n)
		 (if (<= n 2)
		   n
		   (* n ((fac fac) (- n 1))))))))

The main difference between `lambda*` and `letrec` is that the latter
can introduce more than one function, each of which can reference each
other. The principle for translation is the same as with `lambda*`,
only that here each function must be passed all functions (including
itself) as arguments. For example, the expression

    (letrec ((fa (lambda (i)
				   (fb (- i 1))))
		 (fb (lambda (i)
			   (fa (+ i 1)))))
	  (fa 0))

is semantically equivalent to

    (let ((fa (lambda (fa fb i)
				(fb fa fb (- i 1))))
		  (fb (lambda (fa fb i)
				(fa fa fb (- i 1)))))
	  (fa fa fb 0))

The resulting `let` can be translated to a `lambda` as described above.

The most important language part that remains is the conditional
operator `if` and the booleans `#t` and `#f`. Unlambda's "native"
booleans are the function I for true and V, which takes argument and
always returns itself, for false. The Unlambda home page presents an
if function for these booleans, which takes three arguments, the first
one a boolean, i.e., either I or V. If it is true, the function
returns the second argument, otherwise the third.

In a strict language like Scheme, as opposed to a lazy one like
Haskell, `if` is not a function, however. Its second argument is only
evaluated if the condition is true, the third only if it is false. To
accomplish this, we have to delay these arguments and force only the
resulting one. Thus, we transform the expression

    (if condition consequent alternative)

to

    ((*if* condition
	   (lambda (dummy) consequent)
	   (lambda (dummy) alternative))
	 *I*)

whereas `*if*` is the Unlambda if function and `*I*` the function I.

That's pretty much all there is to the language and the compiler. As
an example of how complex data structures can be represented, I'll
discuss how lists can be implemented. Lists in Scheme are constructed
out of so called "cons" cells. Each such cell is a tuple with two
elements, which are called the "car" and the "cdr". The function
`cons` takes two arguments and constructs such a cell. It can be
implemented like this:

    (lambda (car cdr)
	  (lambda (f)
		(f car cdr)))

In this implementation, a cell is nothing more than a function which
takes another function and applies it to the car and the cdr. This is
taken advantage of in the implementation of the functions `car` and
`cdr`, each of which take a cell and return its car or cdr,
respectively. Here is the function `car`:

    (lambda (cell)
	  (cell (lambda (car cdr)
			  car)))

What's left is a way of representing the empty list `()`, which is not
a cons cell. Applying `car` or `cdr` to it is illegal, so it is not
supposed to give meaningful results in those cases (we don't do error
handling). However, it can be tested for with the function `null?`,
which returns `#t` if applied to the empty list, and `#f` if applied
to a cons cell. Here is the empty list:

    (lambda (f)
      #t)

The reason for this implementation only becomes apparent when seen in
conjunction with the function `null?`:

    (lambda (cell)
	  (cell (lambda (car cdr)
			  #f)))

If the argument `cell` is the empty list, applying it to whatever
argument will return `#t`, which is exactly what we want. If it is a
cell, however, the inner `lambda` takes care of returning the result
`#f`.

Given bits (booleans) and a way of putting them together (lists) it's
now easy to represent numbers, or any other data structure desired, so
I'll not go into the details of how this can be done.

We now have a compiler translating a reasonable subset of the Scheme
programming language to Unlambda. In theory, we can now program to our
heart's delight, compile the program to Unlambda and see it run. In
practice, however, we still have one serious problem: The Unlambda
programs get much too big. A simple program which reads two binary
numbers, represents them as lists of booleans (in binary
representation), adds them, and outputs the resulting binary number,
compiles to an Unlambda program about 18MB in size. The original
Scheme code is less than 50 lines. Running the program on my 1GB RAM
machine is impossible because it uses too much memory. Clearly
something must be done.

As I have already mentioned in the introduction, the result of this
code growth is the process of abstraction elimination. For every
single increase in nested lambda depth, the generated code grows by a
factor of about three, and not very much can be done about it, except
to keep lambdas shallow.

An important observation about abstraction elimination is that if one
uses only some pre-fabricated functions and just applies them to each
other, the lambda depth does not increase beyond that of those
functions. Another observation is that constructing lists (via `cons`)
only uses pre-fabricated functions which are applied to each other. In
other words, we can construct lists of arbitrary length and depth
without going beyond a fixed, very shallow, lambda depth. The result
is that Unlambda programs representing lists only grow linearly with
relation to the size of the list, not exponentially.

Since a Scheme program is nothing but a list, we could in theory write
a Scheme interpreter in Scheme, compile it to Unlambda, and then have
a way of executing arbitrary Scheme programs in Unlambda without
exponential growth. Of course, a full Scheme interpreter - even for
our limited subset - would be far too big as an Unlambda program, but
it is possible to translate Scheme to a very simple list
representation, which can then be interpreted by an Unlambda program.

I have discussed above how to translate the most important Scheme
language features into pure lambda calculus. Now I'll discuss how to
transform lambda calculus into something more appropriate for direct
interpretation.

An expression in pure lambda calculus can be of one out of three types:

* An application. In Scheme syntax: `(F A)`. `F` if the expression
  which evaluates to the function, which is applied to the result of
  the evaluation of `A`.

* A lambda expression (with one argument), which constructs a
  function. In Scheme: `(lambda (X) B)`. `X` is the name of the
  argument, `B` is the body expression.

* A variable reference. The variable must be the argument of some
  enclosing lambda expression.

The main problem with making this work in an interpreter is
representing and looking up the lambda argument names. Fortunately, it
is easy to recognize that the names can be done away with completely,
if environments are represented in a list form, like in the Scheme in
OCaml interpreter discussed above. In that case, the only piece of
information that is necessary for a variable reference is how many
lambda expressions outside of the reference the name was
introduced. For example, in

    (lambda (x) (lambda (y) (lambda (z) y)))

we can do away with the names altogether and replace the reference to
`y` by the number `2`, since `y` was introduced by the second lambda
expression outward of the reference, giving

    (lambda (lambda (lambda 2)))

Of course, my interpreter does not represent a lambda expression with
the symbol `lambda`. Instead, each expression is represented as a cons
cell (compiled to Unlambda functions, as detailed above), the car of
which gives the type of the expression. To that end, it is a cons cell
itself whose car and cdr are booleans, which encode the following
expression types:

* `(#t . #t)`: lambda expression

* `(#t . #f)`: application

* `(#f . #t)`: variable reference

* `(#f . #f)`: a native function

The first thing the `eval` function does is check of which type the
expression it is fed is:

    (lambda* eval (env expr)
	  (if (car (car expr))
		(if (cdr (car expr))

In the case of a lambda expression, the cdr of the expression cell
gives the body. All we have to do is construct a closure with this
body and the current environment. My interpreter represents a closure
as a cons cell whose car is the environment and whose cdr is the body,
so the code for interpreting a lambda expression is simply

          (cons env (cdr expr))

Note that we do not have to tag this closure for being a closure,
because in this interpreter, every value is a closure.

Next on the list are applications. The cdr of an application's
expression cell is a cons cell whose car is the function and whose cdr
is the argument, both of which must of course be evaluated. Hence, the
first thing we do with an application is evaluate the function:

          (let ((fun (eval env (car (cdr expr)))))

The result (now in `fun`) is a closure. When applying a function to an
argument, we must call `eval` with the function body and with an
environment which includes the new argument. The rest of the
environment is that of the closure in `fun`. The code looks like this:

            (eval (cons (eval env (cdr (cdr expr)))
						(car fun))
				  (cdr fun))))

What this code does is first evaluate the application argument (via
the inner call to `eval`), then `cons` the result together with the
function's environment to get the new environment, and then evaluate
the function's body with this new environment.

The last lambda calculus expression type is the variable reference. As
outlined above, a variable reference contains a number giving the
index of the variable to get in the current environment
list. Representing numbers as lists of booleans involves using the
`if` special form, which adds lambda depth and blows up the
interpreter. Encoding the number in the length of the list would
result in additional size in the generated code, especially when
dealing with deep lambda nesting, which is not uncommon.

The solution I chose encodes numbers in binary representation, but
instead of using `#t` for one and `#f` for zero, I use the function
`cdr` for one and I for zero. In other words, applying a digit to a
list returns either the list, if the digit is "zero", or the list
advanced by one element if the digit is "one". Applying such a binary
number list to an environment list entails - if the number list is not
empty - applying the first, least significant, "digit" to the list,
and then applying the rest of the number list to the result twice, or
the other way around. The code for the recursive function `get`, which
performs this application, is this:

    (lambda* get (env pos)
	  (if (null? pos)
		env
		((car pos) (get (get env (cdr pos)) (cdr pos)))))

Now that we have this function, implementing a variable reference is
very easy. The cdr of the expression cell contains the number list, so
all we have to do is supply the current environment and this list to
`get` and take the car, i.e., the first list element, of the result:

        (if (cdr (car expr))
          (car (get env (cdr expr)))

Don't mind the `if` line - it checks for the second boolean in the
expression type cell, in case the first boolean turns out to be false
(this is the alternative path of the outermost `if`.

Last, but not least, we come to the native functions, the purpose of
which I have not yet mentioned. While the first three expression types
are sufficient to implement any function, the interpreter still lacks
the ability to do input and output. Instead of putting this
functionality directly into the interpreter, for example by creating a
new expression type for each input/output function, and thereby
blowing up the interpreter by a considerable amount, I decided to
simply add the functionality to call a "native", i.e., non
interpreted, function, which is directly embedded in the intermediate
code. The code for this expression type looks a bit complicated, but
it is really quite simple:

          (cons () ((cdr expr) (cons (cons #t #t) (cons (cons #f #t) ())))))))

The cdr of the expression cell contains the native function, so we
apply it to some argument. Since most I/O function in Unlambda
behave - apart from their side effect - like the identity function,
and even a native function must return a result in the form of an
interpretable closure, we pass the native function an expression cell
for an interpretable identity function, namely the cell `((#t . #t)
. ((#f . #t) . ()))`, which is what the function `(lambda (x) x)`
looks like to the interpreter. Of course, the native function must not
necessarily return this expression cell, but most do. Those which
don't, which are functions returning booleans, checking, for example,
for end-of-file, must nevertheless return valid expression cells. The
outermost cons creates a closure from the expression cell returned by
the native function, with an empty environment.

Finally, we're through. This minimalistic interpreter compiles to
about 400KB of Unlambda code. The benefits are obvious when comparing
the sizes of the directly compiled code versus interpreted code of
more complicated programs. The abovementioned binary adding program,
which is about 18MB in size when compiled directly, now comes to only
470KB, and that includes the interpreter. Furthermore, it consumes
little memory and runs nicely - albeit slowly - on my machine.

## Prerequisites

You'll need the Bigloo Scheme system to compile the compiler.  You can
get it from [the Bigloo homepage](http://www-sop.inria.fr/mimosa/fp/Bigloo/).

Of course, you might also want to get an Unlambda interpreter to
execute the Unlambda programs.  You can get the official Unlambda
distribution from the
[Unlambda homepage](http://www.eleves.ens.fr:8080/home/madore/programs/unlambda/).

A much more efficient Unlambda interpreter is available
[here](http://www.ofb.net/~jlm/unlambda/).

## Compiling

Type

    make

## Usage

To compile a Scheme program directly to Unlambda (without the
interpreter), use

    ./unlcomp -c FILENAME

The Unlambda code is written to stdout.

To compile with the interpreter, use

    ./compile FILENAME

The resulting Unlambda code will be in the file `FILENAME.unl`.

## License

This program is licenced under the GNU General Public License.  See
the file `COPYING` for details.

---
Mark Probst <mark.probst@gmail.com>
