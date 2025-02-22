# Simplex-Algorithm

Basic R implementation of the Simplex algorithm for Linear Programming Optimisation problems (https://en.wikipedia.org/wiki/Simplex_algorithm)

Provides graphical display for 2 dimensional problems.

Usage:

Problem should be expressed in 'standard form' for linear programming:

* Maximise z = **AX**, subject to the dependencies
* **BX** <= **C**,
* **X** >= 0

1. Declare values for **A**, **B**, & **C**
2. Initialise the Simplex tableau
3. Iterate the Simplex tableau until optimal form is found.

E.g:
```
> A = c(14, 96)
> B = rbind(c(3, 5), c(7, 4))
> C = c(37, 54)

> initialise_simplex(A, B, C)
> iterate_simplex()
> iterate_simplex()
> iterate_simplex()
> .
> .
> .
```
Dependencies:
* library(grid)
* library(gridExtra)
* library(ggplotify)
