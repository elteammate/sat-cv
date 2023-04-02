#set page(height: auto, margin: 0.5cm)

#let ___module_exports = {
  let un_op(op, arg) = (op: op, arg: arg)
  let op(op, ..args) = (op: op, args: args.pos())
  
  let and_(..args) = op("&", ..args)
  let or_(..args) = op("|", ..args)
  let not_(arg) = un_op("!", arg)

  let extras_xor(lhs, rhs)       = op("^"  , lhs, rhs)
  let extras_imply(lhs, rhs)     = op("->" , lhs, rhs)
  let extras_if(lhs, rhs)        = op("<-" , lhs, rhs)
  let extras_not_imply(lhs, rhs) = op("!->", lhs, rhs)
  let extras_not_if(lhs, rhs)    = op("!<-", lhs, rhs)
  let extras_eq(lhs, rhs)        = op("="  , lhs, rhs)
  let extras_nand(lhs, rhs)      = op("!&" , lhs, rhs)
  let extras_nor(lhs, rhs)       = op("!|" , lhs, rhs)
  let extras_lhs_id(lhs, rhs)    = op("<|" , lhs, rhs)
  let extras_rhs_id(lhs, rhs)    = op("|>" , lhs, rhs)

  let extras_at_most_one_of(args) = {
    let if_one_then_not_other = ()
    for x1 in args {
      for x2 in args {
        if x1 != x2 {
          if_one_then_not_other.push(
            extras_imply(x1, not_(x2))
          )
        }
      }
    }
    and_(..if_one_then_not_other)
  }

  let extras_exactly_one_of(args) = {
    and_(..extras_at_most_one_of(args).args, or_(..args))
  }

  let is_var(f) = type(f) == "string"
  let is_const(f) = type(f) == "boolean"
  let is_unary(f) = type(f) == "dictionary" and "arg" in f
  let is_binary(f) = type(f) == "dictionary" and "args" in f

  let to_math(f) = {
    if is_var(f) {
      $#{f}$
    } else if is_const(f) {
      if f {
        $tack.b$
      } else {
        $tack.t$
      }
    } else if is_unary(f) {
      if f.op == "!" {
        if not is_binary(f.arg) {
          $not #{to_math(f.arg)}$
        } else {
          $not (#{to_math(f.arg)})$
        }
      } else {
        (:).at("Error: Unknown Operator " + f.op)
      }
    } else {
      f.args.map(x => {
        if is_binary(x) {
          $(#to_math(x))$
        } else {
          $#to_math(x)$
        }
      }).join((
        "&": $and$,
        "|": $or$,

        "^": $plus.circle$,
        "->": $arrow$,
        "<-": $arrow.l$,
        "!->": $arrow.not$,
        "!<-": $arrow.l.not$,
        "=": $ident$,
        "!&": $space.hair bar space.hair$,
        "!|": $space.hair arrow.b space.hair$,
        "<|": $tack.r$,
        "|>": $tack.l$,
      ).at(f.op))
    }
  }

  let bin_op_truth_table = (
    "&":   (false, false, false, true ),
    "|":   (false, true , true , true ),
    "^":   (false, true , true , false),
    "->":  (true , true , false, true ),
    "<-":  (true , false, true , true ),
    "!->": (false, false, true , false),
    "!<-": (false, true , false, false),
    "=":   (true , false, false, true ),
    "!&":  (true , true , true , false),
    "!|":  (true , false, false, false),
    "<|":  (false, false, true , true ),
    "|>":  (false, true , false, true ),
  )

  let overload_args_as_dict(args) = {
    if args.named().len() == 0 and args.pos().len() == 1 {
      args = args.pos().at(0)
    } else if args.pos().len() == 0 {
      args = args.named()
    } else {
      (:).at("Undefined overload")
    }

    args
  }

  let dict_product(dict) = {
    let result = ((:), )
    for (k, values) in dict.pairs() {
      let new_result = ()
      for v in values {
        new_result += result.map(x => {
          x.insert(k, v)
          x
        })
      }
      result = new_result
    }
    result
  }

  let product(arrs) = {
    let result = ((), )
    for arr in arrs {
      let new_result = ()
      for el in arr {
        new_result += result.map(x => {
          x.push(el)
          x
        })
      }
      result = new_result
    }
    result
  }

  let arr_to_index_dict(arr) = {
    let result = (:)
    for (i, x) in arr.enumerate() { result.insert(str(x), i) }
    result
  }

  let dedup(arr) = {
    let result = ()
    for (i, x) in arr.enumerate() {
      if i + 1 >= arr.len() or arr.at(i + 1) != x {
        result.push(x)
      }
    }
    result
  }

  let filter_by(arr, filter) = {
    let result = ()
    for (i, x) in arr.enumerate() {
      if filter.at(i) { result.push(x) }
    }
    result
  }

  let dict_of_one(key, value) = {
    let res = (:)
    res.insert(key, value)
    res
  }

  let zip_into_dict(keys, values) = {
    let res = (:)
    for (i, k) in keys.enumerate() {
      res.insert(k, values.at(i))
    }
    res
  }

  let argmax(arr) = {
    let max = arr.at(0)
    let max_i = 0
    for (i, x) in arr.enumerate() {
      if x > max { 
        max_i = i
        max = x
      }
    }
    return max_i
  }

  /// Removes operators other than `and`, `or` and `not`,
  /// does constant folding, removes double `not`s.
  let normalize_initial(f) = {
    let normalized = if is_var(f) or is_const(f) {
      f
    } else if is_unary(f) {
      f.arg = normalize_initial(f.arg)
      if f.op == "!" {
        if is_unary(f.arg) and f.arg.op == "!" {
          f.arg.arg
        } else if is_const(f.arg) {
          not f.arg
        } else {
          f
        }
      }
    } else if f.op in ("&", "|") {
      f.args = f.args.map(arg => {
        arg = normalize_initial(arg)
        if is_binary(arg) and arg.op == f.op {
          arg.args
        } else {
          arg
        }
      }).flatten()
      if f.op == "&" {
        if false in f.args {return false}
        f.args = f.args.filter(arg => arg != true)
        if f.args.len() == 0 { return true }
      } else if f.op == "|" {
        if true in f.args {return true}
        f.args = f.args.filter(arg => arg != false)
        if f.args.len() == 0 { return false }
      }
      f
    } else {
      let lhs = normalize_initial(f.args.at(0))
      let rhs = normalize_initial(f.args.at(1))
      if f.op == "^" {
        or_(and_(not_(lhs), rhs), and_(lhs, not_(rhs)))
      } else if f.op == "->" {
        or_(not_(lhs), rhs)
      } else if f.op == "<-" {
        or_(lhs, not_(rhs))
      } else if f.op == "!->" {
        and_(lhs, not_(rhs))
      } else if f.op == "!<-" {
        and_(not_(lhs), rhs)
      } else if f.op == "=" {
        or_(and_(lhs, rhs), and_(not_(lhs), not_(rhs)))
      } else if f.op == "!&" {
        not_(and_(lhs, rhs))
      } else if f.op == "!|" {
        not_(or_(lhs, rhs))
      } else if f.op == "<|" {
        lhs
      } else if f.op == "|>" {
        rhs
      }
    }

    if not (is_var(normalized) or is_const(normalized)) { normalized.normalized = true }
    return normalized
  }

  /// Propagates all `not`s in a semi-normalized formula
  /// to make it fully normalized.
  let propagate_not(f) = {
    let impl(f) = {
      if is_var(f) or is_const(f) {
        return f
      } else if is_binary(f) {
        f.args = f.args.map(arg => impl(arg))
        f
      } else {
        f = f.arg
        if is_var(f) {
          return not_(f)
        } else if is_const(f) {
          return not f
        } else if is_binary(f) and f.op == "&" {
          return or_(..f.args.map(arg => impl(not_(arg))))
        } else if is_binary(f) and f.op == "|" {
          return and_(..f.args.map(arg => impl(not_(arg))))
        } else if is_unary(f) and f.op == "!" {
          return impl(f.arg)
        } else {
          (:).at("Unreachable")
        }
      }
    }

    impl(f)
  }

  /// Removes operators other than `and`, `or` and `not`,
  /// performs constant folding, propagates `not`s
  /// so that only terminals are negated.
  /// Sets `normalized` flag
  let normalize(f) = {
    f = propagate_not(normalize_initial(f))
    f.normalized = true
    f
  }

  let smart_negate(f) = {
    if is_var(f) {
      return not_(f)
    } else if is_const(f) {
      return not f
    } else if is_unary(f) {
      if f.op == "!" {
        return f.arg
      }
    } else if is_binary(f) {
      if f.op == "&" {
        or_(..f.args.map(arg => smart_negate(arg)))
      } else if f.op == "|" {
        and_(..f.args.map(arg => smart_negate(arg)))
      } else {
        (:).at("Unsupported operator in smart negate")
      }
    }
  }

  let evaluate(f, ..values) = {
    let values = overload_args_as_dict(values)
    
    let evaluate(f) = {
      if is_const(f) {
        f
      } else if is_var(f) {
        values.at(f)
      } else if is_unary(f) {
        if f.op == "!" {
          not evaluate(f.arg)
        }
      } else if f.args.len() == 2 {
        let lhs = evaluate(f.args.at(0))
        let rhs = evaluate(f.args.at(1))
        bin_op_truth_table.at(f.op).at(
          if lhs and rhs {
            3
          } else if not lhs and rhs {
            2
          } else if lhs and not rhs {
            1
          } else {
            0
          }
        )
      } else if f.op == "&" {
        for arg in f.args {
          if not evaluate(arg) { return false }
        }
        true
      } else {
        for arg in f.args {
          if not evaluate(arg) { return true }
        }
        false
      }
    }

    evaluate(f)
  }

  // Substitute a variable in f with a value
  let subs(f, ..subs) = {
    subs = overload_args_as_dict(subs)
    
    let impl(f) = {
      if is_var(f) {
        if f in subs {
          subs.at(f)
        } else {
          f
        }
      } else if is_const(f) {
        f
      } else if is_unary(f) {
        f.arg = impl(f.arg)
        f
      } else {
        f.args = f.args.map(arg => impl(arg))
        f
      }
    }

    impl(f)
  }
  
  let get_parameters(f) = {
    let result = if is_var(f) {
      dict_of_one(f, none)
    } else if is_unary(f) {
      get_parameters(f.arg)
    } else if is_binary(f) {
      let result = (:)
      for arg in f.args {
        result += get_parameters(arg)
      }
      result
    }

    return result
  }

  let truth_table(f) = {
    let params = get_parameters(f)
    
    let rows = (:)
    for (k, _) in params.pairs() {
      rows.insert(k, (false, true))
    }

    dict_product(rows).map(params => (params, evaluate(f, params)))
  }

  let cnf(f) = {
    if "cnf" in f { return f }
    
    if is_const(f) { return f }
    if is_var(f) { return and_(or_(f)) }

    if "normalized" not in f { f = normalize(f) }

    if is_unary(f) { return and_(or_(f)) }

    if f.op == "&" {
      f.args = f.args.map(arg => cnf(arg).args).flatten()
    } else if f.op == "|" {
      let disjunctions = f.args.map(
        arg => cnf(arg).args.map(arg => arg.args)
      )
      f = and_(
        ..product(disjunctions).map(disj => or_(..disj.flatten()))
      )
    }

    f.cnf = true
    f
  }

  let cnf_to_clauses(cnf) = {
    if cnf.args.map(c => c.args) == ((false, ), ) { return false }
    if cnf.args.map(c => c.args) == ((true, ), ) { return true }
    
    let params = get_parameters(cnf).keys()
    let param_indexes = arr_to_index_dict(params)

    (
      cnf.args.map(disjunction => {
        disjunction.args.map(terminal => {
          if is_var(terminal) {
            param_indexes.at(str(terminal)) + 1
          } else {
            -param_indexes.at(str(terminal.arg)) - 1
          }
        })
      }),
      params
    )
  }

  let optimize_clauses(clauses) = {
    let params = clauses.at(1)
    let clauses = clauses.at(0)
    
    clauses = clauses.map(clause => {
      if clause.len() == 0 { return false }
      clause = dedup(clause.sorted())
      if clause.find(x => (-x) in clause) != none { 
        return true 
      }
      clause
    })
    
    if false in clauses { return ((), ) }
    (clauses.filter(x => x != true), params)
  }

  let clauses_to_cnf(clauses) = {
    let params = clauses.at(1)
    let clauses = clauses.at(0)

    let f = and_(..clauses.map(clause => or_(
      ..clause.map(x => if x > 0 {
        params.at(x - 1)
      } else {
        not_(params.at(-1 - x))
      })
    )))
    
    f.cnf = true
    f.normalized = true
    f
  }

  let optimized_cnf(f) = {
    if "optimized_cnf" in f { return f }
    if "cnf" not in f { f = cnf(f) }
    f = clauses_to_cnf(optimize_clauses(cnf_to_clauses(f)))
    f.optimized_cnf = true
    f
  }

  let dnf(f) = {
    smart_negate(optimized_cnf(not_(f)))
  }
  
  let dpll(clauses, var_count) = {
    let random = (
      true, true, true, true, false, true, false, true,
      true, true, false, false, true, true, true, true,
      false, false, false, true, true, false, true, true,
      false, false, true, true, true, true, true, true,
      true, false, true, false, true, false, true, false,
      false, false, true, true, true, false, false, true,
      false, true, true, false, false, false, false, false,
      false, true, false, true, false, true, true, true
    )

    let random_state = 0
    
    let stack = ((clauses, (none, ) * (var_count + 1)), )

    for _i in range(1000) {
      if stack.len() == 0 { break }
      for _j in range(1000) {
        if stack.len() == 0 { break }
        for _k in range(1000) {
          if stack.len() == 0 { break }
          let top = stack.pop()
          let clauses = top.first()
          let vars = top.last()
    
          let polarity = ((false, false), ) * (var_count + 1)
          let unit_clauses = (none, ) * (var_count + 1)
    
          for clause in clauses {
            if clause.len() == 1 {
              let x = clause.first()
              unit_clauses.at(calc.abs(x)) = x > 0
            }
            for x in clause {
              let var = calc.abs(x)
              polarity.at(var).at(int(x > 0)) = true
            }
          }
    
          for (i, signs) in polarity.enumerate() {
            if signs == (true, false) {
              vars.at(i) = false
            } else if signs == (false, true) {
              vars.at(i) = true
            } else if unit_clauses.at(i) != none {
              vars.at(i) = unit_clauses.at(i)
            }
          }
    
          let keep_clause = (true, ) * clauses.len()
    
          for (i, clause) in clauses.enumerate() {
            let keep_var = (true, ) * clause.len()
            for (j, x) in clause.enumerate() {
              let var = calc.abs(x)
              if vars.at(var) == none { continue }
              if vars.at(var) and x < 0 or not vars.at(var) and x > 0 {
                keep_var.at(j) = false
              } else {
                keep_clause.at(i) = false
                break
              }
            }
            if keep_clause.at(i) {
              clauses.at(i) = filter_by(clause, keep_var)
            }
          }
    
          clauses = filter_by(clauses, keep_clause)
          
          if clauses == () {
            return vars.map(x => if x == none {false} else {x}).slice(1)
          } else if () in clauses {
            continue
          }
    
          let jeroslow_wang = (0.0, ) * (var_count + 1)
          for clause in clauses {
            let j = calc.pow(0.5, clause.len())
            for x in clause {
              if x > 0 {
                jeroslow_wang.at(x) += j
              }
            }
          }
    
          let var = argmax(jeroslow_wang)
          let value = random.at(random_state)
          vars.at(var) = value
          stack.push((clauses, vars))
          vars.at(var) = not value
          stack.push((clauses, vars))
    
          random_state = calc.mod(random_state + 1, 64)
        }
      }
    }

    return none
  }

  let sat(..args) = {
    let f = if args.pos().len() == 1 {
      args.pos().first()
    } else {
      and_(..args.pos())
    }
    
    if is_var(f) {(
      solution: dict_of_one(str(f), true),
      next: () => none,
    )}

    if is_const(f) { (:).at("Tried to sat-solve a constant") }

    if "optimized_cnf" in f {
      f = cnf_to_clauses(f)
    } else if "cnf" in f {
      f = optimize_clauses(cnf_to_clauses(f))
    } else {
      f = optimize_clauses(cnf_to_clauses(cnf(f)))
    }

    let params = f.at(1)
    let clauses = f.at(0)

    let next(clauses) = {
      let solution = dpll(clauses, params.len())
      if solution == none {
        return none
      } else {
        return (
          solution: zip_into_dict(params, solution),
          next: () => {
            let new_clause = range(solution.len()).map(x => {
              if solution.at(x) { 
                -x - 1 
              } else {
                x + 1
              }
            })
            let new_clauses = clauses
            new_clauses.push(new_clause)
            next(new_clauses)
          }
        )
      }
    }

    next(clauses)
  }

  let sat_all(..args) = {
    let current = sat(..args)
    if current == none { return () }
    
    let solutions = (current.solution, )
    while true {
      let next = current.at("next")()
      if next == none { return solutions }
      solutions.push(next.solution)
      current = next
    }
  }

  let follows(..args, counterexample: false) = {
    let conditions = args.pos().slice(0, args.pos().len() - 1)
    let conclution = args.pos().last()

    let res = sat(extras_not_imply(and_(..conditions), conclution))

    if counterexample {
      if res == none {
        none
      } else {
        res.solution
      }
    } else {
      res == none
    }
  }

  let always_true(..args, counterexample: false) = {
    let res = sat(extras_nor(..args))
    
    if counterexample {
      if res == none {
        none
      } else {
        res.solution
      }
    } else {
      res == none
    }
  }

  (
    not_: not_,
    and_: and_,
    or_: or_,

    extras_xor: extras_xor,
    extras_imply: extras_imply,
    extras_if: extras_if,
    extras_not_imply: extras_not_imply,
    extras_not_if: extras_not_if,
    extras_eq: extras_eq,
    extras_nand: extras_nand,
    extras_nor: extras_nor,
    extras_lhs_id: extras_lhs_id,
    extras_rhs_id: extras_rhs_id,
    extras_exactly_one_of: extras_exactly_one_of,
    extras_at_most_one_of: extras_at_most_one_of,

    get_parameters: get_parameters,
    truth_table: truth_table,
    to_math: to_math,
    normalize: normalize,
    subs: subs,
    cnf: cnf,
    optimized_cnf: optimized_cnf,
    dnf: dnf,
    sat: sat,
    sat_all: sat_all,
    follows: follows,
    always_true: always_true,
  )
}

#let not_ = ___module_exports.not_
#let and_ = ___module_exports.and_
#let or_ = ___module_exports.or_

#let extras_xor = ___module_exports.extras_xor
#let extras_imply = ___module_exports.extras_imply
#let extras_if = ___module_exports.extras_if
#let extras_not_imply = ___module_exports.extras_not_imply
#let extras_not_if = ___module_exports.extras_not_if
#let extras_eq = ___module_exports.extras_eq
#let extras_nand = ___module_exports.extras_nand
#let extras_nor = ___module_exports.extras_nor
#let extras_lhs_id = ___module_exports.extras_lhs_id
#let extras_rhs_id = ___module_exports.extras_rhs_id
#let extras_exactly_one_of = ___module_exports.extras_exactly_one_of
#let extras_at_most_one_of = ___module_exports.extras_at_most_one_of

#let get_parameters = ___module_exports.get_parameters
#let truth_table = ___module_exports.truth_table
#let to_math = ___module_exports.to_math
#let normalize = ___module_exports.normalize
#let subs = ___module_exports.subs
#let to_math = ___module_exports.to_math
#let cnf = ___module_exports.cnf
#let optimized_cnf = ___module_exports.optimized_cnf
#let dnf = ___module_exports.dnf
#let sat = ___module_exports.sat
#let sat_all = ___module_exports.sat_all
#let follows = ___module_exports.follows
#let always_true = ___module_exports.always_true

#{
  let a = "a"
  let b = "b"
  let c = "c"
  let d = "d"
  let e = "e"
  let f = extras_nor(
    or_(
      extras_nor(extras_xor(a, b), not_(b)), 
      not_(and_(b, not_(c), d))
    ),
    or_(false, a)
  )

  grid(
    columns: 2,
    row-gutter: 2em,
    column-gutter: 3em,
    `get_parameters`, [#get_parameters(f).keys()],
    `truth_table`, [#truth_table(f).map(x => [#x]).join([ \ ]) \ ],
    `initial`, $ #to_math(f) $,
    `normalized`, $ #to_math(normalize(f)) $,
    `substituted`, $ #to_math(subs(f, b: c, a: and_(e, a))) $,
    `norm subs`, $ #to_math(normalize(subs(f, b: "c", a: and_(e, a)))) $,
    `cnf`, $ #to_math(cnf(f)) $,
    `optmized cnf`, $ #to_math(optimized_cnf(f)) $,
    `dnf`, $ #to_math(dnf(f)) $,
    `sat1`, [#sat(f)],
    `sat2`, [#repr(sat(f).at("next")())],
    `sat all`, [#sat_all(f)],
    `therefore b and d`, [#follows(f, and_(b, d))],
    `therefore a and c`, [#follows(f, and_(a, c))],
    `therefore a and c ce`, [#follows(f, and_(a, c), counterexample: true)]
  )

  assert(truth_table(f) == truth_table(normalize(f)))

  let f = or_(
    and_(or_("a", "b"), or_("c", "d")), 
    and_(or_("e", "f"), or_("g", "h"))
  )
  
  $ #to_math(f) $
  $ #to_math(cnf(f)) $
  
  $ #to_math(optimized_cnf(f)) $
  $ #to_math(dnf(f)) $

  [#sat(f) \ ]

  let f = and_(
    or_(a, not_(e), d),
    or_(not_(a), e, c, d),
    or_(not_(c), not_(d))
  )

  $ #to_math(optimized_cnf(f)) $

  [#sat(f) \ ]
  [#(sat(f).at("next")()) \ ]
  [#(sat(f).at("next")().at("next")()) \ ]
  [#(sat(f).at("next")().at("next")().at("next")()) \ ]
  [#sat_all(f) \ ]

  [#follows(or_(a, b), a) \ ]
  [#follows(or_(a, b), a, counterexample: true) \ ]
  [#follows(and_(a, b), a) \ ]
  [#follows(extras_xor(a, b), or_(a, b, c)) \ ]

  [#always_true(extras_xor(a, b), extras_eq(a, b)) \ ]
  [#always_true(extras_xor(a, b), and_(a, b)) \ ]
  [#always_true(extras_xor(a, b), and_(a, b), counterexample: true) \ ]
}
