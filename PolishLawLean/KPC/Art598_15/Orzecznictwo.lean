/-
  PolishLawLean.KPC.Art598_15.Orzecznictwo — Structured catalog of published
  Constitutional Tribunal (TK), Supreme Court (SN), and common-court (sądy
  powszechne) rulings on art. 598¹⁵–598²⁰ k.p.c., together with formal theorems
  encoding their holdings and the jurisprudential shift culminated in SN III CZP 20/25.

  IMPORTANT: Contains ONLY published rulings (signature, court, date, holding)
  and generic legal doctrine.
-/

import PolishLawLean.KPC.Art598_15

set_option autoImplicit false

namespace PolishLawLean.KPC.Art598_15.Orzecznictwo

open LegalLean
open PolishLawLean.KPC.Art598_15

-- ============================================================
-- §1  Structured Representation of a Published Ruling
-- ============================================================

/-- Category of published judicial decision. -/
inductive RodzajOrzeczenia where
  | wyrokTK
  | uchwalaSN
  | postanowienieSaduPowszechnego
  deriving Repr, BEq, DecidableEq

/-- Structured metadata and formal mapping for a single published ruling. -/
structure Orzeczenie where
  /-- Case signature (sygnatura), e.g. `"SK 3/20"` or `"III CZP 20/25"`. -/
  sygnatura          : String
  /-- Competent authority type in `AuthorityPL`. -/
  organ              : AuthorityPL
  /-- Full name of the court or tribunal. -/
  sad                : String
  /-- Date of the ruling (`YYYY-MM-DD` when exact day is published, or year). -/
  data               : String
  /-- Kind of ruling. -/
  rodzaj             : RodzajOrzeczenia
  /-- Statutory provisions interpreted by the ruling. -/
  przepisy           : List String
  /-- Concise summary of the legal holding (teza). -/
  teza               : String
  /-- Names of theorems and definitions in `PolishLawLean` that encode the holding. -/
  twierdzeniaWModelu : List String
  deriving Repr, BEq, DecidableEq

-- ============================================================
-- §2  Catalog of Published Rulings (TK, SN, Common Courts)
-- ============================================================

/-- 1. Wyrok Trybunału Konstytucyjnego z 22.06.2022 r., SK 3/20 (Dz.U. 2022 poz. 1371). -/
def orzeczenie_TK_SK_3_20 : Orzeczenie where
  sygnatura := "SK 3/20"
  organ     := .trybunalKonstytucyjny
  sad       := "Trybunał Konstytucyjny"
  data      := "2022-06-22"
  rodzaj    := .wyrokTK
  przepisy  := ["art. 598¹⁵ § 1 k.p.c.", "art. 598¹⁶ § 1 k.p.c.", "art. 48 ust. 1 Konstytucji RP", "art. 72 ust. 3 Konstytucji RP"]
  teza      := "Art. 598¹⁶ § 1 w zw. z art. 598¹⁵ § 1 k.p.c. są niezgodne z Konstytucją w zakresie, w jakim obejmują sytuacje, w których niewłaściwe wykonywanie lub niewykonywanie obowiązków związane jest z zachowaniem dziecka niewywołanym przez osobę, pod której pieczą dziecko się znajduje."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.ZachowanieDzieckaNiewywolane",
    "PolishLawLean.KPC.Art598_15.defeat_TK_SK_3_20",
    "PolishLawLean.KPC.Art598_15.odmowa_dziecka_wyklucza"
  ]

