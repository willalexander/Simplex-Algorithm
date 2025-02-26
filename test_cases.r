# Test cases for Simplex Method implementation.
#
# TODO: Convert these into automated unit tests

# Case 01:
# Simple 2D linear program
# 
# Maximise 40x1 + 30x2, subject to the constraints
# x1 + x2 <= 16
# 2x1 + x2 <= 12
# x1, x2 >= 0
# 
# Code:  
objective_function = c(40, 30)
constraints = rbind(c(1, 1, 12), c(2, 1, 16))
variable_freedom = c(0, 0)
solve_linear_program(objective_function=objective_function, max_inequality_constraints=constraints, freedom=variable_freedom)
#
# Expected result:
# x1: 4
# x2: 8
# Objective Function: 400


# Case 02:
# Example of an infeasible 2D linear program
# 
# Maximise x1 + x2, subject to the constraints
# x1 =< 5
# -x1 <= -10
# 
# Code:  
objective_function = c(1, 1)
constraints = rbind(c(1, 0, 5), c(-1, 0, -10))
variable_freedom = c(0, 0)
solve_linear_program(objective_function=objective_function, max_inequality_constraints=constraints, freedom=variable_freedom)
#
# Expected result:
# Solution should end early, detecting that the problem is infeasible.
# N.B. this problem is also unbounded, and this will be dectected first. Need
# to find an example which is unfeasible but bounded.


# Case 03:
# Example of an unbounded 2D linear program
# 
# Maximise x1 + x2, subject to the constraints
# x1 <= 5
# x1 <= 10
# 
# Code:
objective_function = c(1, 1)
constraints = rbind(c(1, 0, 5), c(1, 0, 10))
variable_freedom = c(0, 0)
solve_linear_program(objective_function=objective_function, max_inequality_constraints=constraints, freedom=variable_freedom)
#
# Expected result:
# Solution should end early, detecting that the problem is unbounded.


# Case 04:
# Example of a linear program exhibiting cycling & degeneracy
# 
# Maximise x1 + x2, subject to the constraints
# x1 <= 5
# x1 <= 10
# 
# Code: 
objective_function = c(0.75, -20, 0.5, -6)
constraints = rbind(c(0.25, -8, -1, 9, 0), c(0.5, -12, -0.5, 3, 0), c(0, 0, 1, 0, 1))
variable_freedom = c(0, 0, 0, 0)
solve_linear_program(objective_function=objective_function, max_inequality_constraints=constraints, freedom=variable_freedom)
#
# Expected result:
# With the default algorithm, this problem would exhibit cycling. The process
# should detect this, adjust the algorithm and reach a solution:
# x1: 1
# x2: 0
# Objective Function: 1.25
