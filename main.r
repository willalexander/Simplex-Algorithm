library(grid)
library(gridExtra)
library(ggplotify)

EPSILON = 0.000001

PIVOT_RULE = "LARGEST_NEGATIVE"

initialise_simplex <- function(A, B, C, display) {
    # Creates & initialises a global Simplex tableau,
    # using the A, B & C standard form values provided.
    # If indicated, displays the resulting tableau.

    tableau = matrix(nrow=0, ncol=length(A) + dim(B)[1] + 2)

    for(i in 1:dim(B)[1])
    {
        row = B[i,]
        for(j in 1:dim(B)[1])
        {
            if(j == i)
                row = append(row, 1)
            else
                row = append(row, 0)
        }
        row = append(row, c(0, C[i]))

        tableau = rbind(tableau, row)
    }

    bottom_row = c(-A, rep(0, dim(B)[1]), 1, 0)
    tableau = rbind(tableau, bottom_row)

    col_names = c(var_name("x", 1:length(A)), var_name("y", 1:dim(B)[1]), 'z', 'RHS')
    colnames(tableau) <- col_names
    rownames(tableau) <- rep("", dim(B)[1] + 1)

    equal_objective_function_count <<- 0

    tableau <<- tableau

    if(display)
        display_simplex()
}

iterate_simplex <- function(display) {
    # Perform 1 iteration of the simplex algorithm on
    # the global tableau. 
    # If indicated, displays the resulting tableau.

    if((problem_is_valid()) && (!optimum_is_attained()))
    {
        current_objective_function_value = current_objective_function()

        bottom_row = get_bottom_row(tableau)

        if(PIVOT_RULE == "LARGEST_NEGATIVE")
            pivot_column = pivot_rule_largest_negative(bottom_row)
        else
            pivot_column = pivot_rule_smallest_negative(bottom_row)
        
        pivot_row = find_smallest_ratio(pivot_column)
        tableau = pivot_tableau(pivot_column, pivot_row)
        tableau <<- tableau

        new_objective_function_value = current_objective_function()
        if(new_objective_function_value > current_objective_function_value)
            equal_objective_function_count <<- 0
        else
        {
            equal_objective_function_count <<- equal_objective_function_count + 1
            if((equal_objective_function_count == 10) && (problem_is_degenerate()))
                change_pivot_rule()
        }
    }

    if(display)
        display_simplex()
}

var_name <- function(base, index)
    paste(base, as.character(index), sep="")

problem_is_degenerate <- function() {
    # Determine whether the current state of the system is degenerate.

    for(i in 1:(dim(tableau)[1] - 1))
    {
        if(tableau[i, dim(tableau)[2]] == 0)
            return(TRUE)
    }
    return(FALSE)
}

change_pivot_rule <- function() {
    # Switch between the two supported pivot rules

    if(PIVOT_RULE == "LARGEST_NEGATIVE")
        PIVOT_RULE <<- "SMALLEST_NEGATIVE"
    else
        PIVOT_RULE <<- "LARGEST_NEGATIVE"
}

get_identity_index <- function(column) {
    # Find the position of the identity element in a matrix column,
    # if it is an identity column (all 0s and one 1)
    # If not, return -1.

    for(i in 1:length(column))
    {
        if((column[i] != 0) && (column[i] != 1))
            return(-1)
    }

    if(sum(column) != 1)
        return(-1)

    for(i in 1:length(column))
    {
        if(column[i] == 1)
            return(i)
    }
}

get_bottom_row <- function(tableau) {
    # Return the bottom row of the Simplex tableau.
    
    bottom_row = unname(tableau)[dim(tableau)[1],]
    bottom_row = bottom_row[1:length(bottom_row) - 1]
    return(bottom_row)
}

optimum_is_attained <- function() {
    # Whether the Simplex tableau is in optimal form.
    # It's in optimal form if there are no negative elements
    # in the bottom row.

    bottom_row = get_bottom_row(tableau)

    if(min(bottom_row) >= 0)
        return(TRUE)

    return(FALSE)
}

