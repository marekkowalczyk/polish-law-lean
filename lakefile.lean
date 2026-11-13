import Lake
open Lake DSL

package «PolishLawLean» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

require «legal-lean» from git
  "https://github.com/marekkowalczyk/legal-lean" @ "cursor/fix-lake-build-and-ci-6b7e"

@[default_target]
lean_lib «PolishLawLean» where
  roots := #[`PolishLawLean]
