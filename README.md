# PolishLawLean

Formalizing Polish statutory law (*ustawy*) and published case law (*orzecznictwo*) in **Lean 4**, built on top of [`LegalLean`](https://github.com/edu-ap/legal-lean).

> **Disclaimer (Zastrzeżenie prawne):** This repository is an open-source research and software-engineering project encoding the logical structure of Polish legal provisions and published judicial decisions. It does **not** constitute legal advice (*porada prawna*), a certified legal opinion (*opinia prawna*), or a court pleading (*pismo procesowe*). All examples in this repository are strictly hypothetical (*Rodzic A*, *Rodzic B*, *Dziecko X*).

---

## Goal

`PolishLawLean` provides a reusable, machine-checked library for modeling Polish law in Lean 4 across multiple branches of law (starting with civil procedure — *Kodeks postępowania cywilnego*, `k.p.c.`, and extensible to substantive civil law `k.c.`, family law `k.r.o.`, administrative law, and tax law):

1. **Decidable Formal Prerequisites (*Warunki formalne*):** Statutory conditions that can be checked algorithmically (e.g., presence of an enforceable title *tytuł wykonalny*, standing/role *legitymacja*, procedural deadlines such as the 6-month discontinuance rule in art. 598²⁰ k.p.c.) are encoded as computable `Bool` predicates with decidable equality.
2. **Explicit Open Texture (*Granica formalizacji*):** Concepts requiring judicial fact-finding (*ustalenie faktyczne*), interpretation of vague standards (*pojęcia nieostre*, `VaguePL`), or judicial discretion (*uznanie sędziowskie*, `DiscretionaryPL`) are declared as `opaque` propositions annotated with `RequiresHumanDeterminationPL` and `AuthorityPL` metadata. They never introduce unproven `axiom`s or `sorry`s into the Lean kernel.
3. **Two-Stage & Defeasible Reasoning (*Wnioskowanie podważalne*):** Statutory rules (`LegalRule`), constitutional/doctrinal defeaters (`Defeats`), and mixed formal/judicial decision procedures (`FormalisationBoundary.mixed`) make explicit what is verified by the Lean type checker versus what remains for the court (*sąd opiekuńczy*, *sąd okręgowy*, *Sąd Najwyższy*, *Trybunał Konstytucyjny*).
4. **Zero-Sorry, Zero-Custom-Axiom Guarantee:** Every theorem in the repository compiles under `lake build` without `sorry` and depends at most on Lean's standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`), enforced in CI via `scripts/check_axioms.sh`.

---

## Repository Structure

```text
.
├── PolishLawLean.lean                           # Root module importing all library modules
├── PolishLawLean/
│   ├── KPC/
│   │   ├── Art598_15.lean                       # Rule model of art. 598¹⁵–598²⁰, 582¹ § 3, 756² k.p.c.
│   │   └── Art598_15/
│   │       └── Orzecznictwo.lean                # Structured catalog of 12 published rulings (TK, SN, common courts) + jurisprudence theorems
│   └── Examples/
│       └── Hypothetical.lean                    # Purely hypothetical scenarios (Rodzic A, Rodzic B, Dziecko X)
├── scripts/
│   └── check_axioms.sh                          # Static gate & #print axioms report generator
├── .github/workflows/ci.yml                     # GitHub Actions CI workflow (Mathlib cache + build + axiom gate)
├── lakefile.lean                                # Lake package configuration
├── lean-toolchain                               # Pinned Lean toolchain (leanprover/lean4:v4.29.1)
├── CONTRIBUTING.md                              # Contribution guidelines
└── LICENSE                                      # MIT License
```

### Currently Modeled Provisions: `PolishLawLean.KPC.Art598_15`

Models the two-stage procedure for enforcing court-ordered contacts with a child (*wykonywanie kontaktów z dzieckiem*, art. 598¹⁵–598²⁰ k.p.c., consolidated text Dz.U. 2026 poz. 468):

- **Authorities (`AuthorityPL`):** Local Polish adjudicatory authority enumeration (`sadOpiekunczy`, `sadRejonowy`, `sadOkregowyZazalenie`, `sadApelacyjny`, `sadNajwyzszy`, `trybunalKonstytucyjny`), avoiding misuse of US/AU constructors in `LegalLean.Authority` (with a `TODO` to switch once Polish court constructors in the upstream fork are merged).
- **Stage I — Threat of Payment (*Zagrożenie nakazaniem zapłaty*, art. 598¹⁵ § 1–2 k.p.c.):**
  - Formal prerequisites (`warunkiFormalne`): enforceable contact ruling or settlement (`tytulKwalifikowany`, art. 598¹⁹ § 1), matching respondent role (`rolaZgodna`: custodial person under § 1, person entitled to or prohibited from contact under § 2), motion filed (`wniosekZlozony`, art. 598¹⁸ § 1), copy of title attached (`odpisTytuluDolaczony`), and hearing of participants (`wysluchanoUczestnikow`, art. 598¹⁸ § 2).
  - Absence of a statutory upper cap (`brak_gornej_granicy`), contrasted with the 15,000 PLN cap in art. 1052 k.p.c. (`kontrast_1052`).
  - Exclusions (`Defeats` & negative theorems): autonomous child refusal not induced by the custodial person (`odmowa_dziecka_wyklucza`, **TK SK 3/20**), breaches caused exclusively by independent circumstances such as illness (`okolicznosci_niezalezne_wykluczaja`, **SN III CZP 87/22**), and absence of prospective coercive purpose where breaches have ceased (`brak_przymusu_wyklucza`, **I Co 780/15**, **VIII Cz 220/13**).
  - Separation of admissibility from quantum-only factors (**SN III CZP 20/25**, **VI Cz 1481/16**): fault (`Zawinione`), harm to child welfare (`SzkodaDlaDobraDziecka`), and contribution by the entitled person (`PrzyczynienieUprawnionego`) affect only the amount of the sum, not admissibility in principle (`dopuszczalnosc_niezalezna_od_winy`, `etapI_niezalezny_od_winy`).
- **Stage II — Order to Pay (*Nakaz zapłaty należnej sumy pieniężnej*, art. 598¹⁶ & art. 598²⁰ k.p.c.):**
  - Requires a prior Stage I threat order remaining in force (`nakaz_wymaga_mocy_zagrozenia`, **SN III CZP 29/24**), a separate application (`nakaz_wymaga_odrebnego_wniosku`, art. 598¹⁸ § 1 zd. 2), filing within 6 months of the last final order (`po_szesciu_miesiacach_brak_nakazu`, `etapII_po_szesciu_miesiacach`, art. 598²⁰), and at least one unexcused breach after service of the threat (`nakaz_wymaga_dalszego_naruszenia`, `okolicznosc_niezalezna_nie_liczy`).
  - Proportionality of payment due (`naleznosc = liczbaNaruszen * sumaZaNaruszenie`, `kwota_nakazu`), subject to exceptional modification under art. 598¹⁶ § 1 sentence 2 (`WyjatkowaZmianaOkolicznosci`).
- **Prospective Threats Without Prior Breach (`PodstawaZagrozenia`):** Contrasts mandatory enforcement under art. 598¹⁵ (`.obligatory`, requires prior breach) with permissive prospective threats under art. 582¹ § 3 and art. 756² k.p.c. (`.permitted`, **II Cz 484/15**, **I Ca 83/15**, `sciezki_pro_futuro`).
- **Appellate Review on *Zażalenie* (art. 598¹⁵ § 3 k.p.c.):** Encodes **SN III CZP 25/13** — appellate review covers the principle of the threat, refusal to issue a threat, and the quantum in both directions (`wysokosc_zaskarzalna_w_obie_strony`).

### Published Case Law Catalog: `PolishLawLean.KPC.Art598_15.Orzecznictwo`

Contains structured `Orzeczenie` entries for 12 published decisions, recording the signature, court (`AuthorityPL`), date, interpreted provisions, holding (*teza*), and the formal theorems encoding it:

| Court / Tribunal | Signature | Date | Key Holding Encoded |
|---|---|---|---|
| Trybunał Konstytucyjny | `SK 3/20` | 2022-06-22 | Exclusion only when the child's refusal is autonomous and **not induced** by the custodial person (`odmowa_dziecka_wyklucza`) |
| Sąd Najwyższy | `III CZP 20/25` | 2025-10-03 | No re-examination of fault or child's will outside `SK 3/20`; mutual parental contribution does not bar admissibility; applicant contribution may at most reduce the sum (`dopuszczalnosc_niezalezna_od_winy`, `monotonicity_break_general_598_15`) |
| Sąd Najwyższy | `III CZP 87/22` | 2022-04-28 | Implied obligations necessary for contact follow from the title; no strict liability under independent circumstances such as child's illness (`okolicznosci_niezalezne_wykluczaja`, `okolicznosc_niezalezna_nie_liczy`) |
| Sąd Najwyższy | `III CZP 76/22` | 2022-04-13 | Implied cooperation duties follow from the contact order; coercive function of art. 598¹⁵ (`zagrozenie_wymaga_naruszenia`) |
| Sąd Najwyższy | `III CZP 29/24` | 2025-01-29 | Stage II payment order requires the Stage I threat order to remain in force (`nakaz_wymaga_mocy_zagrozenia`, `etapII_wymaga_mocy`) |
| Sąd Najwyższy | `III CZP 25/13` | 2013-05-22 | Two-stage structure (`nakaz_wymaga_zagrozenia`) and bidirectional appellate control of the sum on *zażalenie* (`wysokosc_zaskarzalna_w_obie_strony`) |
| SO w Częstochowie | `VI Cz 1481/16` | 2016 | Degree of bad faith and harm to child welfare as quantum factors (`Zawinione`, `SzkodaDlaDobraDziecka`) |
| SO w Toruniu | `VIII Cz 220/13` | 2013 | Art. 598¹⁵ requires a prior breach and serves prospective coercion (`zagrozenie_wymaga_naruszenia`, `brak_przymusu_wyklucza`) |
| SR w Tczewie | `I Co 780/15` | 2016-05-20 | Dismissal when breaches have ceased and the measure would be purely punitive (`defeat_brakPrzymusu`, `brak_przymusu_wyklucza`) |
| SO w Toruniu | `VIII Cz 681/18` | 2018 | Minority view on judicial discretion contrasted with literal `.obligatory` statutory modality (`R1_598_15_p1`, `p1_obligatoryjny`) |
| SO w Bydgoszczy | `II Cz 484/15` | 2015 | Permissive modality of interim threat under art. 756² k.p.c. (`modalnosc`, `sciezki_pro_futuro`) |
| SO w Sieradzu | `I Ca 83/15` | 2015 | General parental conflict alone does not establish "justified fear of breach" under art. 582¹ § 3 k.p.c. (`UzasadnionaObawa`) |

---

## How to Build and Verify

### Prerequisites

Install [`elan`](https://github.com/leanprover/elan) (the Lean version manager). The project pins `leanprover/lean4:v4.29.1` in `lean-toolchain`.

### Build Commands

```bash
# 1. Fetch precompiled Mathlib cache (avoids building Mathlib from source)
lake exe cache get

# 2. Build all modules
lake build

# 3. Run the sorry/axiom gate and generate the #print axioms report
bash scripts/check_axioms.sh axiom-report.txt
```

---

## How to Add a New Provision (*Przepis*) or Ruling (*Orzeczenie*)

### Adding a New Statutory Provision (*Przepis*)

1. Create a module under the appropriate code directory, e.g.:
   - `PolishLawLean/KPC/<Article>.lean` for *Kodeks postępowania cywilnego*,
   - `PolishLawLean/KC/<Article>.lean` for *Kodeks cywilny*,
   - `PolishLawLean/KRO/<Article>.lean` for *Kodeks rodzinny i opiekuńczy*.
2. Cite the consolidated text (*tekst jednolity*, Dz.U. year and position) in the module header.
3. Encode mechanical statutory prerequisites as decidable `Bool` functions.
4. Encode open-texture or fact-dependent predicates as `opaque` propositions (never `axiom`) and register their boundary metadata with `UstalenieFaktyczne`, `VaguePL`, or `DiscretionaryPL`.
5. Prove structural and boundary theorems without `sorry`, and import the new module in `PolishLawLean.lean`.

### Adding a New Published Ruling (*Orzeczenie*)

1. Add a structured `Orzeczenie` definition in the relevant `Orzecznictwo.lean` module with:
   - `sygnatura` (official docket signature of the published ruling),
   - `organ` (`AuthorityPL`),
   - `sad` (court name),
   - `data` (decision date),
   - `rodzaj` (`wyrokTK`, `uchwalaSN`, or `postanowienieSaduPowszechnego`),
   - `przepisy` (list of interpreted articles),
   - `teza` (summary of the legal holding), and
   - `twierdzeniaWModelu` (identifiers of the Lean theorems/definitions encoding the holding).
2. Append the entry to `katalogOrzecznictwa` and update catalog theorems.
3. **Privacy Rule:** Never include unpublished private case files, real party names, or non-public docket numbers. Use synthetic placeholders (`Rodzic A`, `Rodzic B`, `Dziecko X`) in `PolishLawLean/Examples/Hypothetical.lean`.

---

## License

Released under the [MIT License](LICENSE). Copyright (c) 2026 Marek Kowalczyk.
