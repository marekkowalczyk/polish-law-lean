# Contributing to PolishLawLean

Contributions formalizing Polish statutes (*ustawy*) and published case law (*orzecznictwo*) in Lean 4 are welcome.

## Core Requirements

1. **Strict Privacy & Anonymity:**
   - Include **only** statutory text, published court decisions (with public signatures, dates, and holdings), and general legal doctrine.
   - Never include facts, names, docket numbers, or document references from private or unpublished cases.
   - All illustrative examples in `PolishLawLean/Examples/` must use clearly synthetic identifiers (such as `Rodzic A`, `Rodzic B`, `Dziecko X`, and invented dates).

2. **Proof Hygiene (No `sorry`, No Custom Axioms):**
   - Every contribution must compile cleanly with `lake build`.
   - Do not use `sorry` or `axiom`. Model open-texture predicates, judicial discretion, and factual findings as `opaque` propositions annotated with `RequiresHumanDeterminationPL` subclasses (`UstalenieFaktyczne`, `VaguePL`, `DiscretionaryPL`).
   - Run `bash scripts/check_axioms.sh` locally before opening a pull request to verify that all theorems depend only on standard Lean kernel axioms (`propext`, `Classical.choice`, `Quot.sound`).

3. **Statutory Citations:**
   - Cite the official consolidated text (*tekst jednolity* in *Dziennik Ustaw*) and the relevant published rulings of the Constitutional Tribunal (*Trybunał Konstytucyjny*), Supreme Court (*Sąd Najwyższy*), Administrative Courts (*NSA/WSA*), or common courts (*sądy powszechne*).

4. **Licensing:**
   - By submitting a contribution, you agree that your work will be licensed under the repository's [MIT License](LICENSE).