/-- 2. Uchwała Sądu Najwyższego z 03.10.2025 r., III CZP 20/25. -/
def orzeczenie_SN_III_CZP_20_25 : Orzeczenie where
  sygnatura := "III CZP 20/25"
  organ     := .sadNajwyzszy
  sad       := "Sąd Najwyższy"
  data      := "2025-10-03"
  rodzaj    := .uchwalaSN
  przepisy  := ["art. 598¹⁵ § 1 k.p.c.", "art. 598¹⁶ § 1 k.p.c."]
  teza      := "W postępowaniu o wykonywanie kontaktów sąd nie bada ponownie zawinienia ani woli dziecka jako przesłanek wyłączających zasadę odpowiedzialności poza wąskim zakresem wyroku TK SK 3/20 (postawa dziecka niewywołana przez opiekuna); istotne przyczynienie się uprawnionego do postawy dziecka może co najwyżej uzasadniać obniżenie sumy pieniężnej (art. 598¹⁶ § 1 zd. 2 k.p.c.)."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.dopuszczalnosc_niezalezna_od_winy",
    "PolishLawLean.KPC.Art598_15.etapI_niezalezny_od_winy",
    "PolishLawLean.KPC.Art598_15.Orzecznictwo.monotonicity_break_general_598_15",
    "PolishLawLean.KPC.Art598_15.Orzecznictwo.wynikLiniaSN_niezalezny_od_winy"
  ]

/-- 3. Uchwała Sądu Najwyższego z 28.04.2022 r., III CZP 87/22. -/
def orzeczenie_SN_III_CZP_87_22 : Orzeczenie where
  sygnatura := "III CZP 87/22"
  organ     := .sadNajwyzszy
  sad       := "Sąd Najwyższy"
  data      := "2022-04-28"
  rodzaj    := .uchwalaSN
  przepisy  := ["art. 598¹⁵ § 1 k.p.c.", "art. 598¹⁶ § 1 k.p.c."]
  teza      := "Obowiązki wynikające z orzeczenia lub ugody w przedmiocie kontaktów obejmują również obowiązki dorozumiane, niezbędne do realizacji kontaktu (np. przygotowanie i wydanie dziecka); przepisy nie wprowadzają jednak absolutnej odpowiedzialności za rezultat, gdy niewykonanie wynika z okoliczności niezależnych (np. choroby dziecka)."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.WylacznieOkolicznosciNiezalezne",
    "PolishLawLean.KPC.Art598_15.defeat_okolicznoscNiezalezna",
    "PolishLawLean.KPC.Art598_15.okolicznosci_niezalezne_wykluczaja",
    "PolishLawLean.KPC.Art598_15.okolicznosc_niezalezna_nie_liczy"
  ]

/-- 4. Uchwała Sądu Najwyższego z 13.04.2022 r., III CZP 76/22. -/
def orzeczenie_SN_III_CZP_76_22 : Orzeczenie where
  sygnatura := "III CZP 76/22"
  organ     := .sadNajwyzszy
  sad       := "Sąd Najwyższy"
  data      := "2022-04-13"
  rodzaj    := .uchwalaSN
  przepisy  := ["art. 598¹⁵ § 1 k.p.c."]
  teza      := "Z orzeczenia lub ugody regulującej kontakty wynikają także obowiązki o charakterze dorozumianym, warunkujące prawidłowe wykonanie kontaktu; środek z art. 598¹⁵ k.p.c. pełni funkcję przymuszającą do realnego wykonywania tytułu."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.NaruszenieNastapilo",
    "PolishLawLean.KPC.Art598_15.CelPrzymuszajacy",
    "PolishLawLean.KPC.Art598_15.zagrozenie_wymaga_naruszenia"
  ]

/-- 5. Uchwała Sądu Najwyższego z 29.01.2025 r., III CZP 29/24. -/
def orzeczenie_SN_III_CZP_29_24 : Orzeczenie where
  sygnatura := "III CZP 29/24"
  organ     := .sadNajwyzszy
  sad       := "Sąd Najwyższy"
  data      := "2025-01-29"
  rodzaj    := .uchwalaSN
  przepisy  := ["art. 598¹⁶ § 1 k.p.c.", "art. 598¹⁵ § 1 k.p.c."]
  teza      := "Nakazanie zapłaty sumy pieniężnej na podstawie art. 598¹⁶ § 1 k.p.c. (etap II) wymaga, aby uprzednie postanowienie o zagrożeniu nakazaniem zapłaty pozostawało w mocy i aby po jego wydaniu nastąpiły dalsze naruszenia."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.nakaz_wymaga_mocy_zagrozenia",
    "PolishLawLean.KPC.Art598_15.etapII_wymaga_mocy",
    "PolishLawLean.KPC.Art598_15.nakaz_wymaga_dalszego_naruszenia"
  ]

