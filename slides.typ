#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4": canvas, draw
#import "theme.typ": *
#import "support-code.typ": *

#show: setup

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

#let R = $bb(R)$
#let E = $bb(E)$
#let diid = $limits(tilde)^"iid"$
#let hl(body) = text(fill: red, body)
#let under(body) = underline(offset: 0.15em, body)

// Annotation under/over an underbrace: small, centered, multi-line
#let lbl(..lines) = text(size: 0.7em, lines.pos().join(linebreak()))

// Small text pinned to the bottom of the slide (stands in for \footnote)
#let note(body) = place(bottom + left, text(size: 0.55em, body))

#let takeaway(title, body) = block(
  width: 100%,
  fill: dark-teal,
  inset: 0.8em,
  radius: 0.2em,
  text(fill: white)[*#title* \ #body],
)

// Theorem / definition / assumption style boxes
#let thmbox(kind, name: none, body) = block(
  width: 100%,
  fill: brighter.lighten(70%),
  stroke: (left: 0.25em + bright),
  inset: 0.8em,
  radius: (right: 0.2em),
)[
  *#kind#if name != none [ (#name)]*. #body
]

// Show only the part of a PDF page that remains after trimming
// `trim: (left, bottom, right, top)` (same order as LaTeX's trim=).
#let pdf-crop(path, page: 1, trim: (0cm, 0cm, 0cm, 0cm), width: auto, height: auto) = layout(size => context {
  let (l, b, r, t) = trim
  let s = measure(image(path, page: page))
  let cw = s.width - l - r
  let ch = s.height - t - b
  let k = if width != auto {
    (if type(width) == ratio { size.width * width } else { width }) / cw
  } else if height != auto {
    height / ch
  } else { 1 }
  box(width: cw * k, height: ch * k, clip: true, place(top + left, dx: -l * k, dy: -t * k, image(
    path,
    page: page,
    width: s.width * k,
  )))
})

#let bacteria = box(image("figures/bacteria.png", height: 1em), baseline: 0.2em)

// Small network drawings.
// nodes: (x, y, fill, label, label-offset); edges: pairs of node indices;
// loops: node indices that get a self-loop (loop-dir: +1 above, -1 below)
#let net(nodes, edges, loops: (), loop-dir: (:), length: 1cm, r: 0.14) = canvas(length: length, {
  import draw: *
  for (a, b) in edges {
    line((nodes.at(a).at(0), nodes.at(a).at(1)), (nodes.at(b).at(0), nodes.at(b).at(1)), stroke: 0.08em + dark-teal)
  }
  for i in loops {
    let d = loop-dir.at(str(i), default: 1)
    circle((nodes.at(i).at(0), nodes.at(i).at(1) + d * 0.3), radius: 0.2, stroke: 0.08em + dark-teal)
  }
  for n in nodes {
    let (x, y, fill, label, off) = n
    circle((x, y), radius: r, fill: fill, stroke: none)
    if label != none { content((x + off.at(0), y + off.at(1)), label) }
  }
})

// Labelled design matrix: header row of column names above the matrix
#let design(cols, rows, delim: "[") = {
  let n = cols.len()
  math.mat(delim: delim, augment: (hline: 1, stroke: 0.05em + muted), cols, ..rows)
}

// 22.5 minutes?
#slide[
  #set page(
    header: none,
    footer: none,
    margin: 3em,
  )

  #text(size: 1.3em)[
    Estimating peer effects in noisy, low-rank networks via network smoothing
  ]

  #divider

  #set text(size: .8em, weight: "light")
  Alex Hayes

  October 26, 2026  \
  Oregon State University
]


#slide[
  = This is joint work with my advisor

  #toolbox.side-by-side(gutter: 3mm)[
    #align(center)[
      #image("figures/keith.jpg", height: 50%)

      Keith Levin \
      #text(size: 0.8em)[University of Wisconsin-Madison]
    ]
  ]
]


