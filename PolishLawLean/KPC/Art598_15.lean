/-
  PolishLawLean.KPC.Art598_15 — Formalization of art. 598¹⁵–598²⁰ k.p.c.
  (Polish Code of Civil Procedure: enforcing court-ordered contacts with a child)
  built on top of LegalLean.

  DISCLAIMER: Academic and engineering formalization of statutory logic and
  published case law. Not legal advice or a court pleading.

  SOURCE OF STATUTE TEXT (consolidated text / tekst jednolity):
    Obwieszczenie Marszałka Sejmu RP z 27 marca 2026 r., Dz.U. 2026 poz. 468
    (published 7 April 2026)
    https://api.sejm.gov.pl/eli/acts/DU/2026/468/text.pdf
    https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20260000468

  CASE LAW MODELED:
  - TK SK 3/20 (22.06.2022, Dz.U. 2022 poz. 1371): exclusion applies only to the
    child's behavior NOT induced by the custodial person;
  - SN III CZP 20/25 (03.10.2025): in the enforcement phase the court does not
    re-examine fault or the child's will as admissibility bars; substantial
    contribution by the entitled person may at most reduce the payment sum;
  - SN III CZP 87/22 (28.04.2022), III CZP 76/22 (13.04.2022): implied obligations
    necessary to carry out contact "follow from" the contact order; no strict
    liability for the result under independent circumstances (e.g., child's illness);
  - SN III CZP 29/24 (29.01.2025), III CZP 25/13 (22.05.2013): stage II requires
    the threat order to remain in force and continued non-compliance ("nie wypełnia
    nadal"); the amount of the sum is reviewable on appeal (zażalenie) in both
    directions;
  - Common-court decisions: VI Cz 1481/16, VIII Cz 220/13, I Co 780/15,
    VIII Cz 681/18, II Cz 484/15, I Ca 83/15, IV Cz 235/14;
  - Related provisions: art. 598²⁰ (discontinuance after 6 months of inactivity),
    art. 582¹ § 3 and art. 756² (prospective threat without prior breach).

  Conventions from LegalLean (github.com/edu-ap/legal-lean, MIT):
  - Formal prerequisites = decidable `Bool` functions;
  - Open-texture concepts = `opaque` propositions + boundary metadata typeclasses
    (no `axiom` declarations, so no custom axioms enter the kernel);
  - Rules = `LegalRule`, exceptions = `Defeats`, evidence = `EvidenceFor`.
-/

import LegalLean.Core
import LegalLean.Defeasible

set_option autoImplicit false

namespace PolishLawLean.KPC.Art598_15

open LegalLean

-- ============================================================
-- §0  Polish Adjudicatory Authorities & Formalisation Boundary
-- ============================================================

/-- Polish adjudicatory authorities relevant to civil and family procedure.
    TODO: Switch to `LegalLean.Authority` Polish court constructors
    (`sadRejonowy`, `sadOkregowy`, `sadApelacyjny`, `sadNajwyzszy`,
    `trybunalKonstytucyjny`) once the Polish-authorities branch of
    the LegalLean dependency is merged into the base revision. -/
inductive AuthorityPL where
  /-- Sąd opiekuńczy — family and guardianship division of the district court (art. 568, 598¹⁵ k.p.c.). -/
  | sadOpiekunczy          : AuthorityPL
  /-- Sąd rejonowy — Polish district court (first instance). -/
  | sadRejonowy            : AuthorityPL
  /-- Sąd okręgowy — Polish regional court (including second-instance appeal court under art. 598¹⁵ § 3, 598¹⁶ § 3 k.p.c.). -/
  | sadOkregowyZazalenie   : AuthorityPL
  /-- Sąd apelacyjny — Polish court of appeal. -/
  | sadApelacyjny          : AuthorityPL
  /-- Sąd Najwyższy — Supreme Court of Poland. -/
  | sadNajwyzszy           : AuthorityPL
  /-- Trybunał Konstytucyjny — Constitutional Tribunal of Poland. -/
  | trybunalKonstytucyjny : AuthorityPL
  deriving Repr, BEq, DecidableEq, Inhabited

/-- Human-readable Polish description of an `AuthorityPL`. -/
def AuthorityPL.opis : AuthorityPL → String
  | .sadOpiekunczy          => "Sąd opiekuńczy (wydział rodzinny sądu rejonowego, art. 598¹⁵ k.p.c.)"
  | .sadRejonowy            => "Sąd rejonowy"
  | .sadOkregowyZazalenie   => "Sąd okręgowy jako sąd II instancji (art. 598¹⁵ § 3, art. 598¹⁶ § 3 k.p.c.)"
  | .sadApelacyjny          => "Sąd apelacyjny"
  | .sadNajwyzszy           => "Sąd Najwyższy"
  | .trybunalKonstytucyjny => "Trybunał Konstytucyjny"

/-- Format a reason string prefixed with the competent Polish authority. -/
def powodPL (o : AuthorityPL) (r : String) : String := "[" ++ o.opis ++ "] " ++ r

/-- Typeclass marking propositions that require determination by a Polish adjudicatory
    authority (`AuthorityPL`), avoiding misuse of US/AU `LegalLean.Authority` constructors.
    TODO: Switch to `LegalLean.RequiresHumanDetermination` once `LegalLean.Authority`
    includes Polish court constructors on the pinned revision. -/
class RequiresHumanDeterminationPL (P : Prop) where
  reason    : String
  authority : AuthorityPL

/-- Vague legal concepts (pojęcia nieostre) with a settled core and contested penumbra,
    adjudicated by an `AuthorityPL`. -/
class VaguePL (P : Prop) extends RequiresHumanDeterminationPL P where
  core     : String
  penumbra : String

/-- Discretionary judicial determinations (uznanie sędziowskie) with scope and constraints,
    adjudicated by an `AuthorityPL`. -/
class DiscretionaryPL (P : Prop) extends RequiresHumanDeterminationPL P where
  scope       : String
  constraints : List String

/-- Factual determinations made by a Polish court on the basis of evidentiary sources
    (ustalenie faktyczne na podstawie środków dowodowych). -/
class UstalenieFaktyczne (P : Prop) extends RequiresHumanDeterminationPL P where
  dowody : List String

/-- Formalisation boundary parameterized with `AuthorityPL` for the `.boundary` case.
    Converts cleanly to `LegalLean.FormalisationBoundary` via `.mixed` or `.formal`. -/
inductive FormalisationBoundaryPL (P : Sort _) where
  | formal (proof : P) : FormalisationBoundaryPL P
  | boundary (reason : String) (authority : AuthorityPL) : FormalisationBoundaryPL P
  | mixed (formalPart : String) (humanPart : String) : FormalisationBoundaryPL P

-- ============================================================
-- §1  Domain Types (Typy dziedzinowe)
-- ============================================================

/-- Kind of legal instrument regulating contacts with a child. -/
inductive RodzajTytulu where
  | orzeczenie
  | ugodaPrzedSadem
  | ugodaPrzedMediatorem
  deriving Repr, BEq, DecidableEq

/-- Title regulating contacts with a child (tytuł regulujący kontakty). -/
structure Tytul where
  sygnatura        : String
  rodzaj           : RodzajTytulu
  dotyczyKontaktow : Bool
  /-- art. 598¹⁹ § 1 k.p.c.: copy of an ENFORCEABLE (wykonalnego) ruling or settlement. -/
  wykonalny        : Bool
  deriving Repr, BEq, DecidableEq

/-- Statutory role of the respondent under art. 598¹⁵ § 1 or § 2 k.p.c. -/
inductive Rola where
  | piecza               -- § 1: „osoba, pod której pieczą dziecko pozostaje”
  | uprawnionyDoKontaktu -- § 2: „osoba uprawniona do kontaktu z dzieckiem”
  | zakazKontaktu        -- § 2: „osoba, której tego kontaktu zakazano”
  deriving Repr, BEq, DecidableEq

/-- Paragraph of art. 598¹⁵ k.p.c. invoked in the application. -/
inductive Paragraf where
  | p1
  | p2
  deriving Repr, BEq, DecidableEq

/-- Formal procedural parameters of a contact-enforcement case. -/
structure Sprawa where
  tytul                 : Tytul
  obowiazany            : Rola
  wniosekZlozony        : Bool  -- art. 598¹⁸ § 1 (art. 570 ex officio does not apply)
  odpisTytuluDolaczony  : Bool  -- art. 598¹⁹ § 1
  wysluchanoUczestnikow : Bool  -- art. 598¹⁸ § 2
  deriving Repr, BEq, DecidableEq

/-- Monetary amount in Polish zlotys (PLN). -/
abbrev Zlote := Nat

-- ============================================================
-- §2  Statute Text & Decidable Formal Prerequisites
-- ============================================================

/-- Art. 598¹⁵ § 1 k.p.c. (Dz.U. 2026 poz. 468):
    „Jeżeli osoba, pod której pieczą dziecko pozostaje, nie wykonuje albo
    niewłaściwie wykonuje obowiązki wynikające z orzeczenia albo z ugody zawartej
    przed sądem lub przed mediatorem w przedmiocie kontaktów z dzieckiem, sąd
    opiekuńczy, uwzględniając sytuację majątkową tej osoby, zagrozi jej nakazaniem
    zapłaty na rzecz osoby uprawnionej do kontaktu z dzieckiem oznaczonej sumy
    pieniężnej za każde naruszenie obowiązku.”

    Footnote 74 to the consolidated text: art. 598¹⁶ § 1 in conjunction with
    art. 598¹⁵ § 1, insofar as they cover situations in which improper performance
    or non-performance of duties is linked to the child's behavior not induced by
    the custodial person, are inconsistent with art. 48(1) sentence 2 and art. 72(3)
    of the Constitution (TK judgment of 22.06.2022, SK 3/20, Dz.U. poz. 1371).

    Art. 598¹⁵ § 2: „Jeżeli osoba uprawniona do kontaktu z dzieckiem albo osoba,
    której tego kontaktu zakazano, narusza obowiązki wynikające z orzeczenia albo
    z ugody zawartej przed sądem lub przed mediatorem w przedmiocie kontaktów
    z dzieckiem, sąd opiekuńczy zagrozi tej osobie nakazaniem zapłaty oznaczonej
    sumy pieniężnej na rzecz osoby, pod której pieczą dziecko pozostaje, stosując
    odpowiednio przepis § 1.”

    Art. 598¹⁵ § 3: „Na postanowienia sądu, o których mowa w § 1 i 2, przysługuje
    zażalenie.” -/
def rolaZgodna : Paragraf → Rola → Bool
  | .p1, .piecza               => true
  | .p2, .uprawnionyDoKontaktu => true
  | .p2, .zakazKontaktu        => true
  | _,   _                     => false

def tytulKwalifikowany (t : Tytul) : Bool :=
  t.dotyczyKontaktow && t.wykonalny

def warunkiFormalne (s : Sprawa) (p : Paragraf) : Bool :=
  tytulKwalifikowany s.tytul && rolaZgodna p s.obowiazany &&
  s.wniosekZlozony && s.odpisTytuluDolaczony && s.wysluchanoUczestnikow

/-- No statutory upper cap in art. 598¹⁵ k.p.c.
    Contrast: art. 1052 k.p.c. caps a single fine order at 15,000 PLN. -/
def gornaGranica598_15 : Option Zlote := none
def gornaGranica1052   : Option Zlote := some 15000

def kwotaNieWykluczonaUstawowo (granica : Option Zlote) (k : Zlote) : Prop :=
  0 < k ∧ match granica with
          | none   => True
          | some m => k ≤ m

-- ============================================================
-- §3  Elements Requiring Judicial Determination
-- ============================================================

-- 3a. Admissibility / Principle Conditions (Przesłanki zasady)

/-- A breach of contact duties occurred. Includes implied duties necessary to
    carry out contact (SN III CZP 87/22, III CZP 76/22), such as preparing and
    handing over the child. Under art. 598¹⁵ an already established breach is
    required (III CZP 25/13; VIII Cz 220/13). -/
opaque NaruszenieNastapilo : Sprawa → Prop

/-- Child's refusal/behavior NOT induced (neither caused nor shaped) by the
    custodial person — the narrow scope excluded by TK SK 3/20.
    A child's attitude induced by both parents does NOT fall within this exclusion
    (SN III CZP 20/25). -/
opaque ZachowanieDzieckaNiewywolane : Sprawa → Prop

/-- All alleged non-performances resulted exclusively from independent
    circumstances (e.g., child's illness, unforeseen transport disruption;
    SN III CZP 87/22: no strict liability for the result). -/
opaque WylacznieOkolicznosciNiezalezne : Sprawa → Prop

/-- Prospective coercive (preventive) purpose rather than punitive repression for
    purely historical breaches (I Co 780/15; VIII Cz 220/13; III CZP 76/22). -/
opaque CelPrzymuszajacy : Sprawa → Prop

instance (s : Sprawa) : UstalenieFaktyczne (NaruszenieNastapilo s) where
  reason    := "Czy doszło do niewykonania lub niewłaściwego wykonania obowiązku (także dorozumianego)"
  authority := .sadOpiekunczy
  dowody    := ["wykaz dat i godzin niezrealizowanych kontaktów", "korespondencja stron", "zeznania świadków", "sprawozdania kuratora"]

instance (s : Sprawa) : UstalenieFaktyczne (ZachowanieDzieckaNiewywolane s) where
  reason    := "Czy odmowa dziecka była samodzielna, bez wpływu osoby sprawującej pieczę (TK SK 3/20; SN III CZP 20/25)"
  authority := .sadOpiekunczy
  dowody    := ["opinia OZSS / biegłych psychologów", "wysłuchanie małoletniego"]

instance (s : Sprawa) : UstalenieFaktyczne (WylacznieOkolicznosciNiezalezne s) where
  reason    := "Czy niewykonania wynikły wyłącznie z okoliczności niezależnych (SN III CZP 87/22)"
  authority := .sadOpiekunczy
  dowody    := ["zaświadczenia lekarskie", "zawiadomienia o przyczynie odwołania kontaktu"]

instance (s : Sprawa) : VaguePL (CelPrzymuszajacy s) where
  reason    := "Funkcja przymuszająca na przyszłość, nie represyjna za przeszłość"
  authority := .sadOpiekunczy
  core      := "naruszenia trwają w chwili orzekania"
  penumbra  := "naruszenia ustały niedawno; istnieje realne ryzyko nawrotu"

-- 3b. Assessment of the Payment Sum (Ocena wysokości sumy)

opaque UwzglednionoSytuacjeMajatkowa : Sprawa → Zlote → Prop
opaque RealnieDolegliwa : Sprawa → Zlote → Prop
opaque Proporcjonalna : Sprawa → Zlote → Prop

instance (s : Sprawa) (k : Zlote) : DiscretionaryPL (UwzglednionoSytuacjeMajatkowa s k) where
  reason      := "art. 598¹⁵ § 1: 'uwzględniając sytuację majątkową tej osoby'"
  authority   := .sadOpiekunczy
  scope       := "oznaczenie wysokości sumy pieniężnej za każde naruszenie"
  constraints := ["dane o dochodach i majątku obowiązanego", "kontrola instancyjna w zażaleniu (SN III CZP 25/13)"]

instance (s : Sprawa) (k : Zlote) : VaguePL (RealnieDolegliwa s k) where
  reason    := "Suma musi stanowić realną dolegliwość przymuszającą do wykonywania obowiązków"
  authority := .sadOpiekunczy
  core      := "kwota odczuwalna w budżecie obowiązanego"
  penumbra  := "osoby o wysokich dochodach lub wielokrotne, uporczywe naruszenia"

instance (s : Sprawa) (k : Zlote) : VaguePL (Proporcjonalna s k) where
  reason    := "Proporcjonalność sumy; pomocnicza wytyczna orzecznicza (nie norma ustawowa): ok. 10% miesięcznego dochodu netto (SO Słupsk IV Cz 235/14)"
  authority := .sadOpiekunczy
  core      := "w typowych sprawach 50–1 000 zł za pojedyncze naruszenie"
  penumbra  := "kwoty wyższe przy znacznych możliwościach majątkowych lub nasilonej uporczywości"

-- 3c. Factors Affecting ONLY the Quantum (Czynniki wyłącznie kwotowe)

/-- Degree of fault of the obliged person. Under SN III CZP 20/25 fault is not a
    prerequisite of admissibility; under VI Cz 1481/16 it is a quantum factor. -/
opaque Zawinione : Sprawa → Prop

/-- Adverse impact of the obliged person's conduct on the child's welfare (quantum factor). -/
opaque SzkodaDlaDobraDziecka : Sprawa → Prop

/-- Contribution of the entitled person to the child's negative attitude.
    Under SN III CZP 20/25 substantial contribution may at most justify reducing the sum
    (art. 598¹⁶ § 1 sentence 2 k.p.c.). -/
opaque PrzyczynienieUprawnionego : Sprawa → Prop

/-- The court accounted for quantum-only factors when fixing the sum `k`. -/
opaque UwzglednionoCzynnikiKwotowe : Sprawa → Zlote → Prop

instance (s : Sprawa) : DiscretionaryPL (Zawinione s) where
  reason      := "Stopień zawinienia wpływa wyłącznie na wysokość sumy (SN III CZP 20/25; VI Cz 1481/16)"
  authority   := .sadOpiekunczy
  scope       := "podwyższenie sumy pieniężnej"
  constraints := ["nie stanowi przesłanki dopuszczalności co do zasady"]

instance (s : Sprawa) : DiscretionaryPL (SzkodaDlaDobraDziecka s) where
  reason      := "Negatywny wpływ naruszeń na dobro dziecka jako kryterium wysokości (VI Cz 1481/16)"
  authority   := .sadOpiekunczy
  scope       := "podwyższenie sumy pieniężnej"
  constraints := ["nie stanowi przesłanki dopuszczalności co do zasady"]

instance (s : Sprawa) : DiscretionaryPL (PrzyczynienieUprawnionego s) where
  reason      := "Istotne przyczynienie się uprawnionego do postawy dziecka (SN III CZP 20/25)"
  authority   := .sadOpiekunczy
  scope       := "ewentualne obniżenie sumy (art. 598¹⁶ § 1 zd. 2 k.p.c.)"
  constraints := ["nie wyłącza wydania postanowienia", "wymaga istotnego stopnia przyczynienia"]

instance (s : Sprawa) (k : Zlote) : DiscretionaryPL (UwzglednionoCzynnikiKwotowe s k) where
  reason      := "Wypadkowa zawinienia, wpływu na dobro dziecka i przyczynienia uprawnionego"
  authority   := .sadOpiekunczy
  scope       := "oznaczenie wysokości sumy"
  constraints := ["kontrola w zażaleniu w obie strony (SN III CZP 25/13)"]

/-- Judicial findings on admissibility resolved in the applicant's favor.
    Deliberately excludes fault, child-welfare reassessment, and applicant contribution
    in accordance with SN III CZP 20/25. -/
structure OcenySadu (s : Sprawa) : Prop where
  naruszenie            : NaruszenieNastapilo s
  nieOdmowaDziecka      : ¬ ZachowanieDzieckaNiewywolane s
  nieOkolicznosciNiezal : ¬ WylacznieOkolicznosciNiezalezne s
  przymus               : CelPrzymuszajacy s

/-- Judicial assessment of the quantum `k`. -/
structure OcenaWysokosci (s : Sprawa) (k : Zlote) : Prop where
  majatek     : UwzglednionoSytuacjeMajatkowa s k
  dolegliwosc : RealnieDolegliwa s k
  proporcja   : Proporcjonalna s k
  czynniki    : UwzglednionoCzynnikiKwotowe s k

/-- Construct a `FormalisationBoundaryPL.boundary` directly from a
    `RequiresHumanDeterminationPL` instance. -/
def granicaZInstancji (P : Prop) [inst : RequiresHumanDeterminationPL P] : FormalisationBoundaryPL P :=
  .boundary inst.reason inst.authority

def granicaNaruszenie (s : Sprawa) : FormalisationBoundaryPL (NaruszenieNastapilo s) :=
  granicaZInstancji _

def granicaProporcja (s : Sprawa) (k : Zlote) : FormalisationBoundaryPL (Proporcjonalna s k) :=
  granicaZInstancji _

-- ============================================================
-- §4  Rules (LegalRule) and Defeaters (Defeats)
-- ============================================================

/-- Stage I: threatening a payment order is admissible in principle and in quantum `k`. -/
def ZagrozenieDopuszczalne (s : Sprawa) (p : Paragraf) (k : Zlote) : Prop :=
  warunkiFormalne s p = true ∧ kwotaNieWykluczonaUstawowo gornaGranica598_15 k ∧
  OcenySadu s ∧ OcenaWysokosci s k

/-- Rule R1 (art. 598¹⁵ § 1 k.p.c.): mandatory threat of payment per breach against
    the custodial person ("sąd opiekuńczy ... zagrozi").
    Note: SO Toruń VIII Cz 681/18 posited judicial discretion despite the statutory
    wording "zagrozi"; the model encodes the literal statutory modality (`.obligatory`). -/
def R1_598_15_p1 : LegalRule (Sprawa × Zlote) where
  id          := "kpc.598-15.1"
  description := "Zagrożenie nakazaniem zapłaty sumy za każde naruszenie (osoba sprawująca pieczę)"
  modality    := .obligatory
  priority    := { level := 1, source := "statute" }
  conclusion  := fun ⟨s, k⟩ => ZagrozenieDopuszczalne s .p1 k
  defeatedBy  := ["TK.SK-3/20", "okolicznosc-niezalezna", "brak-celu-przymuszajacego"]

/-- Rule R2 (art. 598¹⁵ § 2 k.p.c.): mandatory threat of payment per breach against
    the person entitled to contact or prohibited from contact. -/
def R2_598_15_p2 : LegalRule (Sprawa × Zlote) where
  id          := "kpc.598-15.2"
  description := "Zagrożenie wobec uprawnionego do kontaktu lub osoby, której kontaktu zakazano"
  modality    := .obligatory
  priority    := { level := 1, source := "statute" }
  conclusion  := fun ⟨s, k⟩ => ZagrozenieDopuszczalne s .p2 k
  defeatedBy  := ["okolicznosc-niezalezna", "brak-celu-przymuszajacego"]

def defeat_TK_SK_3_20 : Defeats where
  defeater := "TK.SK-3/20"
  defeated := "kpc.598-15.1"
  reason   := "Wyłączenie dotyczy wyłącznie zachowania dziecka NIEWYWOŁANEGO przez osobę sprawującą pieczę; współprzyczynienie obojga rodziców nie wyłącza sankcji (SN III CZP 20/25)"
  strict   := true

def defeat_okolicznoscNiezalezna : Defeats where
  defeater := "okolicznosc-niezalezna"
  defeated := "kpc.598-15.1"
  reason   := "Choroba dziecka lub inne okoliczności niezależne — brak absolutnej odpowiedzialności za rezultat (SN III CZP 87/22)"
  strict   := true

def defeat_brakPrzymusu : Defeats where
  defeater := "brak-celu-przymuszajacego"
  defeated := "kpc.598-15.1"
  reason   := "Środek ma charakter przymuszający na przyszłość, nie represyjny za ustałe naruszenia (I Co 780/15; VIII Cz 220/13)"
  strict   := false

-- ============================================================
-- §5  Stage II — art. 598¹⁶ and art. 598²⁰ k.p.c.
-- ============================================================

/-- Art. 598¹⁶ § 1 k.p.c.: „Jeżeli osoba, której sąd opiekuńczy zagroził nakazaniem
    zapłaty oznaczonej sumy pieniężnej, nie wypełnia nadal swego obowiązku, sąd
    opiekuńczy nakazuje jej zapłatę należnej sumy pieniężnej, ustalając jej
    wysokość stosownie do liczby naruszeń. Sąd może w wyjątkowych wypadkach
    zmienić wysokość sumy pieniężnej, o której mowa w art. 598¹⁵, ze względu na
    zmianę okoliczności.”
    § 3: „Na postanowienie sądu przysługuje zażalenie.”
    § 4: „Prawomocne postanowienie sądu, w którym nakazano zapłatę należnej sumy
    pieniężnej, jest tytułem wykonawczym bez potrzeby nadawania mu klauzuli
    wykonalności.” -/
def naleznosc (liczbaNaruszen : Nat) (sumaZaNaruszenie : Zlote) : Zlote :=
  liczbaNaruszen * sumaZaNaruszenie

/-- Single scheduled contact slot after the threat order, with judicial findings. -/
structure Termin where
  opis                  : String
  kontaktZrealizowany   : Bool
  /-- Judicial finding: non-performance resulted from an independent circumstance (SN III CZP 87/22). -/
  okolicznoscNiezalezna : Bool
  deriving Repr, BEq, DecidableEq

/-- A contact date counts as a breach only if contact did not take place and
    was not excused by an independent circumstance. -/
def jestNaruszeniem (t : Termin) : Bool := !t.kontaktZrealizowany && !t.okolicznoscNiezalezna

def liczNaruszenia (ts : List Termin) : Nat := (ts.filter jestNaruszeniem).length

opaque WyjatkowaZmianaOkolicznosci : Sprawa → Prop
instance (s : Sprawa) : DiscretionaryPL (WyjatkowaZmianaOkolicznosci s) where
  reason      := "art. 598¹⁶ § 1 zd. 2 k.p.c. (w tym istotne przyczynienie uprawnionego — SN III CZP 20/25)"
  authority   := .sadOpiekunczy
  scope       := "zmiana wysokości sumy pieniężnej w wyjątkowych wypadkach"
  constraints := ["zmiana okoliczności po wydaniu zagrożenia", "wyjątkowość wypadku"]

opaque NaruszeniaPoZagrozeniuUstalone : Sprawa → Nat → Prop
instance (s : Sprawa) (n : Nat) : UstalenieFaktyczne (NaruszeniaPoZagrozeniuUstalone s n) where
  reason    := "Ustalenie liczby naruszeń, które nastąpiły PO doręczeniu postanowienia o zagrożeniu"
  authority := .sadOpiekunczy
  dowody    := ["harmonogram kontaktów", "protokoły wysłuchania", "korespondencja stron"]

/-- Stage I threat order (wydane zagrożenie nakazaniem zapłaty). -/
structure Zagrozenie where
  sprawa   : Sprawa
  paragraf : Paragraf
  suma     : Zlote
  podstawa : ZagrozenieDopuszczalne sprawa paragraf suma

/-- Art. 598²⁰ k.p.c.: „Sąd umarza postępowanie, jeżeli w ciągu sześciu miesięcy od
    uprawomocnienia ostatniego postanowienia nie wpłynął kolejny wniosek
    w sprawach wykonywania kontaktów z dzieckiem.” -/
def terminArt598_20 : Nat := 6

/-- Stage II payment order (nakaz zapłaty należnej sumy pieniężnej).
    Prerequisites (SN III CZP 29/24, III CZP 25/13):
    prior threat order remaining in force, separate application (art. 598¹⁸ § 1 sentence 2),
    application filed within 6 months (art. 598²⁰), and continued breaches after the threat. -/
structure NakazZaplaty where
  zagrozenie        : Zagrozenie
  zagrozenieWMocy   : Bool
  hWMocy            : zagrozenieWMocy = true
  wniosekOdrebny    : Bool
  hWniosek          : wniosekOdrebny = true
  miesiaceDoWniosku : Nat
  hArt598_20        : miesiaceDoWniosku ≤ terminArt598_20
  terminy           : List Termin
  nadalNiewypelnia  : 0 < liczNaruszenia terminy
  ustalenie         : NaruszeniaPoZagrozeniuUstalone zagrozenie.sprawa (liczNaruszenia terminy)
  kwota             : Zlote
  kwotaZgodna       : kwota = naleznosc (liczNaruszenia terminy) zagrozenie.suma ∨
                      WyjatkowaZmianaOkolicznosci zagrozenie.sprawa

-- ============================================================
-- §6  Prospective Threats Without Prior Breach (art. 582¹ § 3, art. 756²)
-- ============================================================

/-- Statutory basis for threatening a payment order:
    - `art598_15`: enforcement proceeding (requires an already established breach);
    - `art582_1_p3`: included in the contact order itself upon "justified fear of breach";
    - `art756_2`: interim measure (zabezpieczenie). -/
inductive PodstawaZagrozenia where
  | art598_15
  | art582_1_p3
  | art756_2
  deriving Repr, BEq, DecidableEq

def wymagaStwierdzonegoNaruszenia : PodstawaZagrozenia → Bool
  | .art598_15 => true
  | _          => false

/-- Statutory modality: "zagrozi" (art. 598¹⁵) vs "może zagrozić" (art. 582¹ § 3, art. 756²).
    II Cz 484/15: under art. 756² the threat is discretionary ("fakultatywne, ale nie dowolne"). -/
def modalnosc : PodstawaZagrozenia → Deontic
  | .art598_15 => .obligatory
  | _          => .permitted

opaque UzasadnionaObawa : Sprawa → Prop
instance (s : Sprawa) : VaguePL (UzasadnionaObawa s) where
  reason    := "art. 582¹ § 3 k.p.c.: 'uzasadniona obawa naruszenia obowiązków'"
  authority := .sadOpiekunczy
  core      := "uprzednie utrudnianie kontaktów lub zapowiedzi niewykonywania orzeczenia"
  penumbra  := "sam ogólny konflikt między rodzicami (por. SO Sieradz I Ca 83/15 — odmowa zagrożenia)"

-- ============================================================
-- §7  Formally Verified Theorems (Twierdzenia)
-- ============================================================

/-- T1. Art. 598¹⁵ imposes no statutory upper bound on any positive sum. -/
theorem brak_gornej_granicy (k : Zlote) (hk : 0 < k) :
    kwotaNieWykluczonaUstawowo gornaGranica598_15 k :=
  ⟨hk, trivial⟩

/-- T2. A sum of 5,000 PLN per breach is not statutorily excluded under art. 598¹⁵. -/
theorem piec_tysiecy_nie_wykluczone :
    kwotaNieWykluczonaUstawowo gornaGranica598_15 5000 :=
  brak_gornej_granicy 5000 (by decide)

/-- T3. Contrast with art. 1052 k.p.c. (15,000 PLN cap): 20,000 PLN is excluded by
    art. 1052 but permitted by the statutory range of art. 598¹⁵. -/
theorem kontrast_1052 :
    ¬ kwotaNieWykluczonaUstawowo gornaGranica1052 20000 ∧
      kwotaNieWykluczonaUstawowo gornaGranica598_15 20000 := by
  refine ⟨?_, brak_gornej_granicy 20000 (by decide)⟩
  intro ⟨_, h⟩
  simp [gornaGranica1052] at h

/-- T4. "Za każde naruszenie": total payment due grows linearly with each breach. -/
theorem naleznosc_za_kazde_naruszenie (n : Nat) (s : Zlote) :
    naleznosc (n + 1) s = naleznosc n s + s := by
  simp [naleznosc, Nat.succ_mul]

/-- T5. Arithmetic check: 3 breaches at 5,000 PLN = 15,000 PLN. -/
theorem trzy_naruszenia_po_5000 : naleznosc 3 5000 = 15000 := by decide

/-- T6. Zero breaches yield zero payment due. -/
theorem zero_naruszen (s : Zlote) : naleznosc 0 s = 0 := by simp [naleznosc]

/-- T7. Payment due is monotonic in the number of breaches. -/
theorem naleznosc_monotoniczna (n m : Nat) (s : Zlote) (h : n ≤ m) :
    naleznosc n s ≤ naleznosc m s := Nat.mul_le_mul_right s h

/-- T8. A Stage II payment order requires a valid Stage I threat order (SN III CZP 25/13). -/
theorem nakaz_wymaga_zagrozenia (n : NakazZaplaty) :
    ZagrozenieDopuszczalne n.zagrozenie.sprawa n.zagrozenie.paragraf n.zagrozenie.suma :=
  n.zagrozenie.podstawa

/-- T9. A Stage II payment order requires at least one breach after the threat ("nie wypełnia nadal"). -/
theorem nakaz_wymaga_dalszego_naruszenia (n : NakazZaplaty) : liczNaruszenia n.terminy ≠ 0 :=
  Nat.pos_iff_ne_zero.mp n.nadalNiewypelnia

/-- T10. Without an exceptional change of circumstances, the payment order equals
    (number of breaches) × (threatened sum per breach). -/
theorem kwota_nakazu (n : NakazZaplaty) (h : ¬ WyjatkowaZmianaOkolicznosci n.zagrozenie.sprawa) :
    n.kwota = naleznosc (liczNaruszenia n.terminy) n.zagrozenie.suma :=
  n.kwotaZgodna.resolve_right h

/-- T10a. Stage II requires the threat order to remain in force (SN III CZP 29/24). -/
theorem nakaz_wymaga_mocy_zagrozenia (n : NakazZaplaty) : n.zagrozenieWMocy = true := n.hWMocy

/-- T10b. Stage II requires a separate application (art. 598¹⁸ § 1 sentence 2). -/
theorem nakaz_wymaga_odrebnego_wniosku (n : NakazZaplaty) : n.wniosekOdrebny = true := n.hWniosek

/-- T10c. Art. 598²⁰: after 6 months without a new motion, a Stage II order cannot issue. -/
theorem po_szesciu_miesiacach_brak_nakazu (n : NakazZaplaty) (h : 6 < n.miesiaceDoWniosku) : False := by
  have := n.hArt598_20
  simp [terminArt598_20] at this
  omega

/-- T10d. A missed contact date excused by an independent circumstance does not
    increase the breach count (SN III CZP 87/22). -/
theorem okolicznosc_niezalezna_nie_liczy (t : Termin) (ts : List Termin)
    (h : t.okolicznoscNiezalezna = true) : liczNaruszenia (t :: ts) = liczNaruszenia ts := by
  simp [liczNaruszenia, List.filter, jestNaruszeniem, h]

/-- T10e. Abstract illustration: 4 unrealized contact dates, one excused by the child's
    illness, and 1 realized contact date ⇒ 3 breaches ⇒ 15,000 PLN at 5,000 PLN/breach. -/
def terminyIlustracja : List Termin :=
  [ ⟨"termin A (hipotetyczny)", false, false⟩,
    ⟨"termin B (hipotetyczny) — choroba dziecka", false, true⟩,
    ⟨"termin C (hipotetyczny)", false, false⟩,
    ⟨"termin D (hipotetyczny)", false, false⟩,
    ⟨"termin E (hipotetyczny) — kontakt zrealizowany", true, false⟩ ]

theorem ilustracja_choroba : liczNaruszenia terminyIlustracja = 3 ∧
    naleznosc (liczNaruszenia terminyIlustracja) 5000 = 15000 := by decide

/-- T11. Lack of an application precludes a threat order (art. 598¹⁸ § 1). -/
theorem brak_wniosku_wyklucza (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : s.wniosekZlozony = false) : ¬ ZagrozenieDopuszczalne s p k := by
  intro ⟨hf, _, _⟩
  simp [warunkiFormalne, h] at hf

/-- T12. Lack of an enforceable contact title precludes a threat order (art. 598¹⁹ § 1). -/
theorem brak_tytulu_wyklucza (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : tytulKwalifikowany s.tytul = false) : ¬ ZagrozenieDopuszczalne s p k := by
  intro ⟨hf, _, _⟩
  simp [warunkiFormalne, h] at hf

/-- T13. Art. 598¹⁵ § 1 applies exclusively to the custodial person (`Rola.piecza`). -/
theorem p1_tylko_piecza (s : Sprawa) (k : Zlote) (h : s.obowiazany ≠ .piecza) :
    ¬ ZagrozenieDopuszczalne s .p1 k := by
  intro ⟨hf, _, _⟩
  cases ho : s.obowiazany <;> simp_all [warunkiFormalne, rolaZgodna]

/-- T14. TK SK 3/20: a finding that the child's refusal was autonomous and not induced
    by the custodial person precludes a threat order. -/
theorem odmowa_dziecka_wyklucza (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : ZachowanieDzieckaNiewywolane s) : ¬ ZagrozenieDopuszczalne s p k :=
  fun ⟨_, _, o, _⟩ => o.nieOdmowaDziecka h

/-- T14a. SN III CZP 87/22: breaches caused exclusively by independent circumstances
    preclude a threat order. -/
theorem okolicznosci_niezalezne_wykluczaja (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : WylacznieOkolicznosciNiezalezne s) : ¬ ZagrozenieDopuszczalne s p k :=
  fun ⟨_, _, o, _⟩ => o.nieOkolicznosciNiezal h

/-- T15. Lack of prospective coercive purpose precludes a threat order
    (I Co 780/15; VIII Cz 220/13). -/
theorem brak_przymusu_wyklucza (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : ¬ CelPrzymuszajacy s) : ¬ ZagrozenieDopuszczalne s p k :=
  fun ⟨_, _, o, _⟩ => h o.przymus

/-- T15a. Under art. 598¹⁵ an established breach is required (SN III CZP 25/13; VIII Cz 220/13). -/
theorem zagrozenie_wymaga_naruszenia (s : Sprawa) (p : Paragraf) (k : Zlote)
    (h : ZagrozenieDopuszczalne s p k) : NaruszenieNastapilo s := h.2.2.1.naruszenie

/-- T15b. Prospective tracks (art. 582¹ § 3 and art. 756²) do not require a prior breach
    and are permissive (`.permitted`), whereas art. 598¹⁵ requires a prior breach and
    is mandatory (`.obligatory`). -/
theorem sciezki_pro_futuro :
    wymagaStwierdzonegoNaruszenia .art598_15 = true ∧
    wymagaStwierdzonegoNaruszenia .art582_1_p3 = false ∧
    wymagaStwierdzonegoNaruszenia .art756_2 = false ∧
    modalnosc .art598_15 = .obligatory ∧ modalnosc .art582_1_p3 = .permitted ∧
    modalnosc .art756_2 = .permitted := by decide

/-- T16. Statutory modality of § 1 and § 2 is obligatory ("zagrozi"). -/
theorem p1_obligatoryjny : R1_598_15_p1.modality = .obligatory := rfl
theorem p2_obligatoryjny : R2_598_15_p2.modality = .obligatory := rfl

/-- T17 (Main admissibility theorem). Formal prerequisites ∧ k > 0 ∧ admissibility
    findings ∧ quantum assessment ⇒ threat order is admissible. -/
theorem zagrozenie_dopuszczalne (s : Sprawa) (p : Paragraf) (k : Zlote)
    (hf : warunkiFormalne s p = true) (hk : 0 < k) (zasada : OcenySadu s)
    (wysokosc : OcenaWysokosci s k) : ZagrozenieDopuszczalne s p k :=
  ⟨hf, brak_gornej_granicy k hk, zasada, wysokosc⟩

/-- T17a (SN III CZP 20/25). Fault, harm to child welfare, and contribution by the
    entitled person do not affect admissibility in principle: the threat remains
    admissible even if fault is absent, no harm is shown, and the entitled person
    contributed to the situation. -/
theorem dopuszczalnosc_niezalezna_od_winy (s : Sprawa) (p : Paragraf) (k : Zlote)
    (hf : warunkiFormalne s p = true) (hk : 0 < k) (zasada : OcenySadu s)
    (wysokosc : OcenaWysokosci s k)
    (_brakWiny : ¬ Zawinione s) (_brakSzkody : ¬ SzkodaDlaDobraDziecka s)
    (_przyczynienie : PrzyczynienieUprawnionego s) :
    ZagrozenieDopuszczalne s p k :=
  zagrozenie_dopuszczalne s p k hf hk zasada wysokosc

/-- T17b. Admissibility in principle is invariant across all positive sums: changing
    the sum `k` to `k' > 0` requires only a new quantum assessment `OcenaWysokosci s k'`. -/
theorem zasada_niezalezna_od_kwoty (s : Sprawa) (p : Paragraf) (k k' : Zlote)
    (h : ZagrozenieDopuszczalne s p k) (hk' : 0 < k') (w : OcenaWysokosci s k') :
    ZagrozenieDopuszczalne s p k' :=
  ⟨h.1, brak_gornej_granicy k' hk', h.2.2.1, w⟩

-- ============================================================
-- §8  Scope of Appellate Review on Zażalenie (SN III CZP 25/13)
-- ============================================================

/-- Issues reviewable on appeal (zażalenie) under art. 598¹⁵ § 3 k.p.c.
    per SN III CZP 25/13: validity of the threat, failure to issue a threat,
    and correctness of the determined payment sum. -/
inductive PrzedmiotZazalenia where
  | prawidlowoscZagrozenia
  | brakZagrozenia
  | wysokoscSumy
  deriving Repr, BEq, DecidableEq

def objeteZazaleniem : PrzedmiotZazalenia → Bool := fun _ => true

inductive KierunekZmiany where
  | podwyzszenie
  | obnizenie
  deriving Repr, BEq, DecidableEq

/-- Appellate review of the quantum operates in both directions (increase or reduction). -/
def dopuszczalnaZmianaWZazaleniu : KierunekZmiany → Bool := fun _ => true

theorem wysokosc_zaskarzalna_w_obie_strony :
    objeteZazaleniem .wysokoscSumy = true ∧
    dopuszczalnaZmianaWZazaleniu .podwyzszenie = true ∧
    dopuszczalnaZmianaWZazaleniu .obnizenie = true := by decide

-- ============================================================
-- §9  Two-Stage Decision Procedure as `FormalisationBoundary.mixed`
-- ============================================================

/-- Formal input for Stage I (art. 598¹⁵ k.p.c.).
    Fields `zawinienie` and `przyczynienieUprawnionego` are included in the input
    record, but — in accordance with SN III CZP 20/25 — do not affect the formal
    admissibility decision (`etapI_niezalezny_od_winy`). -/
structure WejscieEtapI where
  sprawa                    : Sprawa
  paragraf                  : Paragraf
  /-- Whether the application alleges specific breaches; their occurrence is determined by the court. -/
  naruszenieZarzucone       : Bool
  zawinienie                : Option Bool
  przyczynienieUprawnionego : Option Bool
  deriving Repr, BEq, DecidableEq

/-- Formal input for Stage II (art. 598¹⁶ k.p.c.). -/
structure WejscieEtapII where
  etapI                     : WejscieEtapI
  zagrozenieWydane          : Bool
  /-- SN III CZP 29/24: the threat order must remain in force. -/
  zagrozenieWMocy           : Bool
  /-- Art. 598¹⁸ § 1 sentence 2: separate application for Stage II. -/
  wniosekOdrebny            : Bool
  /-- Art. 598²⁰: full months elapsed since the last order became final. -/
  miesiaceOdUprawomocnienia : Nat
  /-- "nie wypełnia nadal" — further breaches alleged after the threat order. -/
  dalszeNaruszeniaZarzucone : Bool
  deriving Repr, BEq, DecidableEq

/-- Decidable formal admissibility check for Stage I. -/
def dopuszczalnyEtapI (w : WejscieEtapI) : Bool :=
  warunkiFormalne w.sprawa w.paragraf && w.naruszenieZarzucone

/-- Decidable formal admissibility check for Stage II. -/
def dopuszczalnyEtapII (w : WejscieEtapII) : Bool :=
  dopuszczalnyEtapI w.etapI && w.zagrozenieWydane && w.zagrozenieWMocy &&
  w.wniosekOdrebny && decide (w.miesiaceOdUprawomocnienia ≤ terminArt598_20) &&
  w.dalszeNaruszeniaZarzucone

def czescFormalnaEtapI : String :=
  "Sprawdzone maszynowo: wykonalny tytuł w przedmiocie kontaktów (art. 598¹⁹ § 1), rola " ++
  "obowiązanego zgodna z § 1/§ 2, wniosek (art. 598¹⁸ § 1), odpis tytułu, " ++
  "wysłuchanie uczestników (art. 598¹⁸ § 2), zarzucone naruszenie; zawinienie " ++
  "nie jest przesłanką dopuszczalności (SN III CZP 20/25)."

def czescSadowaEtapI : String :=
  powodPL .sadOpiekunczy
    ("Do oceny sądu: (1) czy naruszenia nastąpiły i trwają (także obowiązki " ++
     "dorozumiane — SN III CZP 87/22, III CZP 76/22); (2) wyłączenie TK SK 3/20 " ++
     "(postawa dziecka niewywołana przez osobę sprawującą pieczę) oraz " ++
     "okoliczności niezależne; (3) WYSOKOŚĆ sumy: art. 598¹⁵ § 1 — sytuacja " ++
     "majątkowa; wytyczna ok. 10% dochodu netto (SO Słupsk IV Cz 235/14, " ++
     "niewiążąca ustawowo); brak górnej granicy w art. 598¹⁵ (limit 15 000 zł " ++
     "w art. 1052 k.p.c.); (4) zawinienie i przyczynienie uprawnionego — " ++
     "wyłącznie przy wymiarze sumy (SN III CZP 20/25; VI Cz 1481/16).")

def czescFormalnaEtapII : String :=
  czescFormalnaEtapI ++ " Ponadto: zagrożenie wydane i pozostające w mocy " ++
  "(SN III CZP 29/24), odrębny wniosek (art. 598¹⁸ § 1 zd. 2), wniosek przed " ++
  "upływem 6 miesięcy (art. 598²⁰), zarzucone dalsze naruszenia po zagrożeniu."

def czescSadowaEtapII : String :=
  powodPL .sadOpiekunczy
    ("Do oceny sądu: liczba naruszeń PO doręczeniu zagrożenia (należność = liczba " ++
     "× suma, art. 598¹⁶ § 1 zd. 1); wyjątkowa zmiana wysokości ze względu na " ++
     "zmianę okoliczności, w tym istotne przyczynienie uprawnionego (art. 598¹⁶ " ++
     "§ 1 zd. 2; SN III CZP 20/25); okoliczności niezależne przy poszczególnych " ++
     "terminach (SN III CZP 87/22).")

/-- Stage I decision procedure: art. 598¹⁵ k.p.c. — threat of payment. -/
def rozstrzygnijEtapI (w : WejscieEtapI) : FormalisationBoundary Prop :=
  if dopuszczalnyEtapI w then .mixed czescFormalnaEtapI czescSadowaEtapI
  else .formal False

/-- Stage II decision procedure: art. 598¹⁶ k.p.c. — order to pay. -/
def rozstrzygnijEtapII (w : WejscieEtapII) : FormalisationBoundary Prop :=
  if dopuszczalnyEtapII w then .mixed czescFormalnaEtapII czescSadowaEtapII
  else .formal False

/-- Helper predicate: a `FormalisationBoundary Prop` value is of constructor `.mixed`. -/
def JestMixed (b : FormalisationBoundary Prop) : Prop :=
  ∃ f h, b = FormalisationBoundary.mixed f h

/-- M1. For every formally admissible Stage I input, the outcome is `.mixed`:
    the formal model never usurps the court's factual and quantum determinations. -/
theorem etapI_zawsze_mixed (w : WejscieEtapI) (h : dopuszczalnyEtapI w = true) :
    JestMixed (rozstrzygnijEtapI w) :=
  ⟨czescFormalnaEtapI, czescSadowaEtapI, by simp [rozstrzygnijEtapI, h]⟩

/-- M2. For every formally admissible Stage II input, the outcome is `.mixed`. -/
theorem etapII_zawsze_mixed (w : WejscieEtapII) (h : dopuszczalnyEtapII w = true) :
    JestMixed (rozstrzygnijEtapII w) :=
  ⟨czescFormalnaEtapII, czescSadowaEtapII, by simp [rozstrzygnijEtapII, h]⟩

/-- M3. When Stage II is formally admissible, both Stage I and Stage II produce `.mixed`. -/
theorem decyzja_zawsze_mixed (w : WejscieEtapII) (h : dopuszczalnyEtapII w = true) :
    JestMixed (rozstrzygnijEtapI w.etapI) ∧ JestMixed (rozstrzygnijEtapII w) := by
  refine ⟨etapI_zawsze_mixed _ ?_, etapII_zawsze_mixed _ h⟩
  simp only [dopuszczalnyEtapII, Bool.and_eq_true] at h
  exact h.1.1.1.1.1

/-- M4. Stage I returns exclusively either machine-verified rejection (`.formal False`)
    or `.mixed` (never an unguarded `.formal True`). -/
theorem etapI_tylko_odrzucenie_albo_mixed (w : WejscieEtapI) :
    rozstrzygnijEtapI w = .formal False ∨ JestMixed (rozstrzygnijEtapI w) := by
  by_cases h : dopuszczalnyEtapI w = true
  · exact Or.inr (etapI_zawsze_mixed w h)
  · left; simp [rozstrzygnijEtapI, h]

/-- M5 (SN III CZP 20/25). Fault and applicant contribution do not alter the
    Stage I boundary classification for any input. -/
theorem etapI_niezalezny_od_winy (w : WejscieEtapI) (z p : Option Bool) :
    rozstrzygnijEtapI { w with zawinienie := z, przyczynienieUprawnionego := p } =
      rozstrzygnijEtapI w := rfl

/-- M6 (art. 598²⁰). After 6 months of inactivity, Stage II is rejected automatically. -/
theorem etapII_po_szesciu_miesiacach (w : WejscieEtapII)
    (h : terminArt598_20 < w.miesiaceOdUprawomocnienia) :
    rozstrzygnijEtapII w = .formal False := by
  have h' : ¬ (w.miesiaceOdUprawomocnienia ≤ terminArt598_20) := by omega
  simp [rozstrzygnijEtapII, dopuszczalnyEtapII, h']

/-- M7 (SN III CZP 29/24). If the Stage I threat is no longer in force, Stage II is
    rejected automatically. -/
theorem etapII_wymaga_mocy (w : WejscieEtapII) (h : w.zagrozenieWMocy = false) :
    rozstrzygnijEtapII w = .formal False := by
  simp [rozstrzygnijEtapII, dopuszczalnyEtapII, h]

/-- M8. Stage II cannot be formally admissible if Stage I is formally inadmissible. -/
theorem etapII_wymaga_etapuI (w : WejscieEtapII) (h : dopuszczalnyEtapI w.etapI = false) :
    rozstrzygnijEtapII w = .formal False := by
  simp [rozstrzygnijEtapII, dopuszczalnyEtapII, h]

end PolishLawLean.KPC.Art598_15
