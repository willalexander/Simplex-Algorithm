# Simplex-Algorithm

Basic R implementation of the Simplex algorithm for Linear Programming Optimisation problems (https://en.wikipedia.org/wiki/Simplex_algorithm)

Usage:

Problem should be expressed in 'standard form' for linear programming:

* Maximise z = **AX**, subject to the dependencies
* **BX** <= **C**,
* **X** >= 0

Optimisation is performed by defining the linear program and calling `solve_linear_program()`: 
```
> A = c(40, 30)
> B = rbind(c(1, 1), c(2, 1))
> C = c(12, 16)
> solve_linear_program(A, B, C)
Initial state:  x1: 0. x2: 0. Objective Function: 0 
Iteration #1: x1: 8. x2: 0. Objective Function: 320
Iteration #2: x1: 4. x2: 8. Objective Function: 400

Optimisation complete:
x1: 4
x2: 8
Objective Function: 400
```

Alternatively, each iteration step can be performed manually, with intermediate information displayed: 
(graphical display only available for 2 dimensional problems)

<img src="/images/simplex_iteration_01.png" width=30%/><img src="/images/simplex_iteration_02.png" width=30%/><img src="/images/simplex_iteration_03.png" width=30%/>

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