#slide[
  = Roadmap for today

  + What are peer effect?

  + How do we typically estimate peer effects?

  + Estimating peer effects from noisy data

  + Other current projects + pitch to students and collaborators

]


// ---------------------------------------------------------------------------
// Recent work on network regression
// ---------------------------------------------------------------------------

#new-section[What are peer effects and how do we estimate them?]

#slide[
  = Peer effects are measures of social influence

  #toolbox.side-by-side(columns: (0.35fr, 0.65fr), gutter: 1em)[
    #align(center, net(
      (
        (0, 1, red, none, (0, 0)),
        (1, -1, muted, bacteria, (-0.4, -0.3)),
        (1.5, 2.5, red, none, (0, 0)),
        (2.75, 0.5, red, none, (0, 0)),
        (4.3, 2.4, muted, bacteria, (0.4, 0.3)),
        (3.4, -1.4, red, bacteria, (0, -0.5)),
        (4.7, 0.1, muted, bacteria, (0.5, 0)),
      ),
      ((0, 1), (0, 2), (1, 2), (1, 3), (3, 5), (2, 3), (3, 4), (1, 5), (5, 6), (6, 4), (4, 2)),
      length: 0.8cm,
    ))
  ][
    #set par(spacing: 1.2em)
    #only("1-")[*Direct effect*: if I get #hl[vaccinated], I am less likely to get sick #bacteria]

    #only("1-")[*Contagion*: if my friends get sick #bacteria, I am more likely to get sick #bacteria]

    #only("1-")[*Interference*: if my friends get #hl[vaccinated], I am less likely to get sick #bacteria]

    #uncover("2-")[
      #text(size: 0.6em)[\* Can be defined counterfactually (#cite(<vazquez-bare2023>, form: "prose")), but we do not consider counterfactual inference in this talk.]
    ]
  ]
]


#slide[
  = Linear-in-means models estimate social influence

  #text(size: 0.65em)[
  #let cell(n, body) = uncover(str(n) + "-", body)
  #grid(
    columns: (auto, auto, auto, auto, 3em, auto, auto, auto),
    column-gutter: 0.5em,
    row-gutter: 0.7em,
    align: left,
    cell(1)[Outcome], cell(1)[(sick?)], cell(1)[$Y_i$], cell(1)[$in {0, 1}$], [],
    cell(1)[Base rate], cell(1)[$alpha$], cell(1)[$in R$],

    cell(2)[Node degree], cell(2)[(num friends)], cell(2)[$d_i$], cell(2)[$in {0, 1, 2, dots}$], [],
    cell(2)[Contagion], cell(2)[$beta$], cell(2)[$in (-1, 1)$],

    cell(2)[Edge $i tilde j$], cell(2)[(friends?)], cell(2)[$A_(i j)$], cell(2)[$in {0, 1}$], [],
    cell(3)[Direct effect], cell(3)[$gamma$], cell(3)[$in R$],

    cell(3)[Treatment], cell(3)[(vaccinated?)], cell(3)[$T_i$], cell(3)[$in {0, 1}$], [],
    cell(4)[Interference], cell(4)[$delta$], cell(4)[$in R$],
  )

  #v(0.3em)
  #set text(size: 1.5em)
  #align(center)[
    #let term(s, body) = uncover(str(s) + "-", math.equation(block: false, math.display(body)))
    #term(1, $underbrace(Y_i, #lbl[sick?]) = alpha$)
    #term(2, $+ beta underbrace(1 / d_i sum_(j : A_(i j) = 1) Y_j, #lbl[fraction sick friends])$)
    #term(3, $+ gamma underbrace(T_i, #lbl[vaccinated?])$)
    #term(4, $+ delta underbrace(1 / d_i sum_(j : A_(i j) = 1) T_j, #lbl[fraction vaccinated friends])$)
    #term(5, $+ underbrace(epsilon.alt_i, #lbl[error])$)
  ]

  #uncover("6-")[
    #set text(size: 0.5em)
    Letting $G = D^(-1) A$ be the row-normalized adjacency matrix, we can write this in matrix-vector form:
    #align(center, text(size: 2em, $Y = alpha bold(1)_n + beta G Y + T gamma + G T delta + epsilon.alt$))
  ]
  ]
]