/-- 6. Uchwała Sądu Najwyższego z 22.05.2013 r., III CZP 25/13 (OSNC 2013/12/140). -/
def orzeczenie_SN_III_CZP_25_13 : Orzeczenie where
  sygnatura := "III CZP 25/13"
  organ     := .sadNajwyzszy
  sad       := "Sąd Najwyższy"
  data      := "2013-05-22"
  rodzaj    := .uchwalaSN
  przepisy  := ["art. 598¹⁵ § 1–3 k.p.c.", "art. 598¹⁶ § 1 k.p.c."]
  teza      := "Postępowanie ma charakter dwuetapowy (zagrożenie → nakaz zapłaty); w zażaleniu na postanowienie o zagrożeniu kontroli podlega zarówno sama zasada zagrożenia, jak i prawidłowość określenia wysokości sumy pieniężnej (w obu kierunkach)."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.nakaz_wymaga_zagrozenia",
    "PolishLawLean.KPC.Art598_15.wysokosc_zaskarzalna_w_obie_strony",
    "PolishLawLean.KPC.Art598_15.decyzja_zawsze_mixed"
  ]

/-- 7. Postanowienie Sądu Okręgowego w Częstochowie z 2016 r., VI Cz 1481/16. -/
def orzeczenie_SO_VI_Cz_1481_16 : Orzeczenie where
  sygnatura := "VI Cz 1481/16"
  organ     := .sadOkregowyZazalenie
  sad       := "Sąd Okręgowy w Częstochowie"
  data      := "2016"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 598¹⁵ § 1 k.p.c."]
  teza      := "Na wymiar sumy pieniężnej wpływają — obok sytuacji majątkowej obowiązanego — stopień złej woli (uporczywość naruszeń) oraz ujemny wpływ zachowania obowiązanego na dobro dziecka; sąd II instancji może podwyższyć sumę przy uporczywych naruszeniach."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.Zawinione",
    "PolishLawLean.KPC.Art598_15.SzkodaDlaDobraDziecka",
    "PolishLawLean.KPC.Art598_15.UwzglednionoCzynnikiKwotowe",
    "PolishLawLean.KPC.Art598_15.wysokosc_zaskarzalna_w_obie_strony"
  ]

/-- 8. Postanowienie Sądu Okręgowego w Toruniu z 2013 r., VIII Cz 220/13. -/
def orzeczenie_SO_VIII_Cz_220_13 : Orzeczenie where
  sygnatura := "VIII Cz 220/13"
  organ     := .sadOkregowyZazalenie
  sad       := "Sąd Okręgowy w Toruniu"
  data      := "2013"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 598¹⁵ § 1 k.p.c."]
  teza      := "Zagrożenie nakazaniem zapłaty na podstawie art. 598¹⁵ k.p.c. wymaga uprzedniego stwierdzenia naruszenia obowiązków z tytułu kontaktowego i służy przymuszeniu do ich wykonywania w przyszłości."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.zagrozenie_wymaga_naruszenia",
    "PolishLawLean.KPC.Art598_15.brak_przymusu_wyklucza",
    "PolishLawLean.KPC.Art598_15.sciezki_pro_futuro"
  ]

