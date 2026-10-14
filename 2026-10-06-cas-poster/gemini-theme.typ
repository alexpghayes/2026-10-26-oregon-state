
// https://colorhunt.co/palette/84994fffe797fcb53ba72703

#let gemini-scheme = (
  highlight2: rgb("84994F"),
  lo: rgb("FFE797"),
  highlight: rgb("FCB53B"),
  hi: rgb("A72703"),
)

// #let gemini-scheme = (
//   hi: rgb("#A31F34"),
//   lo: rgb("#d8d8d8"),
//   highlight: blue,
// )

#let gemini(
  title: [title],
  author: [author],
  institute: none,
  footer: none,
  logo-left: none,
  logo-right: none,
  body,
) = {
  let s = gemini-scheme

  // margins inside the page; the header / footer are sized separately
  let h-margin = 1.5cm
  let v-margin = 1cm

  set page(
    // paper: "a0",
    width: 24in,
    height: 36in,
    flipped: true,
    margin: (top: v-margin + 11em, bottom: v-margin, x: h-margin),
    header-ascent: v-margin,
    footer-descent: v-margin,
    header: {
      set text(fill: white)
      set align(center + horizon)
      show std.title: set text(size: 1.4em)

      // the small outset is to draw beyond the frame; this avoids rendering issues with white hairlines at the edges.
      block(fill: s.hi, width: 100% + 2 * h-margin, outset: .2mm, height: 100%, [
        #grid(
          columns: (15%, 70%, 15%),

          if logo-left != none {
            if type(logo-left) == content {
              logo-left
            } else {
              image(logo-left, height: 7cm)
            }
          },

          [
            #v(1.3em)
            #stack(
              spacing: .8em,
              std.title(title),
              author.join(sym.space.quad),
              text(size: .9em, institute.join(sym.space.quad)),
            )
          ],

          if logo-right != none {
            if type(logo-right) == content {
              logo-right
            } else {
              image(logo-right, height: 7cm)
            }
          },
        )
      ])
    },
    footer: if footer != none {
      set text(fill: white)
      set align(center + horizon)

      block(
        fill: s.lo,
        width: 100% + 2 * h-margin,
        outset: .2mm,
        height: 5cm,
        inset: (x: h-margin),
        footer,
      )
    },
  )


  set text(size: 24pt, font: "Lato", weight: "light")
  set par(justify: true, leading: .55em)
  set strong(delta: 150)

  show math.equation: set text(font: "Fira Math")

  show heading.where(depth: 1): it => {
    set text(fill: s.hi, size: 0.93em)
    set align(center)
    set block(stroke: (bottom: black), width: 100%, inset: (bottom: .4em))
    it
  }

  // color figure numberings
  show figure.caption: it => {
    (
      text(fill: s.hi, [#it.supplement ] + numbering(it.numbering, ..it.counter.at(it.location())))
        + it.separator
        + it.body
    )
  }

  import "@preview/itemize:0.2.0" as el

  show: el.default-enum-list.with(
    fill: s.hi,
    body-format: (style: (size: (1em, .9em))),
  )

  set enum(spacing: 1em)
  set list(spacing: 1em)

  // show body (in multi-col)
  columns(3, gutter: 4em, body)
}

// the base for our different highlights
#let _basic-block(fill: none, body) = {
  show heading.where(level: 1): set block(outset: (x: 10pt)) // correct the headings line

  set text(size: 1.4em, font: "Lato", weight: "light")
  v(2em)
  block(stroke: 4pt, outset: 50pt, radius: 10pt, body)
  v(2em)
}


// the base for our different highlights
#let _basic-block(fill: none, body) = {
  show heading.where(level: 1): set block(outset: (x: 10pt)) // correct the headings line

  set text(size: 1.2em, font: "Lato", weight: "light")
  v(1.5em)
  block(stroke: 3pt, outset: 30pt, radius: 10pt, body)
  v(1em)
}

#let alert = _basic-block.with(fill: gemini-scheme.hi.transparentize(90%))

#let _basic-block2(fill: none, body) = {
  v(1em)
  block(fill: fill, inset: 10pt, outset: 15pt, body)
}

#let highlight = _basic-block2.with(fill: gemini-scheme.hi.transparentize(90%))