#slide[
  = The canonical two-stage least stages linear-in-means estimator
  $
    beta^* = (Z^top M Z)^(-1) Z^top M Y
  $
  where
  $
    Z = [1 space W space G W space G Y] quad quad quad quad G = D^(-1) A
  $
  is the covariate matrix and
  $
    M = H (H^top H)^(-1) H^top
  $
  is the projection onto the span of the instrument matrix
  $
    H = [W space G W space G^2 W space G^3 W].
  $
]

#new-section([The problem])


#slide[
  = This talk is about the #under[linear-in-means] model

  #hl[Very popular] tool for estimating social influence

  Used in education, crime, health, social policy, etc.

  I discovered an issue with this model

  #note[E.g., @sacerdote2001, @epple2011, @soetevent2007, @trogdon2008, @duflo2003, @bertrand2000, @glaeser1996, @patacchini2012a, @carrell2013, etc.]
]


#slide[
  = Peer effects in networks with missing and noisy edges

  #align(center, image("figures/missing-edges.pdf", height: 100%))
]

#slide[
  = A new estimator for the linear-in-means model

  *Setting*: Treatment random and independent of network. $T_i diid "Bern"(0.5)$

  #align(center, text(size: 1.4em, $Y = alpha bold(1)_n + beta G Y + T gamma + G T delta + epsilon.alt$))

  We started to run a simulation study to confirm that our estimator worked...

  #note[Generate $Y$ via the reduced-form specification $Y = (I - beta G)^(-1) (alpha bold(1)_n + gamma T + delta G T + epsilon.alt)$.]
]


#slide[
  = Base rates and interference are collinear in large samples

  #align(center)[
    #let rd(x) = hl(x)
    #set text(size: 0.85em)
    $
      vec(Y_1, Y_2, dots.v, Y_n) =
      underbrace(
        mat(
          delim: "[",
          bold(1)_n, G Y, T, G T;
          rd(1), G Y_1, 1, rd(1 \/ 2);
          rd(1), G Y_2, 0, rd(1 \/ 2);
          dots.v, dots.v, dots.v, dots.v;
          rd(1), G Y_n, 1, rd(1 \/ 2)
        ),
        #lbl[as $n -> oo$]
      )
      vec(rd(alpha), beta, gamma, rd(delta)) + vec(epsilon.alt_1, epsilon.alt_2, dots.v, epsilon.alt_n)
    $

    #under[Sometimes can't distinguish between base rate #hl($alpha$) and interference #hl($delta$)]
  ]
]

#slide[
  = In simulations, we couldn't estimate #hl($beta$) either

  #align(center, image("figures/simulations/jobtalk-mse.pdf", width: 85%))
]

#slide[
  = Causal folks study treatments that depend on network position

  #align(center, pdf-crop("papers/shalizi.pdf", page: 2, trim: (1.5cm, 16cm, 0cm, 3.3cm), width: 80%))
]

#slide[
  = Dependence between treatment and network might help

  #align(center)[
    #set text(size: 1.4em)
    $
      underbrace([G T]_i, #lbl[fraction vaccinated friends])
      = underbrace(1 / d_i sum_(j : A_(i j) = 1) T_j, #lbl[average of dependent treatments])
    $

    #v(1em)
    $G T$ might not converge, or might converge to a non-constant value
  ]
]

#slide[
  = Stochastic blockmodels induce dependence

  #toolbox.side-by-side(columns: (0.45fr, 0.55fr), gutter: 1em)[
    #image("figures/assortative.png", width: 100%)
  ][
    Stochastic blockmodels are an intuitive way to induce dependence

    #v(0.5em)
    Block indicators $Z_i$ \
    Popularity parameters $theta_i$ \
    Mixing matrix $B in [0, 1]^(d times d)$

    $ P(A_(i j) = 1 | Z, theta) = theta_i Z_i B Z_j^top theta_j $
  ]
]