problem_is_valid <- function() {
    # Check whether the problem is both feasible & bounded

    return (problem_is_feasible() && problem_is_bounded())
}

problem_is_feasible <- function() {
    # Determine whether current tableau state is feasible, by
    # detecting infeasible cases.

    for(i in 1:(dim(tableau)[1] - 1))
    {
        row_main = tableau[i,][1:(dim(tableau)[2] - 1)]
        RHS_element = tableau[i, dim(tableau)[2]]
        row_sign = row_has_same_sign(row_main)
        if(row_sign == 0)
            next

        if(row_sign != sign(RHS_element))
            return(FALSE)
    }
    return(TRUE)
}

problem_is_bounded <- function() {
    # Determine whether current tableau state is bounded, by
    # detecting unbounded feasible cases.

    for(i in 1:(dim(tableau)[2] - 1))
    {
        bottom_row_element = tableau[dim(tableau)[1], i]
        if(bottom_row_element >= 0)
            next

        all_elements_non_positive = TRUE
        for(j in 1:(dim(tableau)[1] - 1))
        {
            if(tableau[j, i] > 0)
                all_elements_non_positive = FALSE
        }
        if(all_elements_non_positive)
            return(FALSE)
    }
    return(TRUE)
}

row_has_same_sign <- function(row) {
    # Determine whether all non-zero elements of the given row 
    # have the same sign. If so, return that sign. If not, return zero.

    row_signs = sign(row)
    row_sign = 0
    for(i in 1:length(row_signs))
    {
        if(row_signs[i] == 0)
            next

        if(row_sign == 0)
        {
            row_sign = row_signs[i]
            next
        }

        if(row_sign != row_signs[i])
            return(0)
    }
    return(row_sign)
}

interpet_tableau <- function() {
    # Determine the current values of the main & slack 
    # variables represented by the current state of 
    # the Simplex tableau. Return NULL if not interpretable.

    slots = rep(0, dim(tableau)[2] - 1)
    for(i in 1:(dim(tableau)[2] - 1))
    {
        column = tableau[,i]

        index = get_identity_index(column)
        if(index != -1)
        {
            if(slots[i] == 0)
                slots[i] = 1
        }

        if(sum(slots) >= dim(tableau)[1])
            break
    }

    if(sum(slots) >= dim(tableau)[1])
    {
        RHS = tableau[, dim(tableau)[2]]
        
        solution_vector = rep(0, dim(tableau)[2] - 1)

        for(i in 1:(dim(tableau)[2] - 1))
        {
            if(slots[i] == 1)
            {
                column = tableau[,i]
                index = get_identity_index(column)

                solution_vector[i] = RHS[index]
            }
            else
                solution_vector[i] = 0
        }

        return(solution_vector)
    }
    else
    {
        return(NULL)
    }
}

pivot_tableau <- function(pivot_column, pivot_row) {
    # Perform a Simplex algorithm tableau pivot around the
    # given pivot element (specified by the given pivot column 
    # and row) 

    if(tableau[pivot_row, pivot_column] != 0)
    {
        tableau[pivot_row,] = tableau[pivot_row,] / tableau[pivot_row, pivot_column]
    }
    else
    {
        most_zeros = 0
        best_row = c()
        for(i in 1:(dim(tableau)[1]))
        {
            if(i == pivot_row)
                next

            if(new_tableau[i, pivot_column] == 0)
                next

            new_row = tableau[pivot_row,] + tableau[i,] * (1 / tableau[i, pivot_column])
            
            num_zeros = get_num_zeros(new_row)

            if(num_zeros > most_zeros)
            {
                most_zeros = num_zeros
                best_row = new_row
            }
        }
        tableau[pivot_row,] = best_row
    }

    for(i in 1:(dim(tableau)[1]))
    {
        if(i == pivot_row)
            next

        if(tableau[i, pivot_column] == 0)
            next

        tableau[i,] = tableau[i,] - tableau[pivot_row,] * (tableau[i, pivot_column] / tableau[pivot_row, pivot_column])
    }
    tableau <<- tableau
}

