// "Ported" Gemini theme
// https://github.com/anishathalye/gemini
// for: https://discord.com/channels/1054443721975922748/1088371919725793360/1433905080473747486 (Typst, #quick-questions)

#import "gemini-theme.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/lilaq:0.5.0" as lq

#let betanaught = text(gemini-scheme.highlight)[$beta_0$]
#let betaw = text(gemini-scheme.highlight)[$beta_"w"$]
#let betax = text(gemini-scheme.highlight)[$beta_"x"$]
#let betay = text(gemini-scheme.highlight)[$beta_"y"$]
#let bbeta = text(gemini-scheme.highlight)[$beta$]

#let thetanaught = text(gemini-scheme.hi)[$theta_0$]
#let thetaw = text(gemini-scheme.hi)[$theta_"w"$]
#let thetax = text(gemini-scheme.hi)[$theta_"x"$]
#let thetay = text(gemini-scheme.hi)[$theta_"y"$]
#let btheta = text(gemini-scheme.hi)[$theta$]

#let betahatols = text(gemini-scheme.highlight)[$hat(beta)_"OLS"$]
#let betahattsls = text(gemini-scheme.highlight)[$hat(beta)_"TSLS"$]

#let thetahatols = text(gemini-scheme.hi)[$hat(theta)_"OLS"$]
#let thetahattsls = text(gemini-scheme.hi)[$hat(theta)_"TSLS"$]

#let svg-with-fill(path, color: white) = {
  let svg = read(path)
  let svg = svg.replace("currentColor", color.to-hex())
  image(bytes(svg), format: "svg", height: 1em, fit: "contain")
}

#let socials = [
  #set list(marker: none)

  #align(left)[
    #list(
      [#box(svg-with-fill("./figures/icons/bluesky.svg"), baseline: 5pt) #h(0.5em) #link(
          "https://bsky.app/profile/alexpghayes.com",
        )[\@alexpghayes.com]],
      [#box(svg-with-fill("./figures/icons/envelope.svg"), baseline: 5pt) #h(0.5em) #link(
          "mailto:alex.hayes@oregonstate.edu",
        )[alex.hayes\@oregonstate.edu]],
      [#box(svg-with-fill("./figures/icons/wordpress.svg"), baseline: 5pt) #h(0.5em) #link(
          "https://www.alexpghayes.com",
        )[alexpghayes.com]],
      [#box(svg-with-fill("./figures/icons/github.svg"), baseline: 5pt) #h(0.5em) #link(
          "https://github.com/alexpghayes",
        )[github.com/alexpghayes]],
    )
  ]
]

#let logos = [
  #grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0em,
    image("figures/logos-osu/png/OSU_vertical_1C_W.png", height: 7cm)
    // image("figures/logos-uw-madison/uw-crest-color-web-digital.pdf", height: 5cm)
  )
]

#show: gemini.with(
  title: [Estimating how much people influence their friends when friendship measurements are unreliable],
  author: ([Alex Hayes¹], [Keith Levin²]),
  institute: ([¹Oregon State University], [²University of Wisconsin-Madison]),
  footer: none,
  logo-right: socials, //"figures/logos-uw-madison/color-flush-UWlogo-print.pdf",
  logo-left: logos, //"figures/logos-stanford/Block_S_2_color.png",
)



= Humans constantly influence their social contacts

#figure(
  image("./figures/diagram2.jpeg", height: 10cm),
)

= ...but measuring someone's friends is challenging.
#v(0.5em)

#grid(
  columns: (2em, 1fr),
  box(),
  [
    #h(-1em)If I ask you who your friends are:

    - answers vary depending on how exactly I ask you,
    - you'll probably forget day-to-day social contacts, and
    - you might think someone is your friend, but they might disagree.
  ],
)

