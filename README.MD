# InterSystems IRIS: A First Look

An [Instruqt](https://instruqt.com/) hands-on lab giving a whistle-stop tour of InterSystems IRIS as a data platform. Target audience: technically literate but IRIS-naive — developers, architects, or evaluators who want a quick feel for the platform.

**Track slug:** `intro-to-iris`  
**Owner:** intersystems  
**Time limit:** 60 minutes  
**Sandbox preset:** `iris-data-platform`

---

## Narrative thread

A single fictional product — "Gummy Rings" (SKU `SKU-976`) — is followed across four IRIS surfaces to show that SQL, code, interoperability, and analytics all operate on the same live data.

| Challenge | Title | What learners do |
|---|---|---|
| 1 | Welcome to InterSystems IRIS | Tour the Management Portal |
| 2 | Data Platform | Run SQL, insert Gummy Rings at $2.99 |
| 3 | Execution Engine | Restock via ObjectScript + Embedded Python, verify via SQL |
| 4 | Integration Layer | Submit a web order, trace it through an IRIS production, trigger an email |
| 5 | Real Time Analytics | Watch the order appear live in the BI dashboard |
| 6 | Conclusion | Links to further learning |

---

## Local development

IRIS runs via Docker Compose:

```bash
docker compose up -d
```

IRIS is mapped to `http://localhost:52773`. Credentials: `SuperUser` / `SYS`.

The sandbox uses the `iris-data-platform` preset which pre-loads the HoleFoods sample dataset (products, sales transactions, BI cubes and dashboards) into the `USER` namespace.

---

## Repository structure

```
track.yml                        # Instruqt track definition
docker-compose.yml               # Local dev environment
01-challenge-1/                  # Welcome / Management Portal
  assignment.md
  setup-iris                     # Imports HoleFoods classes into IRIS
02-challenge-2/                  # Data Platform (SQL)
  assignment.md
03-challenge-3/                  # Execution Engine (ObjectScript + Python)
  assignment.md
  setup-vscode                   # Writes ProductChanges.cls, configures VS Code
04-challenge-4/                  # Integration Layer
  assignment.md
  setup-iris                     # Builds the interoperability production
05-challenge-5/                  # Real Time Analytics (IRIS BI)
  assignment.md
06-challenge-6/                  # Conclusion / further links
  assignment.md
introp_plan.md                   # Design spec for the interop challenge
assets/                          # Screenshots used in assignment.md files
```

---

## Key dataset tables (`USER` namespace)

| Table | Contents |
|---|---|
| `HoleFoods.Product` | Products: SKU, Name, Category, Price, Stock |
| `HoleFoods.SalesTransaction` | Sales records linked to Product and Outlet |
| `HoleFoods.Outlet` / `Country` / `Region` | Geography |
| `HoleFoods.Cube` / `BudgetCube` | DeepSee BI cube definitions |

---

## Challenge 3 — ProductChanges class

`setup-vscode` writes `/opt/intersystems/src/exercise-3/HoleFoods/ProductChanges.cls` with:

- `PrintProductDetails(pSKU)` — ObjectScript, prints product details by SKU
- `Restock(pSKU, pQty)` — Embedded Python, increments stock and saves

---

## Challenge 4 — Integration production

The production (`HoleFoods.Interop.Production`) connects:

1. `FromWeb` — REST Business Service receiving orders from `/csp/user/order.html`
2. `ToOrderProcessor` — Business Operation that looks up the SKU, checks stock, writes a `SalesTransaction`
3. `ToEmail` — Business Operation (added by the learner during the challenge) that sends an order confirmation email via MailHog

---

## Further resources

- [InterSystems Learning Portal](https://learning.intersystems.com/)
- [InterSystems Developer Hub](https://developer.intersystems.com)
- [Developer Community](https://community.intersystems.com)
- [Open Exchange](https://openexchange.intersystems.com/)
