# Intro to IRIS - Instruqt Track

## What this is

A work-in-progress Instruqt tutorial track giving a whistle-stop tour of InterSystems IRIS as a data platform. The target audience is technically literate but IRIS-naive — developers, architects, or evaluators who want a quick feel for what IRIS can do.

The track runs on the `iris-data-platform` sandbox preset. IRIS runs at `http://iris:52773`, credentials `SuperUser`/`SYS`. VS Code runs at `http://vscode:8080`.

---

## Narrative thread

A single data point — a fictional product "Gummy Rings" (SKU `SKU-976`) — is followed across four IRIS surfaces to show that SQL, code, interoperability, and analytics all operate on the same live data, not separate silos.

1. **SQL** (challenge 2): Insert Gummy Rings at $2.99, explore the HoleFoods relational schema
2. **Code** (challenge 3): Drop the price to $1.99 using ObjectScript + Embedded Python, verify via SQL
3. **Interop** (challenge 4): Submit a web order form, watch it route through an IRIS production, get a status response back
4. **Analytics** (challenge 5): View the HoleFoods BI dashboard; the sale from step 3 is live in the data

---

## Track structure

```
track.yml                                  # sandbox preset: iris-data-platform
01-challenge-1/ ... 06-challenge-6/        # One dir per challenge (slug in assignment.md frontmatter, e.g. challenge-4)
  assignment.md
  setup-*, check-*, solve-*                # Per-challenge bash scripts (suffix = target host: -iris or -vscode)
src/                                       # HoleFoods classes (src/HoleFoods/...) and web pages (order.html etc.)
assets/                                    # Images used by assignment.md
tests/                                     # Local check-script tests (run-all.sh, test-challenge-N.sh, helpers.sh)
Dockerfile, docker-compose.yml, setup.sh   # Local dev: runs the track scripts against a local IRIS container
```

Challenges: 1 Welcome / Management Portal tour, 2 SQL / Data Platform, 3 Execution Engine (VS Code), 4 Integration Layer (interop), 5 Real Time Analytics (IRIS BI), 6 Well Done.

---

## HoleFoods dataset

Pre-loaded sample data from the InterSystems SamplesBI project. Key tables (all in the `USER` namespace):

- `HoleFoods.Product` — products with `SKU`, `Name`, `Category`, `Price`. A `Stock` column needs adding for the interop challenge.
- `HoleFoods.SalesTransaction` — sales records linked to Product and Outlet
- `HoleFoods.Outlet`, `HoleFoods.Country`, `HoleFoods.Region` — geography
- `HoleFoods.Cube` / `HoleFoods.BudgetCube` — DeepSee BI cube definitions
- Dashboards and pivots are defined in `HoleFoods.DashboardsEtc`

The sandbox does NOT use the local `src/` directly. `01-challenge-1/setup-iris` downloads the GitHub tarball of `intersystems-community/intro-to-iris-instruqt` (branch `main`) into `/home/irisowner/intro-to-iris-instruqt`, and later setup scripts import `src/HoleFoods` and copy the `src/*.html` pages from that download. Edits to `src/` only reach the sandbox once pushed to GitHub `main` (separately from the Instruqt track sync). Check/solve/setup scripts come from the track itself. The user pushes; never push.

---

## Challenge 3 — what exists

`setup-vscode` writes `/opt/intersystems/src/challenge-3/Intro/ProductChanges.cls` with two methods:
- `PrintProductDetails(pId)` — ObjectScript, reads and prints a product by SKU
- `ChangeProductPrice(pId, pPrice)` — Embedded Python, updates the price and saves

The learner imports and compiles the class via the VS Code ObjectScript extension, then calls both methods from the terminal.

---

## Challenge 4 — Integration Layer (built)

Classes live in `src/HoleFoods/Interop/` (`Production`, `Setup`, `BS/OrderService`, `BP/OrderRouter`, `BO/ToOrderProcessor`, `BO/ToEmail`, `Msg/OrderRequest`, `REST/OrderDispatch`). `setup-iris` runs `HoleFoods.Interop.Setup.Run()`, copies `src/*.html` to `/usr/irissys/csp/user/`, and patches the interop editor UI for the narrow Instruqt viewport.

Learner flow: submit an order on the Shop tab (`order.html` POSTs to `/api/holeFoods/order`), open the production in the IRIS tab, add an outbound host `ToEmail` (`HoleFoods.Interop.BO.ToEmail`), enable and start it, submit again, read the confirmation in the Mail tab (port 8025).

`check-iris` requires all three: a `SalesTransaction` for `SKU-976`, `ToEmail` running in the production, and an `Ens_Util.Log` row with `ConfigName='ToEmail'` and `SourceMethod='SendMail'`. `solve-iris` reproduces the learner's work: adds `ToEmail` to the production via a class it writes to `/tmp`, then POSTs a real order to the REST endpoint and fails unless `emailSent` is true. Local logic tests for the check live in `tests/test-challenge-4.sh`.

---

## Key conventions

- Setup scripts are bash, run as `irisowner` (challenge 1) or `coder` (challenge 3). Use `su - <user> <<'EOSU' ... EOSU` pattern.
- `iris session` fed by a heredoc cannot run multiline blocks (`if { ... }`, `for { ... }` spanning lines). For anything beyond one-liners, write a class (heredoc to `/tmp/X.cls`), import it with `$system.OBJ.Import(file, "ck")` (`Load` is deprecated), and call its method from a one-line command. See `04-challenge-4/solve-iris`.
- Challenges are numbered by directory prefix; the slug values in `assignment.md` frontmatter are the Instruqt identifiers — do not change them.
- Python (`python3` + `urllib`) is used instead of `curl`/`git` in sandbox scripts; they are not guaranteed to exist.

## Testing (Instruqt auto-test)

Auto-test runs per challenge: setup, check (must FAIL), solve, check (must PASS). Rules learned the hard way:

- Every challenge's `solve-iris` must reproduce what the learner does, so its own `check-iris` passes. An empty solve fails "check expecting success" (challenge 4 failed this way). Challenges 1 has no check/solve (reported NOT IMPLEMENTED).
- A check must fail on the untouched state: never check something an earlier challenge's solve already created. Challenge 4's check looks for `SKU-976` sales, so nothing earlier may place one.
- Solves should drive the same entry points the learner uses (REST endpoint, production config), not write rows directly, and must fail loudly (non-zero exit) if the step did not work.
- Solves must be safe to run twice.
- Local logic tests for check scripts: `tests/run-all.sh`. They inject state directly and do not prove solve scripts work; only an Instruqt auto-test run does.