/-- 9. Postanowienie Sądu Rejonowego w Tczewie z 20.05.2016 r., I Co 780/15. -/
def orzeczenie_SR_I_Co_780_15 : Orzeczenie where
  sygnatura := "I Co 780/15"
  organ     := .sadRejonowy
  sad       := "Sąd Rejonowy w Tczewie"
  data      := "2016-05-20"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 598¹⁵ § 1 k.p.c.", "art. 1051¹ k.p.c."]
  teza      := "Środek przymuszający nie ma charakteru kary za przeszłe, zakończone już naruszenia; jeżeli naruszenia ustały i obowiązek jest wykonywany, wniosek podlega oddaleniu z uwagi na brak celu przymuszającego."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.CelPrzymuszajacy",
    "PolishLawLean.KPC.Art598_15.defeat_brakPrzymusu",
    "PolishLawLean.KPC.Art598_15.brak_przymusu_wyklucza"
  ]

/-- 10. Postanowienie Sądu Okręgowego w Toruniu z 2018 r., VIII Cz 681/18. -/
def orzeczenie_SO_VIII_Cz_681_18 : Orzeczenie where
  sygnatura := "VIII Cz 681/18"
  organ     := .sadOkregowyZazalenie
  sad       := "Sąd Okręgowy w Toruniu"
  data      := "2018"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 598¹⁵ § 1 k.p.c."]
  teza      := "Pogląd mniejszościowy przyjmujący pewną swobodę jurysdykcyjną sądu opiekuńczego mimo kategorycznego brzmienia ustawy ('sąd opiekuńczy ... zagrozi'); w modelu zestawiony z literalną modalnością obligatoryjną."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.R1_598_15_p1",
    "PolishLawLean.KPC.Art598_15.p1_obligatoryjny"
  ]

/-- 11. Postanowienie Sądu Okręgowego w Bydgoszczy z 2015 r., II Cz 484/15. -/
def orzeczenie_SO_II_Cz_484_15 : Orzeczenie where
  sygnatura := "II Cz 484/15"
  organ     := .sadOkregowyZazalenie
  sad       := "Sąd Okręgowy w Bydgoszczy"
  data      := "2015"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 756² § 1 k.p.c.", "art. 598¹⁵ k.p.c."]
  teza      := "Zagrożenie nakazaniem zapłaty w postanowieniu o udzieleniu zabezpieczenia (art. 756² k.p.c.) ma charakter fakultatywny ('może zagrozić'), w odróżnieniu od obligatoryjnego trybu wykonawczego z art. 598¹⁵ k.p.c., lecz decyzja sądu nie może być dowolna."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.PodstawaZagrozenia",
    "PolishLawLean.KPC.Art598_15.modalnosc",
    "PolishLawLean.KPC.Art598_15.sciezki_pro_futuro"
  ]

/-- 12. Postanowienie Sądu Okręgowego w Sieradzu z 2015 r., I Ca 83/15. -/
def orzeczenie_SO_I_Ca_83_15 : Orzeczenie where
  sygnatura := "I Ca 83/15"
  organ     := .sadOkregowyZazalenie
  sad       := "Sąd Okręgowy w Sieradzu"
  data      := "2015"
  rodzaj    := .postanowienieSaduPowszechnego
  przepisy  := ["art. 582¹ § 3 k.p.c.", "art. 598¹⁵ k.p.c."]
  teza      := "Sam ogólny konflikt między rodzicami nie wystarcza do przyjęcia 'uzasadnionej obawy naruszenia obowiązków' z art. 582¹ § 3 k.p.c. bez konkretnych okoliczności wskazujących na groźbę niewykonywania orzeczenia."
  twierdzeniaWModelu := [
    "PolishLawLean.KPC.Art598_15.UzasadnionaObawa",
    "PolishLawLean.KPC.Art598_15.wymagaStwierdzonegoNaruszenia",
    "PolishLawLean.KPC.Art598_15.sciezki_pro_futuro"
  ]

