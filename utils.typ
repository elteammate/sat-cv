#let map2(args, f) = {
    let res = ()
    for (i, arg) in args.enumerate() {
        res.push(f(i, arg))
    }
    res
}

#let remap_range(from_l, from_r, to_l, to_r, t) = {
    to_l + (to_r - to_l) * (t - from_l) / (from_r - from_l)
}

#let icon(name) = box(
    move(dy: 0.2em)[
        #image(
            "icon-" + name + ".svg", 
            width: 1em,
            height: 1em,
        )
    ]
)