get_num_zeros <- function(row) {
    # Count the number of 0s in the given vector

    count = 0
    for(i in 1:(length(row) - 1))
    {
        if(row[i] == 0)
            count = count + 1
    }
    return(count)
}

pivot_rule_largest_negative <- function(row) {
    # Find the position of the smallest element in 
    # the given vector.

    min_index = 0
    min_value = 100000
    for(i in 1:length(row))
    {
        if(row[i] < min_value)
        {
            min_index = i
            min_value = row[i]
        }
    }
    return(min_index)
}

pivot_rule_smallest_negative <- function(row) {
    # Find the position of the negative element with smallest
    # magnitude in the given vector.

    max_index = 1
    max_value = -100000
    for(i in 1:length(row))
    {
        if(row[i] >= 0)
            next

        if(row[i] > max_value)
        {
            max_index = i
            max_value = row[i]
        }
    }
    return(max_index)
}

find_smallest_ratio <- function(pivot_column) {
    # Find the column position with the smallest value of 
    # the ratio pivot column / RHS column.

    smallest_index = 0
    smallest_ratio = 100000

    for(i in 1:(dim(tableau)[1]-1))
    {
        if(tableau[i, pivot_column] <= 0)
            next

        ratio = tableau[i, dim(tableau)[2]] / tableau[i, pivot_column] 
        if(ratio < smallest_ratio)
        {
            smallest_ratio = ratio
            smallest_index = i
        }
    }
    return(smallest_index)
}

find_non_zero_element_in_column <- function(column) {
    # Find the first non-zero element in the given vector.

    for(i in 1:length(column))
    {
        if(column[i] != 0)
            return(i)
    }
}

get_intersection <- function(B1, C1, B2, C2) {
    # Find the intersection point between two lines, specified
    # in B * X = C form

    m1 = -B1[1]/B1[2]
    c1 = C1/B1[2]

    m2 = -B2[1]/B2[2]
    c2 = C2/B2[2]

    if((abs(m1) == Inf) && (abs(m2) == Inf))
        return(c())

    if(m1 == m2)
        return(c())

    if(abs(m1) == Inf)
    {
        x = C1
        return(c(x, m2*x + c2))
    }

    if(abs(m2) == Inf)
    {
        x = C2
        return(c(x, m1*x + c1))
    }

    x = (c2 - c1) / (m1 - m2)
    y = m1 * x + c1

    return(c(x, y))
}

in_feasible_region <- function(P) {
    # Determine whether the given poins is with in the 
    # Linear program's feasible region.     

    if(P[1] < 0.0)
        return(FALSE)
    if(P[2] < 0.0)
        return(FALSE)

    for(i in 1:dim(simplex_B)[1])
    {
        val = as.numeric(simplex_B[i,] %*% P)
        if(val > (simplex_C[i] + EPSILON))
            return(FALSE)
    }
    return(TRUE)
}

generate_line_segments <- function() {
    # Generates the boundary points of the linear program's
    # convex feasible region, by intersecting all constaint lines.

    Be = rbind(simplex_B, c(1, 0), c(0, 1))
    Ce = append(simplex_C, c(0, 0))

    points_d = matrix(nrow=0, ncol=2)

    for(i in 1:dim(Be)[1])
    {
        for(j in 1:dim(Be)[1])
        {
            if(i == j)
                next

            intersection_P = get_intersection(Be[i,], Ce[i], Be[j,], Ce[j])

            if(length(intersection_P) == 0)
                next

            if(in_feasible_region(intersection_P))
            {
                points_d = rbind(points_d, intersection_P)
            }
        }
    }

    return(points_d)
}

