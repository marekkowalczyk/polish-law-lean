/-
  PolishLawLean.Examples.Hypothetical — Purely synthetic, hypothetical scenarios
  illustrating the two-stage contact enforcement model (art. 598¹⁵–598²⁰ k.p.c.)
  and its jurisprudential boundaries.

  All parties ("Rodzic A", "Rodzic B", "Dziecko X"), dates, and docket numbers
  are fictional illustrations.
-/

import PolishLawLean.KPC.Art598_15
import PolishLawLean.KPC.Art598_15.Orzecznictwo

set_option autoImplicit false

namespace PolishLawLean.Examples.Hypothetical

open LegalLean
open PolishLawLean.KPC.Art598_15
open PolishLawLean.KPC.Art598_15.Orzecznictwo

-- ============================================================
-- §1  Hypothetical Parties and Contact Title
-- ============================================================

/-- Synthetic party labels for hypothetical family-law scenarios. -/
structure StronyHipotetyczne where
  osobaSprawujacaPiecze : String := "Rodzic A"
  osobaUprawniona       : String := "Rodzic B"
  maloletni             : String := "Dziecko X"
  deriving Repr, BEq, DecidableEq

def stronyPrzykladowe : StronyHipotetyczne := {}

/-- Hypothetical enforceable court order regulating contacts of `Rodzic B` with `Dziecko X`. -/
def tytulHipotetyczny : Tytul where
  sygnatura        := "I Co 100/26 (hipotetyczna)"
  rodzaj           := .orzeczenie
  dotyczyKontaktow := true
  wykonalny        := true

/-- Hypothetical Stage I case where `Rodzic B` applies under art. 598¹⁵ § 1 k.p.c.
    against `Rodzic A` (custodial parent of `Dziecko X`). -/
def sprawaHipotetyczna : Sprawa where
  tytul                 := tytulHipotetyczny
  obowiazany            := .piecza
  wniosekZlozony        := true
  odpisTytuluDolaczony  := true
  wysluchanoUczestnikow := true

theorem hipotetyczna_warunki_formalne :
    warunkiFormalne sprawaHipotetyczna .p1 = true := by decide

/-- Evidence wrapper (`EvidenceFor`) for the formal prerequisites of the hypothetical case. -/
def dowodFormalnyHipotetyczny : EvidenceFor (warunkiFormalne sprawaHipotetyczna .p1 = true) where
  source   := "Dane hipotetyczne (Rodzic A, Rodzic B, Dziecko X)"
  artifact := some "Hipotetyczny odpis wykonalnego postanowienia w przedmiocie kontaktów z dnia 2026-01-15"
  witness  := hipotetyczna_warunki_formalne

-- ============================================================
-- §2  Scenario 1: Stage I Admissibility (art. 598¹⁵ § 1 k.p.c.)
-- ============================================================

/-- Stage I formal input for the hypothetical case (fault and applicant contribution left open). -/
def wejscieEtapIHipotetyczne : WejscieEtapI where
  sprawa                    := sprawaHipotetyczna
  paragraf                  := .p1
  naruszenieZarzucone       := true
  zawinienie                := none
  przyczynienieUprawnionego := none

/-- For the hypothetical Stage I application, the formal check succeeds and yields `.mixed`. -/
theorem hipotetyczna_etapI_mixed :
    JestMixed (rozstrzygnijEtapI wejscieEtapIHipotetyczne) :=
  etapI_zawsze_mixed _ (by decide)

/-- If the guardianship court resolves the admissibility findings (`OcenySadu`) and
    the quantum assessment (`OcenaWysokosci`) for 1,000 PLN per breach, the threat
    order is admissible. -/
theorem hipotetyczna_1000_dopuszczalne
    (zasada : OcenySadu sprawaHipotetyczna)
    (wysokosc : OcenaWysokosci sprawaHipotetyczna 1000) :
    ZagrozenieDopuszczalne sprawaHipotetyczna .p1 1000 :=
  zagrozenie_dopuszczalne _ _ _ hipotetyczna_warunki_formalne (by decide) zasada wysokosc