#slide[
  = More takeaways

  #takeaway("Takeaway 3")[Explicitly modelling dependence between nodal covariates and network structure can aid identifiability and resolve asymptotic collinearity issues.]

  #v(0.5em)
  #takeaway("Takeaway 4")[Treatments dependent on network must be considered on a case-by-case basis, considering both the treatment and the network model.]
]

#slide[
  = Peer effects in networks with missing and noisy edges

  #set figure(supplement: none)
  #set figure.caption(position: bottom)
  #toolbox.side-by-side(columns: (1fr, 1fr, 1fr), gutter: 1em)[
    #figure(image("figures/matrices/A.png", width: 100%), caption: $A$, numbering: none)
  ][
    #figure(image("figures/matrices/P.png", width: 100%), caption: $E[A | X] = X X^top$, numbering: none)
  ][
    #figure(image("figures/matrices/Phat.png", width: 100%), caption: $hat(X) hat(X)^top$, numbering: none)
  ]
]

#slide[
  = Causal inference for co-evolution models

  #align(center, image("figures/time-varying.png", height: 100%))
]


#new-section[Estimating peer effects from noisy data]

// Notation from the CAS poster: orange = peer contagion, red = latent contagion
#let pc(body) = text(bright, body)
#let lc(body) = text(red, body)
#let betanaught = pc($beta_0$)
#let betaw = pc($beta_"w"$)
#let betax = pc($beta_"x"$)
#let betay = pc($beta_"y"$)
#let bbeta = pc($beta$)
#let thetanaught = lc($theta_0$)
#let thetaw = lc($theta_"w"$)
#let thetax = lc($theta_"x"$)
#let thetay = lc($theta_"y"$)
#let btheta = lc($theta$)
#let thetahattsls = lc($hat(theta)_"TSLS"$)

#slide[
  = Humans constantly influence their social contacts

  #align(center, image("figures/friendship-diagram.jpeg", height: 85%))
]

#slide[
  = ...but measuring someone's friends is challenging

  If I ask you who your friends are:

  - answers vary depending on how exactly I ask you,
  - you'll probably forget day-to-day social contacts, and
  - you might think someone is your friend, but they might disagree.
]

#slide[
  = We use estimated *likelihood of friendship* instead

  #text(size: 0.6em)[
    $
      Y_i & = betanaught + W_i betaw + X_i betax + underbrace(betay sum_(j != i) pc(A_(i j) / d_i) Y_j, "peer contagion") + epsilon.alt_i & "requires all" A_(i j) \
      Y_i & = thetanaught + underbrace(W_i thetaw, "observed covariate effects") + underbrace(X_i thetax, "latent positional effect") + underbrace(thetay sum_(j != i) lc((X_i^top X_j) / (bb(E)[d_i | X])) Y_j, "latent contagion") + epsilon.alt_i quad & "requires" bb(P)(A_(i j) = 1)
    $
  ]
]

#slide[
  = ...based on a low-rank network model

  #toolbox.side-by-side(gutter: 1em)[
    #image("figures/blockmodel-poster.png", height: 60%)
  ][
    *Intuition*: stochastic blockmodels

    Block indicators $Z_i$ \
    Popularity parameters $gamma_i$ \
    Mixing matrix $B in [0, 1]^(d times d)$

    $ bb(P)(A_(i j) = 1 | Z, gamma, B) = underbrace(gamma_i Z_i B Z_j^top gamma_j, "rank" d) $
  ]

  #text(size: 0.7em)[Only assume undirected $A in R^(n times n)$ with low rank $P = E[A | X] = X X^top$ and sub-gamma (Bernoulli, Poisson, Gaussian, Gamma, ...) deviations around $A$.]
]

#slide[
  = Estimating contagion with noisy data

  + Humans constantly *influence each other*. We want to *estimate how strong social influence* is.
  + However, *measuring friendships is challenging*.
  + To estimate social influence, we *need to know who is friends with whom*.
  + We propose *a method that works with noisy friendship measurements*.
]

