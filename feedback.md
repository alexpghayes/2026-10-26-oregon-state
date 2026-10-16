# Feedback on `slides.typ`

Based on reading the source only; the slides were not compiled, so the rendered layout was not checked.

## Biggest issues

1. **Unfinished spots.**
   - The "Peer effects estimates need perfectly observed networks" slide appears twice, at lines 272 and 322. Both copies end with a broken sentence: "networks are measurement with noisy and imperfectly".
   - The "Use progressively more exotic datasets" slide is a TODO (line 473).
   - The closing slide has the placeholder "consulting obligation".
   - There is an empty final slide (line 641) with a commented-out bibliography.
2. **The noise motivation arrives too late and is too thin.** The talk's selling point is "works with noisy networks". But the problem gets one half-written slide at about slide 9, and the payoff is a single figure (`all_matrices.png`) that has no explanation. The audience never sees why plugging a noisy `A` into 2SLS fails, such as attenuation or errors-in-variables bias. A simulation figure showing the standard estimator breaking and yours holding up would help more than any theorem slide.
3. **The roadmap doesn't match the talk.** The roadmap promises "Other current projects + pitch to students and collaborators". The section is only a bio and an interests slide, with no other projects. Either add one slide of projects or fix the roadmap.
4. **Too much math for about 22 minutes.**
   - The "First: we can estimate…" slide (line 406) is a wall of definitions followed by a theorem. Show the idea in words: smooth `A` to `P̂`, row-normalize, then run 2SLS.
   - Move the estimator details to the appendix, and keep one theorem statement in the main talk.
   - The three consecutive theorem slides (lines 406–444) are the heaviest stretch, and they come right when attention fades.
   - "Hold on! Does this model make sense?" is a nice interlude. But it sits between two copies of the same slide, so the argument doesn't flow.
5. **The notation clashes.**
   - `X` means the design matrix `[W GY]`, the latent positions in the RDPG appendix slide, and "localized/group effects" on the MBA slide.
   - Line 430 defines `hat(D) = diag(tilde(d)…)`, which should be `tilde(D)`.
   - The model slides use `[W GY]` with no intercept, but the appendix uses `[1_n W GW GY]`.
   - Your own appendix assumes zero diagonal of `G`, but `Ĝ` from a rank-r SVD has a nonzero diagonal. Expect a question about that.

## Narrative and content

- **Make the MBA data the running example.** Introduce it on slide 3, so "anxiety/meditation" and the real data are one story. As it stands, the data appear only at the end, and the result slide doesn't say what the estimates show or which model is right.
- **The real-data slide is cramped.** The text is 0.65em and the plot is only 45% of the height. "Specification dramatically impacts inference" needs one concrete number, such as the estimate of `θ_y` against `β_y` and their confidence intervals.
- **Slides 419–425 say "as good as knowing exact friendship".** Spell out what the theorem actually delivers. Is it the same limiting distribution, or the same rate? The audience will take it as an efficiency claim.
- **Add related work.** Mention the measurement-error-in-networks and peer-effects literature briefly, plus your claim "one of the first methods". Hedge that claim, or back it up with citations.
- **The slide on `P̂`, `P` and `A` matrices (line 446) is the best explanatory visual,** but it comes after the theorems. Move it before them as the "why this works" slide.
- **The "joint work with my advisor" slide** has one photo in a side-by-side layout and a lot of empty space. Fold it into the title or roadmap slide.
- **The ending is weak.** Use three takeaways (the `takeaway` helper at line 45 is defined but unused) instead of a "Questions?" slide. The `sin-theta-last-slide.png` image is unexplained, so cut it or caption it.

## Design

- **Orange vs. red.** `bright` (orange) means peer contagion and `red` means latent contagion, and the two are hard to tell apart on a projector or for color-blind viewers. Also, `hl` uses orange for plain emphasis, such as "meditate" on slide 5, so orange carries two meanings. Make latent contagion a distinct hue like blue or purple, and keep orange only for the standard model.
- **Typos:** "nework" (line 389), "measurement with noisy" (lines 279 and 329), and "Okay but does…" repeats the earlier title.
- **`#only("1-")`** on slide 5 does nothing and can be removed.
- **Helpers that look unused:** `pdf-crop`, `design`, `lbl`, `note`, `takeaway`, and the `loops` option in `net`. Prune them or use them.
- **Contact details:** the title and contact slides use an `oregonstate.edu` address, while your git email is Stanford. Check which one you want on the slides.

## Suggested structure (about 18 main slides)

1. Title and roadmap.
2. Peer effects: the meditation/anxiety example.
3. The measurement problem, with the noisy-network picture.
4. The standard model, and why 2SLS needs `A`.
5. Failure of the plug-in estimator, shown by simulation.
6. The latent contagion idea and the `P̂` picture.
7. One theorem slide with the intuition in words.
8. The MBA results.
9. Takeaways, then a short about-me and projects slide.
