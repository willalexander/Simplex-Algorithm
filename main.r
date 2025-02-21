library(grid)
library(gridExtra)
library(ggplotify)

EPSILON = 0.000001

initialise_simplex <- function(A, B, C) {
    # Creates & initialises a global Simplex tableau,
    # using the A, B & C standard form values provided.
    # Displays the resulting tableau.

    tableau = matrix(nrow=0, ncol=length(A) + dim(B)[2] + 2)

    for(i in 1:dim(B)[2])
    {
        row = B[i,]
        for(j in 1:dim(B)[2])
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

    var_name <- function(base, index)
        paste(base, as.character(index), sep="")
    col_names = c(var_name("x", 1:length(A)), var_name("y", 1:dim(B)[1]), 'z', 'RHS')
    colnames(tableau) <- col_names
    rownames(tableau) <- rep("", dim(B)[1] + 1)

    tableau <<- tableau

    display_simplex()
}

iterate_simplex <- function() {
    # Perform 1 iteration of the simplex algorithm on
    # the global tableau. 
    # Displays the resulting tableau.

    if(!optimum_is_attained())
    {
        bottom_row = get_bottom_row(tableau)
        pivot_column = find_smallest_entry(bottom_row)
        pivot_row = find_smallest_ratio(pivot_column)
        tableau = pivot_tableau(pivot_column, pivot_row)
        tableau <<- tableau
    }

    display_simplex()
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

        most_zeros = 0
        best_row = c()
        for(j in 1:(dim(tableau)[1]))
        {   
            if(i == j)
                next

            if(tableau[j, pivot_column] == 0)
                next

            new_row = tableau[i,] - tableau[j,] * (tableau[i, pivot_column] / tableau[j, pivot_column])
            num_zeros = get_num_zeros(new_row)
            if(num_zeros > most_zeros)
            {
                most_zeros = num_zeros
                best_row = new_row
            }
        }
        tableau[i,] = best_row
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

find_smallest_entry <- function(row) {
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

find_smallest_ratio <- function(pivot_column) {
    # Find the column position with the smallest value of 
    # the ratio pivot column / RHS column.

    smallest_index = 0
    smallest_ratio = 100000

    for(i in 1:(dim(tableau)[1]-1))
    {
        if(tableau[i, dim(tableau)[2]] == 0)
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

    for(i in 1:dim(B)[1])
    {
        val = as.numeric(B[i,] %*% P)
        if(val > (C[i] + EPSILON))
            return(FALSE)
    }
    return(TRUE)
}

generate_line_segments <- function() {
    # Generates the boundary points of the linear program's
    # convex feasible region, by intersecting all constaint lines.

    Be = rbind(B, c(1, 0), c(0, 1))
    Ce = append(C, c(0, 0))

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
                points_d = rbind(points_d, intersection_P)
        }
    }

    return(points_d)
}

graph_plot <- function() {
    # Plot the feasible region filled interior and its boundary
    # lines and points.
    # Also plot the current solution position, reflected by
    # the tableau

    plot(points_d)
    plot(mat, pch=20, col=cols)
    for(i in 1:(0.5*dim(points_d)[1]))
    {
        lines(points_d[(i*2-1):(i*2), 1], points_d[(i*2-1):(i*2), 2])
    }

    col = "red"
    if(optimum_is_attained())
        col="green"
    points(current_solution[1], current_solution[2], pch=19, col=col)
}

display_simplex <- function() {
    # Display the current state of the Simplex algorithm:
    # 1. The graphical representation
    # 2. The Simplex tableau
    # 3. Current values for the main variables & objective function

    points_d = generate_line_segments()

    x_max = max(points_d[,1])
    y_max = max(points_d[,2])

    step = x_max / 50
    sq_x = seq(0.0, x_max, step)
    sq_y = seq(0.0, y_max, step)
    mat = cbind(rep(sq_x, length(sq_y)), rep(sq_y, each=length(sq_x)))

    cols=rep("cadetblue1", dim(mat)[1])
    for(i in 1:dim(mat)[1])
    {
        if(!in_feasible_region(mat[i,]))
            cols[i] = "white"
    }

    table_plot = tableGrob(tableau)

    points_d <<- points_d
    mat <<- mat
    cols <<-cols

    solution_vector = interpet_tableau()
    current_solution <<- solution_vector[1:2]

    col = "red"
    status = "Optimum not yet acheived."
    if(optimum_is_attained())
    {
        col="green"
        status = "** OPTIMUM ACHIEVED **"
    }

    solution_text = paste(status, "\n", "x1: ", as.character(current_solution[1]), "\n", "x2: ", as.character(current_solution[2]), "\n", "Objective Function: ", as.character(A %*% current_solution), "\n")

    lay <- rbind(c(1,1,2),
                 c(1,1,3))
    grid.arrange(as.grob(graph_plot), table_plot, textGrob(label=solution_text, gp=gpar(col=col)), layout_matrix = lay)
}
