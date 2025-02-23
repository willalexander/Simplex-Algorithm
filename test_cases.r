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
