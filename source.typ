#import "utils.typ": *
#import "chessboard.typ": *
#import "secrets.typ"

#set page(margin: (top: 2cm, bottom: 0pt, left: 2cm, right: 2cm))
#set text(region: "ru")
#show par: set block(spacing: 0.65em)

#let primary = rgb("#f28c26")
#let primary_opt = rgb("#FF8A23")
#let font = ""

#set text(font: font)
#set par(leading: 0.3em)

#let hl(content) = emph(text(weight: 900, primary, content))

#let old_link = link
#let link(..args) = underline(emph(old_link(..args)))

#let email(addr) = link("mailto:" + addr)[#addr]

#let self_url = "https://github.com/elteammate/sat-cv"
#let self_link(content) = link(self_url, content)

#let gh_link(href) = link(href)[#place(dy: -0.4em, icon("github")) #h(1em)]

#block(width: 100%)[
    #grid(columns: (2fr, 1fr))[
        #box(width: 100%, height: 2cm)[#grid(rows: (1fr, 1fr))[
            #text(
                2.5em,
                // weight: 800,
                font: font,
            )[
                Степанов Николай
            ]
        ][
            #block(inset: (left: 0.2cm, right: 0.6cm))[#par[#hl[
                Программист-энтузиаст, экспериментатор, который постоянно учится, ищет новые вызовы и импульсивно принимается проверять новые идеи. 
                #h(1fr) #box(place(dy: -0.3em, dx: -2em)[--- я.])
            ]]]
        ]]
    ][
        #rect(width: 100%, stroke: (left: primary + 2pt))[#align(right)[
            #v(-0.5cm)
            #stack(spacing: 2pt)[
                Санкт-Петербург, Россия #icon("location")
            ][
                #secrets.phone #icon("phone")
            ][
                #email(secrets.email) #icon("mail")
            ][
                #link("https://github.com/elteammate/")[github.com/elteammate]
                #icon("github")
            ][
                #link(secrets.telegram)[t.me/elteammate]
                #icon("telegram")
            ]
        ]]
    ]
]

#let sep = line(length: 100%, stroke: primary + 2pt)

#sep

#v(1cm)

#let fadeout(..elements) = {
    let elements = elements.pos()
    let color = black
    let n = elements.len()
    for (i, element) in elements.enumerate() {
        text(color, element)
        color = color.lighten(remap_range(0, n, 0%, 30%, i))
    }
}

#let bullet_points(..points) = {
    let n = points.pos().len()

    show heading: set text(primary, font: font, weight: 800, size: 1.5em)

    stack(..map2(points.pos(), (i, point) => {
        let lbl = label("point-" + str(i))

        let measure_radius(styles) = measure([= A], styles).height / 2

        stack[
            #box() #lbl
            #locate(current => style(styles => {
                let offset = 0.8cm
                let radius = measure_radius(styles)
                let inner_radius = 0.45em
                let stroke = radius - inner_radius

                let next = query(label("point-" + str(i + 1)), after: current).first()
                let dy = next.location().position().y - current.position().y
                place(dx: -offset)[

                    #place(
                        dx: -radius, dy: -radius, 
                        circle(radius: radius, fill: primary),
                    )

                    #place(
                        dx: -inner_radius, dy: -inner_radius,
                        circle(radius: inner_radius, fill: white),
                    )

                    #line(
                        start: (0pt, (radius + inner_radius) / 2),
                        end: (0pt, dy),
                        stroke: primary + stroke
                    )

                    #place(
                        dx: -stroke / 2, dy: -stroke / 2,
                        circle(radius: stroke / 2, fill: primary),
                    )
                ]
            }))
        ][
            #style(styles => {
                let radius = measure_radius(styles)
                v(radius)
                move(dy: -radius * 2, point)
                v(radius * 2)
            })
        ]
    }))
    
    [
        #box()#label("point-" + str(n))
    ]
}

#bullet_points[
    = Образование
    Первый курс СПбГУ, факультет математики и компьютерных наук, направление "Современное Программирование".
][
    #grid(columns: (1fr, chessboard_size))[
        = Портфолио
        Более сотни созданных проектов. #hl[Несколько законченных.]
        #block(width: 95%)[
            Например:
            - #gh_link("https://github.com/elteammate/checkers") Шашки на Avalonia, с искусственным интеллектом на основе эвристического алгоритма, улучшенного с помощью генетического алгоритма над нейронными сетями.
            - #gh_link("https://github.com/elteammate/typst-compiler") Компилятор подможества "языка программирования" #link("https://typst.app/")[Typst] в нативный код. Написан на самом Typst, кроме препроцессора на Python и LALR(1) парсер-генератора на Rust.
            - #gh_link("https://github.com/elteammate/rust2sharp-translator") Транслятор подмножества Rust в С\#.
            - Карточная игра на Unity, на подобии Inscryption #strike[(Unity не дружит с git)]
            - #gh_link("https://github.com/elteammate/heavy-puzzle") Многопользовательская кооперативная web-игра по сборке мозаики.
            - #gh_link("https://github.com/elteammate/2021-11-1/tree/main/15-N.Stepanov/03-huffman") Визуализация алгоритма сжатия Хаффмана.
            - #gh_link(self_url) #self_link[Это резюме] (особенно картинка справа).
        ]
    ][
        #stack(spacing: 0.3cm)[
            #square(size: chessboard_size, stroke: primary)[
                #solution
            ]
        ][
            #block(width: 100%, align(center)[
                #self_link[Задача о 8 ферзях]
            ])
        ]

    ]
][
    = Олимпиады
    - #link("https://inf2022.siriusolymp.ru/results")[Всероссийская олимпиада школьников по информатике, 2022]. #hl[Призер, 60-е место.]
    - #link("https://olympiads.ru/zaoch/2021-22/onsite/standing.shtml")[Открытая олимпиада школьников по информатике, 2022]. #hl[Призёр, 55-е место.]
    - ... и #link("https://t.me/elteammates_bubble/51")[множество] других.
][
    = Технологии

    Пишу идиоматичный код на Rust, Python, Kotlin, C++. Когда-либо писал на 
    #fadeout[Java, ][С\#, ][JavaScript, ][TypeScript, ][Go, ][Lua, ][Assembly, ][Clojure, ][PHP, ][APL, ][...]

    Знаком с несколькими web-фреймворками (React, Vue, Svelte, а также Flask, aiohttp), базами данных (SQLite, PostgreSQL, SurrealDB), и прочими несвязанными друг с другом технологиями: #fadeout[Git, ][Docker, ][Unity, ][Системы сборки (много), ][Blender, ][Avalonia, ][OpenGL, ][WGPU, ][Spigot, ][...]
][
    = Интересы
    Любое программирование: от дизайна языков программирования до соревнований по кибербезопасности, от современной веб-разработки до низкоуровневых оптимизаций, от плагинов на Minecraft до низкоуровневой компьютерной графики, от олимпиадных задач до #hl[SAT-решателя на том же языке программирования, на котором написано это резюме].
][
    = Языки
    - Русский, Native
    - English, \~B2+, Good enough technical. #hl[5 years (almost) without watching youtube in Russian.]
]

#sep
#align(right)[
    #text(black.lighten(80%))[
        \@elteammate, 2023, for R&D Toolchain Technology, Fast and light SAT solver
    ]
]