graph_plot <- function() {
    # Plot the feasible region filled interior and its boundary
    # lines and points.
    # Also plot the current solution position, reflected by
    # the tableau

    if(dim(points_d)[1] > 0)
        plot(points_d)

    plot(mat, pch=20, col=cols)

    if(dim(points_d)[1] > 0)
    {
        for(i in 1:(0.5*dim(points_d)[1]))
        {
            lines(points_d[(i*2-1):(i*2), 1], points_d[(i*2-1):(i*2), 2])
        }
    }

    col = "red"
    if(optimum_is_attained())
        col="green"

    points(current_solution[1], current_solution[2], pch=19, col=col)
}

current_objective_function <- function() {
    # Compute the value of the objective function given the system's
    # current state.

    solution_vector = interpet_tableau()
    current_solution <<- solution_vector[1:length(simplex_A)]
    objective_function = simplex_A %*% current_solution
    return(objective_function)
}

summarise_state <- function(compact) {
    # Return a string describing the current values of the
    # main variables & objective function

    solution_vector = interpet_tableau()

    if(is.null(solution_vector))
        return("")

    current_solution <<- solution_vector[1:length(simplex_A)]

    sep = "\n"
    if(compact)
        sep = ". "

    state_text = paste("x1: ", as.character(current_solution[1]), sep, "x2: ", as.character(current_solution[2]), sep, "Objective Function: ", as.character(simplex_A %*% current_solution), sep="")
    return(state_text)
}

display_simplex <- function() {
    # Display the current state of the Simplex algorithm:
    # 1. The graphical representation
    # 2. The Simplex tableau
    # 3. Current values for the main variables & objective function

    if(length(simplex_A) == 2)
    {
        points_d = generate_line_segments()

        if(dim(points_d)[1] > 0)
        {
            x_max = max(points_d[,1])
            y_max = max(points_d[,2])

            step = x_max / 50
            sq_x = seq(0.0, x_max, step)
            sq_y = seq(0.0, y_max, step)
            mat = cbind(rep(sq_x, length(sq_y)), rep(sq_y, each=length(sq_x)))
        }
        else
        {
            mat = matrix(nrow=1, ncol=2, c(0, 0))
        }

        cols=rep("cadetblue1", dim(mat)[1])
        for(i in 1:dim(mat)[1])
        {
            if(!in_feasible_region(mat[i,]))
                cols[i] = "white"
        }
    }
    else
    {
        points_d = matrix(nrow=1, ncol=2, c(0, 0))
        mat = matrix(nrow=1, ncol=2, c(0, 0))
        cols = c("white")
    }

    table_plot = tableGrob(tableau)

    points_d <<- points_d
    mat <<- mat
    cols <<-cols

    state_text = summarise_state(compact=FALSE)

    col = "red"
    status = ""  
    if(!problem_is_feasible())
        status = "PROBLEM IS INFEASIBLE"
    else if(!problem_is_bounded())
        status = "PROBLEM IS UNBOUNDED"
    else
    {
        status = "Optimum not yet achieved."  
        if(optimum_is_attained())
        {
            col="green"
            status = "** OPTIMUM ACHIEVED **"
        }
    }

    solution_text = paste(status, "\n", state_text, "\n")

    if(length(simplex_A) == 2)
    {
        lay <- rbind(c(1,1,2),
                    c(1,1,3))
        grid.arrange(as.grob(graph_plot), table_plot, textGrob(label=solution_text, gp=gpar(col=col)), layout_matrix = lay)
    }
    else
    {
        lay <- rbind(c(1),
                    c(2))
        grid.arrange(table_plot, textGrob(label=solution_text, gp=gpar(col=col)), layout_matrix = lay)
    }
}