= We use estimated *likelihood of friendship* instead
$
  Y_i & = betanaught + W_i betaw + X_i betax + underbrace(betay sum_(j != i) #text(gemini-scheme.highlight)[$(A_(i j)) / d_i$] Y_j, "peer contagion") + epsilon_i & "requires all" A_(i j) space #emoji.face.teeth\
  Y_i & = thetanaught + underbrace(W_i thetaw, "observed\ncovariate\n effects") + underbrace(X_i thetax, "latent\npositional\neffect") + underbrace(thetay sum_(i != j) #text(gemini-scheme.hi)[$(X_i^top X_j) / (EE[d_i mid(|) X])$] Y_j, "latent contagion") + epsilon_i quad quad & "requires" PP(A_(i j) = 1)
$


= ...based on a low-rank network model

#grid(
  columns: (50fr, 50fr),
  gutter: 1em,
  [
    #figure(
      image("./figures/blockmodel.png", width: 75%),
    )

  ],
  [
    #align(horizon)[
      #v(0.5em)
      *Intuition*: stochastic blockmodels
      #v(0.5em)
      Block indicators $Z_i$ \
      Popularity parameters $gamma_i$ \
      Mixing matrix $B in [0, 1]^(d times d)$

      $ PP(A_(i j) = 1 | Z, gamma, B) = underbrace(gamma_i Z_i B Z_j^top gamma_j, "rank" d) $
    ]
  ],
)

Only assume undirected $A in RR^(n times n)$ with low rank $P = EE(A mid(|) X) = X X^top$ and sub-gamma (Bernoulli, Poisson, Gaussian, Gamma, ...) deviations around $A$.

#colbreak()

#alert[
  = Estimating contagion with noisy data

  + Humans constantly *influence each other*. We want to *estimate how strong social influence* is.
  + However, *measuring friendships is challenging*.
  + To estimate social influence, we *need to know who is friends with whom*.
  + We propose *a method that works with noisy friendship measurements*.
]

= ...to estimate how much people influence each other

Let $A approx hat(U) hat(S) hat(U)^top$ be the rank $d$ SVD of $A$. Put $hat(X) = hat(U) hat(S)^(1\/2)$ and $hat(P) = hat(X) hat(X)^top$ and $hat(d)_i = sum_j hat(P)_(i j)$ and $hat(D) = "diag"(hat(d)_1, ..., hat(d)_n)$ and $hat(G) = hat(D)^(-1) hat(P) in RR^(n times n).$ Let $hat(Z) = [W space hat(X) space hat(G) y]$ and $hat(H) = [W space hat(X) space hat(G) W space hat(G) hat(X) space hat(G)^2 W space hat(G)^2 hat(X)]$. Let $hat(M) = hat(H) (hat(H)^top hat(H))^(-1) hat(H)^top$. Then
$
  thetahattsls = (hat(Z)^top hat(M) hat(Z))^(-1) hat(Z)^top hat(M) y
$

*Theorem:* $thetahattsls$ is asymptotically normal under the #text(gemini-scheme.hi)[latent contagion] model
$
  sqrt(n) space (thetahattsls - btheta) & -> cal(N)(0, Sigma)
$


= This can be as good as knowing exact friendship!

*Theorem:* $thetahattsls$ is asymptotically normal under the #text(gemini-scheme.highlight)[peer contagion] model
$
  sqrt(n) space (thetahattsls - bbeta) & -> cal(N)(0, Sigma)
$

#align(center)[How generally can we apply the strategy of replacing $A$ with $PP(A)$?]

#highlight[
  = More about Alex Hayes

  - I'm an Assistant Professor in Statistics & Data Science
  - I develop statistical methods for social networks and causal inference
  - I write lots of `R` code and worked on some of the `tidyverse` packages
  - I'm actively looking for collaborators!
  
]

= Our estimators can handle noisy measurements

#figure(
  image("/figures/all_matrices.png"),
)

...because latent structure is estimable at fast rates even in noisy networks

= Anxiety before final exams amongst MBA students

#v(0.5em)

Data on 241 MBA students from “Do Your Friends Stress You out? A Field Study of the Spread of Stress...” by Shihan et al (2023)

#align(center)[
  $
    #raw("anxiety") & ~ #raw("personality + demographics + X +") #text(gemini-scheme.hi)[`latent peer anxiety`] \
    #raw("anxiety") & ~ #raw("personality + demographics + X +") #text(gemini-scheme.highlight)[`peer anxiety`]
  $
]

$X$ accounts for localized/group effects. Dimension of $X$ is unknown!

#figure(
  image("/figures/anxiety/estimates.pdf"),
)

#align(center)[
  *Model specification dramatically impacts inference*
]

#bibliography("references.bib", title: none)