/-- Under SN III CZP 20/25, even if `Rodzic A` acted without fault and `Rodzic B`
    contributed to the conflict, Stage I admissibility in principle still holds. -/
theorem hipotetyczna_1000_mimo_przyczynienia
    (zasada : OcenySadu sprawaHipotetyczna)
    (wysokosc : OcenaWysokosci sprawaHipotetyczna 1000)
    (hBrakWiny : ¬ Zawinione sprawaHipotetyczna)
    (hBrakSzkody : ¬ SzkodaDlaDobraDziecka sprawaHipotetyczna)
    (hPrzyczynienie : PrzyczynienieUprawnionego sprawaHipotetyczna) :
    ZagrozenieDopuszczalne sprawaHipotetyczna .p1 1000 :=
  dopuszczalnosc_niezalezna_od_winy _ _ _
    hipotetyczna_warunki_formalne (by decide) zasada wysokosc
    hBrakWiny hBrakSzkody hPrzyczynienie

-- ============================================================
-- §3  Scenario 2: Stage II Payment Order (art. 598¹⁶ § 1 k.p.c.)
-- ============================================================

/-- Hypothetical schedule of 5 contact dates between `Rodzic B` and `Dziecko X`
    following the Stage I threat order in spring 2026:
    - 2026-03-07: contact not realized, no independent cause (breach #1);
    - 2026-03-14: contact not realized due to documented fever of `Dziecko X` (excused per III CZP 87/22);
    - 2026-03-21: contact realized normally;
    - 2026-03-28: contact not realized, no independent cause (breach #2);
    - 2026-04-04: contact not realized, no independent cause (breach #3). -/
def terminyHipotetyczneEtapII : List Termin :=
  [ { opis := "2026-03-07 (sobota) — niewydanie Dziecka X Rodzicowi B"
    , kontaktZrealizowany := false
    , okolicznoscNiezalezna := false }
  , { opis := "2026-03-14 (sobota) — infekcja gorączkowa Dziecka X (zaświadczenie lekarskie)"
    , kontaktZrealizowany := false
    , okolicznoscNiezalezna := true }
  , { opis := "2026-03-21 (sobota) — kontakt zrealizowany zgodnie z harmonogramem"
    , kontaktZrealizowany := true
    , okolicznoscNiezalezna := false }
  , { opis := "2026-03-28 (sobota) — niewydanie Dziecka X Rodzicowi B"
    , kontaktZrealizowany := false
    , okolicznoscNiezalezna := false }
  , { opis := "2026-04-04 (sobota) — niewydanie Dziecka X Rodzicowi B"
    , kontaktZrealizowany := false
    , okolicznoscNiezalezna := false }
  ]

/-- Out of the 5 dates, exactly 3 count as actionable breaches, yielding 3,000 PLN
    at a threatened sum of 1,000 PLN per breach. -/
theorem hipotetyczne_naliczenie_etapII :
    liczNaruszenia terminyHipotetyczneEtapII = 3 ∧
    naleznosc (liczNaruszenia terminyHipotetyczneEtapII) 1000 = 3000 := by decide

/-- Formal Stage II input filed 2 months after the threat order became final (within
    the 6-month window of art. 598²⁰ k.p.c.). -/
def wejscieEtapIIHipotetyczne : WejscieEtapII where
  etapI                     := wejscieEtapIHipotetyczne
  zagrozenieWydane          := true
  zagrozenieWMocy           := true
  wniosekOdrebny            := true
  miesiaceOdUprawomocnienia := 2
  dalszeNaruszeniaZarzucone := true

theorem hipotetyczna_etapII_mixed :
    JestMixed (rozstrzygnijEtapII wejscieEtapIIHipotetyczne) :=
  etapII_zawsze_mixed _ (by decide)

-- ============================================================
-- §4  Scenario 3: Statutory and Constitutional Exclusions
-- ============================================================

/-- 3a. Autonomous refusal of `Dziecko X` not induced by `Rodzic A` (TK SK 3/20)
    precludes a threat order. -/
theorem hipotetyczna_wykluczenie_TK_SK_3_20
    (hOdmowa : ZachowanieDzieckaNiewywolane sprawaHipotetyczna) :
    ¬ ZagrozenieDopuszczalne sprawaHipotetyczna .p1 1000 :=
  odmowa_dziecka_wyklucza sprawaHipotetyczna .p1 1000 hOdmowa

/-- 3b. Non-performance caused exclusively by independent circumstances (SN III CZP 87/22)
    precludes a threat order. -/
theorem hipotetyczna_wykluczenie_okolicznosci_niezalezne
    (hNiez : WylacznieOkolicznosciNiezalezne sprawaHipotetyczna) :
    ¬ ZagrozenieDopuszczalne sprawaHipotetyczna .p1 1000 :=
  okolicznosci_niezalezne_wykluczaja sprawaHipotetyczna .p1 1000 hNiez

/-- 3c. Historical breaches that have ceased (no prospective coercive purpose, I Co 780/15)
    preclude a threat order. -/
theorem hipotetyczna_wykluczenie_brak_przymusu
    (hBrakPrzymusu : ¬ CelPrzymuszajacy sprawaHipotetyczna) :
    ¬ ZagrozenieDopuszczalne sprawaHipotetyczna .p1 1000 :=
  brak_przymusu_wyklucza sprawaHipotetyczna .p1 1000 hBrakPrzymusu

/-- 3d. Stage II motion filed 8 months after the last order became final (> 6 months,
    art. 598²⁰ k.p.c.) is rejected automatically (`.formal False`). -/
def wejscieEtapIIPoTerminie : WejscieEtapII :=
  { wejscieEtapIIHipotetyczne with miesiaceOdUprawomocnienia := 8 }

theorem hipotetyczna_etapII_po_6_miesiacach :
    rozstrzygnijEtapII wejscieEtapIIPoTerminie = .formal False :=
  etapII_po_szesciu_miesiacach wejscieEtapIIPoTerminie (by decide)

-- ============================================================
-- §5  Scenario 4: Jurisprudential Shift (SN III CZP 20/25)
-- ============================================================

/-- Hypothetical findings where `Dziecko X` refuses contact, both `Rodzic A` and `Rodzic B`
    contributed to the conflict (`wywolanaPrzezPiecze = true`, `przyczynienieUprawnionego = some true`),
    and the contact order only specifies a schedule (`tytulTylkoHarmonogram = true`). -/
def ustaleniaHipotetyczneWspolprzyczynienie : UstaleniaSprawy where
  warunkiFormalneSpełnione  := true
  naruszenieStwierdzone     := true
  celPrzymuszajacyAktualny  := true
  tytulTylkoHarmonogram     := true
  odmowaDziecka             := true
  wywolanaPrzezPiecze       := true
  wylacznieNiezalezne       := false
  winaObowiazanego          := some true
  przyczynienieUprawnionego := some true

/-- In the hypothetical mutual-contribution scenario, the restrictive pre-2025 line
    dismisses the motion (`.formal False`), whereas the SN III CZP 20/25 line
    classifies it as `.mixed` (admissible in principle, with `Rodzic B`'s contribution
    assessed at the quantum stage). -/
theorem hipotetyczne_zlamanie_monotonicznosci :
    wynikLiniaHistoryczna ustaleniaHipotetyczneWspolprzyczynienie = .formal False ∧
    JestMixed (wynikLiniaSN ustaleniaHipotetyczneWspolprzyczynienie) :=
  monotonicity_break_general_598_15 ustaleniaHipotetyczneWspolprzyczynienie
    rfl rfl rfl rfl rfl rfl

end PolishLawLean.Examples.Hypothetical
