This is track 3 of my PhD.

Plan:
Stage 001: Predict antibody Fv structure from your BCR sequences
This part is solid and fast. From paired heavy/light chain sequences you already have, you can generate 3D Fv models with:

IgFold or ABodyBuilder3 — fast, antibody-specific structure prediction, good for batch-processing hundreds/thousands of your clones
AlphaFold3 or Boltz-2 if you want higher accuracy on a smaller set (e.g. your top expanded clones), at higher compute cost

This gets you CDR loop conformations per clone, which is useful on its own for structural clustering (grouping clones by paratope shape rather than just CDR3 sequence identity).

Stage 002: Paratope prediction (which residues actually contact antigen)
Tools like SAbPred's Ig-Patch or newer PLM-based paratope predictors can flag likely antigen-contacting residues from the Fv structure alone, without needing a known antigen. This lets you characterize the "business end" of each clone's binding site and compare it across clones/follicles/patients.

Stage 3: Structural convergence analysis
This is probably the most tractable "binding-relevant" analysis for your dataset without known antigens: cluster clones by predicted paratope structure/surface (not just CDR3 identity) to ask whether expanded or shared clones across follicles converge on similar binding modes. This connects nicely to your existing clonal-sharing work.

Stage 4: Actual antigen docking (if/when you have candidate antigens)
Only feasible once you have candidate antigens, e.g. specific microbiota-derived proteins you hypothesize your clones target. One caveat worth knowing going in: a March 2026 preprint benchmarking AlphaFold3, Boltz-2, and Chai-1 found that while these tools generate structurally plausible antibody-antigen complexes, their confidence scores often fail to distinguish correct binding pairs from incorrect ones. So even with candidate antigens in hand, docking confidence scores alone won't reliably tell you if a clone actually binds a given target, you'd want orthogonal support (e.g. sequence-based specificity signals, or eventually experimental validation). bioRxiv
