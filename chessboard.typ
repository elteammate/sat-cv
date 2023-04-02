#import "logic.typ": *
#import "utils.typ": *

#let n = 8

#let queens_problem() = {
    let queens = range(n).map(y => range(n).map(x => repr((y, x))))

    let constraints = ()

    for k in range(n) {
        constraints.push(extras_exactly_one_of(queens.at(k)))
        constraints.push(extras_exactly_one_of(queens.map(row => row.at(k))))
    }

    for k in range(-n, n) {
        let diagonal = ()
        let anti_diagonal = ()
        for x in range(n) {
            let y = k + x
            if y >= 0 and y < n { diagonal.push(queens.at(y).at(x)) }
            let y = k + n - x
            if y >= 0 and y < n { anti_diagonal.push(queens.at(y).at(x)) }
        }

        constraints.push(extras_at_most_one_of(diagonal))
        constraints.push(extras_at_most_one_of(anti_diagonal))
    }

    constraints.push(queens.at(2).at(2))

    let solution = sat(..constraints).solution
    
    range(n).map(y => range(n).map(x => {
        solution.at(repr((y, x)))
    }))
}

#let chessboard_size = 5cm
#let cell_size = chessboard_size / n

#let black_color = rgb("#f28c26")
#let white_color = rgb("#f28c26").lighten(80%)

#let queen = move(dx: -cell_size * 0.19, dy: -cell_size * 0.3, text(cell_size * 0.8, icon("queen")))

#let solution = grid(..map2(queens_problem(), (row_no, row) => {
    map2(row, (col_no, col) => {
        let inside = if col { queen } else { none }
        if calc.mod(row_no + col_no, 2) == 0 {
            square(size: cell_size, fill: white_color)[#inside]
        } else {
            square(size: cell_size, fill: black_color)[#inside]
        }
    })
}).flatten(), columns: (cell_size, ) * n)

#solution