#slide[
  = ...to estimate how much people influence each other

  #text(size: 0.65em)[
    Let $A approx hat(U) hat(S) hat(U)^top$ be the rank $d$ SVD of $A$. Put $hat(X) = hat(U) hat(S)^(1\/2)$ and $hat(P) = hat(X) hat(X)^top$ and $hat(d)_i = sum_j hat(P)_(i j)$ and $hat(D) = "diag"(hat(d)_1, ..., hat(d)_n)$ and $hat(G) = hat(D)^(-1) hat(P) in R^(n times n).$ Let $hat(Z) = [W space hat(X) space hat(G) y]$ and $hat(H) = [W space hat(X) space hat(G) W space hat(G) hat(X) space hat(G)^2 W space hat(G)^2 hat(X)]$. Let $hat(M) = hat(H) (hat(H)^top hat(H))^(-1) hat(H)^top$. Then
    $ thetahattsls = (hat(Z)^top hat(M) hat(Z))^(-1) hat(Z)^top hat(M) y $

    *Theorem:* $thetahattsls$ is asymptotically normal under the #lc[latent contagion] model
    $ sqrt(n) (thetahattsls - btheta) -> cal(N)(0, Sigma) $
  ]
]

#slide[
  = This can be as good as knowing exact friendship!

  *Theorem:* $thetahattsls$ is asymptotically normal under the #pc[peer contagion] model
  $ sqrt(n) (thetahattsls - bbeta) -> cal(N)(0, Sigma) $

  #align(center)[How generally can we apply the strategy of replacing $A$ with $bb(P)(A)$?]
]

#slide[
  = More about Alex Hayes

  - I'm an Assistant Professor in Statistics & Data Science
  - I develop statistical methods for social networks and causal inference
  - I write lots of `R` code and worked on some of the `tidyverse` packages
  - I'm actively looking for collaborators!
]

#slide[
  = Our estimators can handle noisy measurements

  #align(center, image("figures/all_matrices.png", height: 70%))

  ...because latent structure is estimable at fast rates even in noisy networks
]

#slide[
  = Anxiety before final exams amongst MBA students

  #text(size: 0.65em)[
    Data on 241 MBA students from "Do Your Friends Stress You out? A Field Study of the Spread of Stress..." by Shihan et al (2023)

    #align(center)[
      $
        "anxiety" & ~ "personality + demographics + X +" lc("latent peer anxiety") \
        "anxiety" & ~ "personality + demographics + X +" pc("peer anxiety")
      $
    ]

    $X$ accounts for localized/group effects. Dimension of $X$ is unknown!

    #align(center, image("figures/anxiety/estimates.pdf", height: 45%))

    #align(center)[*Model specification dramatically impacts inference*]
  ]
]

#new-section[My background and research]

#slide[
  = My research interests and professional experience

  #toolbox.side-by-side(gutter: 1em)[
    *Research interests:*
    - (Social) networks
    - Causal inference
    - Peer effects
    - Social processes in science
    - Software design
  ][
    *Professional background:*
    - PhD Statistics, UW-Madison
    - Facebook Core Data Science (Intern)
    - RStudio (Intern)
    - B.A. Statistics, Rice University
  ]
]