/-- Complete list of the 12 core published rulings modeled in this package. -/
def katalogOrzecznictwa : List Orzeczenie :=
  [ orzeczenie_TK_SK_3_20
  , orzeczenie_SN_III_CZP_20_25
  , orzeczenie_SN_III_CZP_87_22
  , orzeczenie_SN_III_CZP_76_22
  , orzeczenie_SN_III_CZP_29_24
  , orzeczenie_SN_III_CZP_25_13
  , orzeczenie_SO_VI_Cz_1481_16
  , orzeczenie_SO_VIII_Cz_220_13
  , orzeczenie_SR_I_Co_780_15
  , orzeczenie_SO_VIII_Cz_681_18
  , orzeczenie_SO_II_Cz_484_15
  , orzeczenie_SO_I_Ca_83_15
  ]

theorem katalog_zawiera_12_orzeczen : katalogOrzecznictwa.length = 12 := by decide

theorem kazde_orzeczenie_ma_twierdzenie :
    katalogOrzecznictwa.all (fun o => !o.twierdzeniaWModelu.isEmpty) = true := by decide

-- ============================================================
-- §3  Jurisprudential Evolution: Pre-2025 Practice vs SN III CZP 20/25
-- ============================================================

/-- Structured representation of factual findings in a contact-enforcement dispute
    used to compare the restrictive pre-2025 common-court interpretation with the
    clarified Supreme Court line (SN III CZP 87/22, III CZP 76/22, III CZP 20/25). -/
structure UstaleniaSprawy where
  /-- Formal procedural prerequisites under art. 598¹⁵, 598¹⁸, 598¹⁹ k.p.c. are satisfied. -/
  warunkiFormalneSpełnione : Bool
  /-- Whether specific contact duties (at least implied duties, III CZP 87/22) were breached. -/
  naruszenieStwierdzone    : Bool
  /-- Whether breaches are ongoing / prospective coercion is needed (I Co 780/15). -/
  celPrzymuszajacyAktualny : Bool
  /-- Whether the contact title only states contact schedule without explicit preparation clauses. -/
  tytulTylkoHarmonogram    : Bool
  /-- Whether the child expresses reluctance/refusal to participate in contact. -/
  odmowaDziecka            : Bool
  /-- Whether the child's reluctance was induced or co-induced by the custodial person. -/
  wywolanaPrzezPiecze      : Bool
  /-- Whether breaches resulted exclusively from independent circumstances (e.g. illness). -/
  wylacznieNiezalezne      : Bool
  /-- Optional finding on fault of the custodial person. -/
  winaObowiazanego         : Option Bool
  /-- Optional finding on contribution by the entitled person. -/
  przyczynienieUprawnionego : Option Bool
  deriving Repr, BEq, DecidableEq

/-- Restrictive historical approach (seen in some earlier common-court decisions):
    treated any child refusal (`odmowaDziecka = true`) or a contact order lacking explicit
    ancillary obligations (`tytulTylkoHarmonogram = true`) as a bar to art. 598¹⁵ § 1. -/
def wynikLiniaHistoryczna (u : UstaleniaSprawy) : FormalisationBoundary Prop :=
  if !u.warunkiFormalneSpełnione || !u.naruszenieStwierdzone || !u.celPrzymuszajacyAktualny then
    .formal False
  else if u.wylacznieNiezalezne then
    .formal False
  else if u.odmowaDziecka || u.tytulTylkoHarmonogram then
    .formal False
  else
    .mixed czescFormalnaEtapI czescSadowaEtapI

/-- Clarified Supreme Court line (SN III CZP 87/22, III CZP 76/22, TK SK 3/20, SN III CZP 20/25):
    - implied duties follow from the contact schedule (`tytulTylkoHarmonogram` does NOT bar enforcement);
    - child refusal bars enforcement ONLY when autonomous and NOT induced by the custodial person
      (`u.odmowaDziecka && !u.wywolanaPrzezPiecze`);
    - fault (`winaObowiazanego`) and applicant contribution (`przyczynienieUprawnionego`) affect
      at most the quantum, never admissibility in principle. -/