solve_simplex <- function(A, B, C) {
    # Create simplex tableau for the given linear programming problem.
    # Iterate using the simplex method until otimisation is achieved.

    initialise_simplex(A, B, C, display=FALSE)
    state_text = summarise_state(compact=TRUE)
    cat("Initial state: ", state_text, "\n")

    count = 1
    while((problem_is_valid())&&(!optimum_is_attained()))
    {   
        iterate_simplex(display=FALSE)
        state_text = summarise_state(compact=TRUE)
        cat("Iteration #", count, ": ", state_text, "\n", sep="")
        count = count + 1
    }

    if(problem_is_valid())
    {
        cat("\nOptimisation complete:\n")
        state_text = summarise_state(compact=FALSE)
        cat(state_text, "\n")
    }
    else
    {
        if(!problem_is_feasible())
            cat("Failed. Problem is not feasible.")
        else
            cat("Failed. Problem is unbounded.")
    }
}

solve_linear_program <- function(objective_function, 
                                 max = TRUE,
                                 max_inequality_constraints = NULL,
                                 min_inequality_constraints = NULL,
                                 equality_constraints = NULL,
                                 freedom) {

    # Parse linear program definition arguments, and convert them into
    # standard form recognisable by Simplex Algorithm.
    # Run the Simplex Algorithm.

    if(max == FALSE)
    {
        print("ERROR. Minimisation problems not yet supported")
        return
    }

    if(!is.null(min_inequality_constraints))
    {
        print("ERROR. Minimum constraints not yet supported")
        return
    }

    if(!is.null(equality_constraints))
    {
        print("ERROR. Equality constraints not yet supported")
        return
    }

    simplex_A <<- objective_function
    
    if((dim(max_inequality_constraints)[2] - 1) != length(simplex_A))
    {
        print("ERROR. Number of constraint coeffecients does not match number of objective function coefficients.")
    }
    simplex_B <<- max_inequality_constraints[1:dim(max_inequality_constraints)[1], 1:length(simplex_A)]

    simplex_C <<- max_inequality_constraints[,length(simplex_A) + 1]

    cat("----------------------------------------------------------------------------\n")
    cat("Problem summary:\n")
    cat("Maximise ")
    

    includes = c()
    for(i in 1:length(simplex_A))
    {
        if(simplex_A[i] != 0)
            includes = append(includes, i)
    }

    for(a in 1:length(includes))
    {
        i = includes[a]

        if(simplex_A[i] != 1)
            coeff = as.character(abs(simplex_A[i]))
        else
            coeff = ""

        if(a > 1)
        {
            if(simplex_A[i] > 0.0)
                cat(" + ")
            else
                cat(" - ")
        }

        cat(coeff, var_name("x", i), sep="")
    }

    
    cat("\n")
    cat("Subject to the constraints:\n")
    for(c in 1:dim(simplex_B)[1])
    {
        includes = c()
        for(i in 1:dim(simplex_B)[2])
        {
            if(simplex_B[c, i] != 0)
                includes = append(includes, i)
        }

        for(a in 1:length(includes))
        {
            v = includes[a]

            if(simplex_B[c, v] == 0)
                next

            if(simplex_B[c, v] != 1)
                coeff = as.character(abs(simplex_B[c, v]))
            else
                coeff = ""

            if(a > 1)
            {
                if(simplex_B[c, v] > 0.0)
                    cat(" + ")
                else
                    cat(" - ")
            }

            cat(coeff, var_name("x", v), sep="")
        }
        cat(" <= ")
        cat(simplex_C[c])
        cat("\n")
    }
    
    includes = c()
    for(i in 1:length(simplex_A))
    {
        if(freedom[i] == 0)
            includes = append(includes, i)
    }
    for(a in 1:length(includes))
    {
        v = includes[a]

        if(freedom[v] == 1)
            next
        cat(var_name("x", v), sep="")
        if(a != length(includes))
            cat(", ")
    }
    cat(" >= 0\n")
    cat("----------------------------------------------------------------------------\n")

    solve_simplex(simplex_A, simplex_B, simplex_C)
}