#slide[

  = Thank you! Questions? Comments?

  #toolbox.side-by-side(gutter: 5mm, columns: (1.3fr, 1fr))[

    Network data is expensive, ARD is cheap

    Two stage spectral estimation is convenient and enables full uncertainty quantification in downstream analysis

    Good traits are strongly homophilous

    #v(1em)
    #set list(marker: none)

    #align(left)[

      #set text(size: 0.8em)

      #list(
        [#box(image("figures/icons/bluesky.svg", height: 1em, fit: "contain"), baseline: 5pt) #h(0.5em) #link(
            "https://bsky.app/profile/alexpghayes.com",
          )[\@alexpghayes.com]],
        [#box(image("figures/icons/envelope.svg", height: 1em, fit: "contain"), baseline: 5pt) #h(0.5em) #link(
            "mailto:alexpgh@stanford.edu",
          )[alexpgh\@stanford.edu]],
        [#box(image("figures/icons/wordpress.svg", height: 1em, fit: "contain"), baseline: 5pt) #h(0.5em) #link(
            "https://www.alexpghayes.com",
          )[alexpghayes.com]],
        [#box(image("figures/icons/github.svg", height: 1em, fit: "contain"), baseline: 5pt) #h(0.5em) #link(
            "https://github.com/alexpghayes",
          )[github.com/alexpghayes]],
      )
    ]
  ][
    #image("figures/sin-theta-last-slide.png")
  ]

  // #align(center)[
  //   #text(muted, size: 0.8em)[These slides are available at github.com/alexpghayes/2025-11-14-madison-networks]
  // ]
]


#new-section[Appendix]

#slide[
  = Assumptions of the canonical two-stage least squares estimator

  + All diagonal elements of $G$ are zero

  + $(I - beta_(g y) G)^(-1)$ is non-singular with $lr(|beta_(g y)|) < 1$.

  + $G$ and $I - beta_(g y) G$ are uniformly bounded in row and column sums.

  + The regressor matrices $W$ have full column rank (for $n$ large enough), and the elements of $W$ are uniformly bounded in absolute value.

  + $epsilon$ are i.i.d. with zero mean and bounded variance $bb(E)[epsilon_i^2] = sigma_epsilon^2 < b < infinity$. Additionally $epsilon_i$ have finite fourth order moments.
]


#slide[
  = Assumptions of the canonical two-stage least squares estimator

  Further, the instruments $H$ have full column rank and are composed of a subset of linearly independent columns of $mat(W, G W, G^2 W)$ where the subset contains $W$ and $X$. Additionally
  $
    lim_(n -> oo) 1/n H^top H
  $
  is finite and non-singular and
  $
    1/n H^top Z
  $
  converges in probability to a matrix that is finite and has full column rank.
]

#slide[
  = Assumptions of the canonical two-stage least squares estimator

  If all the previous assumptions hold, then
  $
    sqrt(n) (beta^* - beta) -> cal(N)(0, sigma_epsilon^2 (Z^top M Z)^(-1))
  $
  recalling that
  $
    Z = [1 space W space G W space G Y] quad quad quad quad G = D^(-1) A
  $
  is the covariate matrix and
  $
    M = H (H^top H)^(-1) H^top
  $
  is the projection onto the instruments $H = [W space G W space G^2 W space G^3 W]$.
]

#slide[
  = Estimators

  - OLS: `lm(y ~ Gy + T + GT)`
  - TSLS: `ivreg(y ~ Gy + T + GT | T + GT + G2T)`, with instruments $T$, $G T$, $G^2 T$
]

#slide[
  = Random dot product graphs

  #text(size: 0.65em)[
  #thmbox("Definition", name: cite(<young2007>, form: "prose"))[
    Let $F$ be a distribution on $R^d$ such that $0 <= x^top y$ for all $x, y in "supp" F$ and the convex cone of $"supp" F$ is $d$-dimensional. Draw $X_1, X_2, dots, X_n diid F$, and collect these in the rows of $X in R^(n times d)$ for ease of notation. Conditional on these $n$ vectors, which we call _latent positions_, generate edges by drawing $\{A_(i j) : 1 <= i < j <= n\}$ as independent $(nu, b)$-subgamma random variables with $E[A_(i j) | X] = rho X_i^top X_j$, where $rho in [0, 1]$. Then we say that $A$ is distributed according to an $n$-vertex random dot product graph with latent position distribution $F$, $(nu, b)$-subgamma edges and sparsity factor $rho$. We write $(A, X) tilde "RDPG"(F, n)$.
  ]
  ]
]

#slide[
  #set text(size: 0.34em)
  #columns(2, bibliography(("ard-trait-selection.bib", "2025-02-19-jobtalk.bib"), style: "apa", title: none))
]
