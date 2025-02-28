# Simplex-Algorithm

Basic R implementation of the Simplex algorithm for Linear Programming Optimisation problems (https://en.wikipedia.org/wiki/Simplex_algorithm)

Currently supported: maximisation problems with maximum inequality & non-negativity constraints of the following form:
* Maximise z = **AX**, subject to the dependencies
* **BX** <= **C**,
* **X** >= 0

Usage:

Call the `solve_linear_program()` function with the following arguments:

`objective_function`: The objective function defined via a vector of coefficients: c(coeff01, coeff02, coeff03...) \
`max`: Whether this is a maximisation or minimisation problem \
`max_inequality_constraints`: Set of maximum inequality constraints, defined via coefficients of each variable followed by the constraint limit \
`min_inequality_constraints`: Set of minimum inequality constraints, defined via coefficients of each variable followed by the constraint limit \
`equality_constraints`: Set of equality constraints, defined via coefficients of each variable followed by the constraint value \
`freedom`: Vector defining whether each variable is free or not \

For example:
```
> objective_function = c(40, 30)
> constraints = rbind(c(1, 1, 12), c(2, 1, 16))
> variable_freedom = c(0, 0)
> solve_linear_program(objective_function=objective_function, max_inequality_constraints=constraints, freedom=variable_freedom)
----------------------------------------------------------------------------
Problem summary:
Maximise 40x1 + 30x2
Subject to the constraints:
x1 + x2 <= 12
2x1 + x2 <= 16
x1, x2 >= 0
----------------------------------------------------------------------------
Initial state:  x1: 0. x2: 0. Objective Function: 0 
Iteration #1: x1: 8. x2: 0. Objective Function: 320
Iteration #2: x1: 4. x2: 8. Objective Function: 400

Optimisation complete:
x1: 4
x2: 8
Objective Function: 400
```

Dependencies:
* library(grid)
* library(gridExtra)
* library(ggplotify)
