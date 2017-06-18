# UnlambdaScheme

For a description of what this program does and how it does it, see
[my "old stuff" page](http://www.complang.tuwien.ac.at/schani/oldstuff/).

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