def wynikLiniaSN (u : UstaleniaSprawy) : FormalisationBoundary Prop :=
  if !u.warunkiFormalneSpełnione || !u.naruszenieStwierdzone || !u.celPrzymuszajacyAktualny then
    .formal False
  else if u.wylacznieNiezalezne then
    .formal False
  else if u.odmowaDziecka && !u.wywolanaPrzezPiecze then
    .formal False
  else
    .mixed czescFormalnaEtapI czescSadowaEtapI

/-- General monotonicity-break theorem (`monotonicity_break_general_598_15`):
    For EVERY factual configuration in which formal prerequisites, breach, and prospective
    coercive purpose hold, no independent-circumstance exclusion applies, and the child's
    refusal was induced (or co-induced) by the custodial person (`odmowaDziecka = true`,
    `wywolanaPrzezPiecze = true`), the historical approach automatically dismisses the
    application (`.formal False`), whereas the SN III CZP 20/25 line classifies it as
    `.mixed` (admissible in principle; quantum left to the court). -/
theorem monotonicity_break_general_598_15 (u : UstaleniaSprawy)
    (hForm : u.warunkiFormalneSpełnione = true)
    (hNar  : u.naruszenieStwierdzone = true)
    (hCel  : u.celPrzymuszajacyAktualny = true)
    (hNiez : u.wylacznieNiezalezne = false)
    (hOdm  : u.odmowaDziecka = true)
    (hWyw  : u.wywolanaPrzezPiecze = true) :
    wynikLiniaHistoryczna u = .formal False ∧ JestMixed (wynikLiniaSN u) := by
  refine ⟨?_, ⟨czescFormalnaEtapI, czescSadowaEtapI, ?_⟩⟩
  · simp [wynikLiniaHistoryczna, hForm, hNar, hCel, hNiez, hOdm]
  · simp [wynikLiniaSN, hForm, hNar, hCel, hNiez, hOdm, hWyw]

/-- Under the SN line, when formal prerequisites, breach, and coercive purpose hold,
    the absence of independent circumstances and the presence of custodial inducement
    preclude automatic dismissal. -/
theorem po_linii_SN_brak_automatycznego_oddalenia (u : UstaleniaSprawy)
    (hForm : u.warunkiFormalneSpełnione = true)
    (hNar  : u.naruszenieStwierdzone = true)
    (hCel  : u.celPrzymuszajacyAktualny = true)
    (hNiez : u.wylacznieNiezalezne = false)
    (hWyw  : u.wywolanaPrzezPiecze = true) :
    wynikLiniaSN u ≠ .formal False := by
  simp [wynikLiniaSN, hForm, hNar, hCel, hNiez, hWyw]

/-- Under SN III CZP 20/25, fault and applicant contribution never change `wynikLiniaSN`. -/
theorem wynikLiniaSN_niezalezny_od_winy (u : UstaleniaSprawy) (w p : Option Bool) :
    wynikLiniaSN { u with winaObowiazanego := w, przyczynienieUprawnionego := p } =
      wynikLiniaSN u := rfl

/-- Conversely, when the child's refusal is autonomous and NOT induced by the custodial
    person (`odmowaDziecka = true`, `wywolanaPrzezPiecze = false`), TK SK 3/20 excludes
    the sanction under both lines. -/
theorem zgodnosc_przy_samodzielnej_odmowie_dziecka (u : UstaleniaSprawy)
    (hForm : u.warunkiFormalneSpełnione = true)
    (hNar  : u.naruszenieStwierdzone = true)
    (hCel  : u.celPrzymuszajacyAktualny = true)
    (hNiez : u.wylacznieNiezalezne = false)
    (hOdm  : u.odmowaDziecka = true)
    (hBrakWyw : u.wywolanaPrzezPiecze = false) :
    wynikLiniaHistoryczna u = .formal False ∧ wynikLiniaSN u = .formal False := by
  simp [wynikLiniaHistoryczna, wynikLiniaSN, hForm, hNar, hCel, hNiez, hOdm, hBrakWyw]

end PolishLawLean.KPC.Art598_15.Orzecznictwo
