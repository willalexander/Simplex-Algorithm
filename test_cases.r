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
A = c(40, 30)
B = rbind(c(1, 1), c(2, 1))
C = c(12, 16)

solve_linear_program(A, B, C)

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
A = c(1, 1)
B = rbind(c(1, 0), c(-1, 0))
C = c(5, -10)

solve_linear_program(A, B, C)

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
A = c(1, 1)
B = rbind(c(1, 0), c(1, 0))
C = c(5, 10)

solve_linear_program(A, B, C)

# Expected result:
# Solution should end early, detecting that the problem is unbounded.

