# References

> A comprehensive, curated knowledge base for the entire Nix ecosystem — from the
> Nix language and NixOS, through deployment, secrets, networking, containers,
> Kubernetes, monitoring, storage, databases, self-hosted apps, media, security,
> development tooling, CI/CD, cloud providers, real-world configurations, community
> discussions, talks, books, and academic papers.

This document is a long-term curated reference for anyone building a **NixOS
homelab**, self-hosting infrastructure, or crafting a reproducible development
environment. It is organised into fourteen thematic parts. Every entry includes a
title, a link, a concrete description of what it is and *why* you would reach for
it in a homelab, and a set of tags.

## How to use this document

- **Browse by part.** Each part covers a coherent slice of the ecosystem
  (Foundations, Core Tooling, Deployment, Secrets & Networking, …).
- **Read the tags.** Tags such as `#flakes`, `#deployment`, `#secrets`,
  `#homelab` let you cross-reference related tools across parts.
- **Watch the status markers.** Projects that are no longer maintained are marked
  **(Archived)** or **(Deprecated)** in their title, and the description usually
  names the recommended replacement (for example NixOps → Colmena / deploy-rs,
  LXD → Incus, `services.promtail` → Grafana Alloy, `niv` → Flakes).
- **Prefer official sources.** Wherever possible, entries link to the canonical
  upstream (the GitHub repository, the official manual, or
  `search.nixos.org/options` for NixOS module options).

## Resource format

Each resource follows this structure:

```
### Resource Title

**Website**

https://example.com

**Description**

One to four sentences describing what it is, its key features, and the concrete
use case for a NixOS homelab.

**Tags**

`#tag1` `#tag2` `#tag3`
```

## At a glance

- **52** sections across **14** parts
- **669** curated resources
- **45** duplicate links removed during compilation

## Table of Contents

- **Part I — Foundations & Learning**
  1. Official Documentation — *16 resources*
  2. Nix Language — *6 resources*
  3. nix.dev — The Official Learning Hub — *10 resources*
  4. Nix Pills — *6 resources*
  5. Zero to Nix — *4 resources*
- **Part II — Core Tooling**
  6. Nixpkgs — *12 resources*
  7. NixOS — *12 resources*
  8. Home Manager — *8 resources*
  9. Flakes — *7 resources*
  10. Flake Parts — *5 resources*
  11. Search Tools — *6 resources*
- **Part III — Deployment & Provisioning**
  12. Multi-Host Flake Deployment Tools — *4 resources*
  13. Bare-Metal Provisioning & Installation — *2 resources*
  14. Impermanence & Ephemeral Root — *2 resources*
  15. Image Generation & ISO Building — *3 resources*
  16. Infrastructure-as-Code Layer — *1 resource*
  17. Lightweight & Niche Deployment Tools — *5 resources*
  18. ISO / Image Builders (Direct) — *2 resources*
  19. Deployment (Miscellaneous) — *2 resources*
  20. Quick-Reference: Which Tool Should I Pick? — *(decision table)*
- **Part IV — Secrets & Networking**
  21. Secrets Management in NixOS — *16 resources*
  22. Networking on NixOS — *47 resources*
- **Part V — Reverse Proxies & Containers**
  23. Reverse Proxies & TLS Termination on NixOS — *15 resources*
  24. Containers & Virtualisation on NixOS — *29 resources*
- **Part VI — Kubernetes & Monitoring**
  25. Kubernetes on NixOS — *11 resources*
  26. Monitoring (as NixOS Modules) — *28 resources*
- **Part VII — Storage & Databases**
  27. Storage on NixOS — *27 resources*
  28. Databases (as NixOS services) — *19 resources*
- **Part VIII — Self-Hosted Applications & Identity**
  29. Self-Hosted Applications on NixOS — *28 resources*
  30. Identity & Access Management (SSO) on NixOS — *11 resources*
- **Part IX — Media Stack**
  31. Media Servers on NixOS — *13 resources*
  32. Servarr Stack on NixOS — *25 resources*
  33. Nix-Specific Media Projects — *5 resources*
- **Part X — Security & Development**
  34. Security on NixOS — *20 resources*
  35. Development Environments (Nix Dev Tooling) — *24 resources*
- **Part XI — CI/CD & Cloud Providers**
  36. CI/CD for Nix — *29 resources*
  37. Cloud Providers — Deploying NixOS / Nix Images — *12 resources*
- **Part XII — Example Configurations & Community**
  38. Example Configurations — Dotfiles — *15 resources*
  39. Complete Homelabs — *10 resources*
  40. Public Infrastructure Repositories — *11 resources*
  41. Blogs — *16 resources*
  42. Reddit Threads — *21 resources*
  43. NixOS Discourse Discussions — *22 resources*
  44. GitHub Discussions & Issues — *11 resources*
- **Part XIII — Talks, Video, Audio & Miscellaneous**
  45. Conference Talks — *24 resources*
  46. YouTube Channels — *10 resources*
  47. YouTube Playlists & Specific Videos — *13 resources*
  48. Podcasts — *10 resources*
  49. Miscellaneous Resources — *20 resources*
- **Part XIV — Books, Academic Papers & Awesome Lists**
  50. Books — *4 resources*
  51. Academic Papers — *7 resources*
  52. Awesome Lists — *3 resources*

---


---

## Part I — Foundations & Learning

### 1. Official Documentation

The canonical starting points for all NixOS work: the project's main web
presence, the four primary manuals (NixOS, Nixpkgs, Nix, nix.dev), the
community wiki, the RFC process, and the official release communications.

#### NixOS Project Homepage

**Website**

https://nixos.org

**Description**

The official landing page for the entire Nix ecosystem (Nix, NixOS, Nixpkgs,
Nix flakes). It links to downloads, manuals, the community wiki, the blog, and
learning paths. Use it as the canonical entry point when you need to verify that
any Nix-related URL is genuine and current.

**Tags**

`#official` `#landing-page` `#nixos` `#nix`

---

#### NixOS Manual

**Website**

https://nixos.org/manual/nixos/stable/

**Description**

The official reference for installing, using, and extending NixOS as a Linux
distribution. Covers partitioning, the declarative `configuration.nix` model,
module authoring, system services, and upgrade/rollback workflows. Essential
when configuring a NixOS homelab host or virtual machine from scratch.

**Tags**

`#official` `#manual` `#nixos` `#configuration` `#installation`

---

#### Nixpkgs Reference Manual

**Website**

https://nixos.org/manual/nixpkgs/stable/

**Description**

The user-facing reference for Nixpkgs: describes `stdenv.mkDerivation`,
languages/frameworks support, overrides, cross-compilation, the module system,
and library functions. Indispensable when packaging software or building custom
derivations for your homelab services.

**Tags**

`#official` `#manual` `#nixpkgs` `#packaging` `#stdenv`

---

#### Nix Reference Manual

**Website**

https://nix.dev/reference/nix-manual.html

**Description**

The reference manual for the Nix package manager itself — the store, the
evaluator, the CLI commands (`nix build`, `nix develop`, `nix flake`), the Nix
language, and built-in functions. Linked from nix.dev with version selectors
for pre-release, stable, and historical builds. Reach for it when debugging
store corruption, evaluating expressions, or scripting with `nix` CLI.

**Tags**

`#official` `#manual` `#nix` `#cli` `#reference`

---

#### NixOS Release Notes

**Website**

https://nixos.org/manual/nixos/stable/release-notes.html

**Description**

Appendix B of the NixOS manual — a per-release changelog of breaking changes,
new modules, and security-relevant updates. Always read before running
`nixos-rebuild switch --upgrade` on a homelab host, especially across major
version jumps (e.g. 24.11 → 25.05).

**Tags**

`#official` `#release-notes` `#nixos` `#upgrades` `#changelog`

---

#### Nixpkgs Release Notes

**Website**

https://nixos.org/manual/nixpkgs/stable/release-notes.html

**Description**

Appendix A of the Nixpkgs manual — tracks breaking changes in package sets
(GCC bumps, Python version migrations, library removals). Useful when a
homelab service stops building after a channel bump and you need to identify
the offending upstream change.

**Tags**

`#official` `#release-notes` `#nixpkgs` `#upgrades` `#changelog`

---

#### NixOS Wiki (Official)

**Website**

https://wiki.nixos.org/wiki/NixOS_Wiki

**Description**

The official, foundation-hosted NixOS wiki, launched in April 2024. Covers
user guides, configuration examples, troubleshooting, and topics not in the
formal manuals. It supersedes the older unofficial `nixos.wiki`; check here
first for recipe-style "how do I do X" answers for homelab services.

**Tags**

`#official` `#wiki` `#nixos` `#howto` `#community`

---

#### NixOS RFCs Repository

**Website**

https://github.com/NixOS/rfcs

**Description**

The Nix community's Request For Comments process: major changes to Nix,
Nixpkgs, and NixOS land as Markdown files under `rfcs/` and are merged after
community review. Reading individual RFCs (e.g. RFC 0042 on the `config`
option, RFC 0136 on flakes stabilization) gives deep context on why NixOS is
shaped the way it is and what is coming next.

**Tags**

`#official` `#rfc` `#governance` `#nixos` `#design`

---

#### NixOS Download Page

**Website**

https://nixos.org/download

**Description**

The official source for NixOS ISOs, virtual appliances, and the Nix package
manager installer scripts across platforms. Use it to fetch the right artifact
for a fresh homelab install (bare metal, KVM, Proxmox, etc.) or to install the
Nix package manager onto an existing Linux/macOS host.

**Tags**

`#official` `#download` `#iso` `#installer` `#nixos`

---

#### NixOS Learn Hub

**Website**

https://nixos.org/learn

**Description**

The official learning landing page that curates the various entry points into
the Nix ecosystem: Nix Pills, nix.dev tutorials, Zero to Nix, and community
guides. Good first stop when onboarding a teammate who is new to NixOS.

**Tags**

`#official` `#learning` `#onboarding` `#nixos`

---

#### NixOS Community Page

**Website**

https://nixos.org/community

**Description**

Lists the official and moderated community spaces: Discourse forum, Matrix
rooms, GitHub, Mastodon, and regional meetups. Useful when you need to ask
questions, find mentors, or contribute back to the project from a homelab
context.

**Tags**

`#official` `#community` `#forum` `#matrix` `#contributing`

---

#### NixOS Blog

**Website**

https://nixos.org/blog

**Description**

Official foundation blog carrying release announcements (e.g. NixOS 25.05,
25.11), security advisories, and project news. Subscribe or check periodically
to time homelab upgrades around stable releases.

**Tags**

`#official` `#blog` `#announcements` `#nixos`

---

#### NixOS Research & Scientific Publications

**Website**

https://nixos.org/research

**Description**

A curated list of peer-reviewed papers, theses, and talks about Nix and
NixOS, maintained by the project. Includes Dolstra's PhD thesis, the JFP
NixOS paper, and reproducibility studies. The right place to ground your
understanding of the theoretical model behind Nix.

**Tags**

`#official` `#research` `#academic` `#papers` `#reproducibility`

---

#### NixOS Discourse (Community Forum)

**Website**

https://discourse.nixos.org

**Description**

The official community forum, replacing the old `nix-devel` mailing list in
2018. Categories cover announcements, help, development, guides, and jobs.
The highest-signal channel for asking homelab-specific NixOS questions and
following project direction.

**Tags**

`#official` `#community` `#forum` `#discourse` `#help`

---

#### NixOS Weekly / Newsletters Archive

**Website**

https://nixos.org/blog/newsletters

**Description**

The archive of the (intermittently published) NixOS newsletter, summarizing
news, jobs, tooling, and events from the ecosystem. A good way to catch up on
what you missed without scrolling the Discourse. Currently low-frequency; the
Nixcademy newsletter is a more regular alternative.

**Tags**

`#official` `#newsletter` `#news` `#archive` `#nixos`

---

#### NixOS GitHub Organization

**Website**

https://github.com/NixOS

**Description**

The umbrella GitHub organization hosting `nix`, `nixpkgs`, `nix-pills`,
`rfcs`, `nixos-homepage`, `nix.dev`, and dozens of supporting repos. The
canonical source of truth for code, issues, and pull requests across the
project.

**Tags**

`#official` `#github` `#source` `#nixos` `#nixpkgs`

---

### 2. Nix Language

Resources focused specifically on the Nix expression language — its syntax,
semantics, builtins, and idioms. Reading at least one of these before writing
non-trivial modules will save hours of confusion.

#### Nix Language Basics (nix.dev Tutorial)

**Website**

https://nix.dev/tutorials/nix-language.html

**Description**

The official nix.dev introduction to reading the Nix language: attribute
sets, let bindings, functions, laziness, and derivations. Aimed at someone
who needs to follow examples in other docs and is the recommended first
read before writing NixOS modules.

**Tags**

`#official` `#language` `#tutorial` `#nix` `#beginner`

---

#### Learn X in Y Minutes — Nix

**Website**

https://learnxinyminutes.com/nix

**Description**

A single-page, code-heavy cheat sheet for the Nix language covering types,
operators, attribute sets, functions, and the most-used builtins. Keep it open
in a browser tab as a quick syntax reference while editing NixOS configs.

**Tags**

`#community` `#language` `#cheatsheet` `#nix` `#reference`

---

#### Nix Language: Learning Resources (NixOS Wiki)

**Website**

https://wiki.nixos.org/wiki/Nix_Language:_Learning_resources

**Description**

A wiki page cataloging external resources for learning the Nix language —
tutorials, videos, books, and articles — with notes on what each is best
suited for. Use it as a discovery layer when the official docs are not enough
for your learning style.

**Tags**

`#official` `#wiki` `#language` `#learning` `#nix`

---

#### The Nix Language (Zero to Nix Concept Page)

**Website**

https://zero-to-nix.com/concepts/nix-language

**Description**

A beginner-friendly concept page from Determinate Systems explaining what Nix
is as a pure, lazy, declarative, functional language and how it relates to the
package manager. Good companion to the denser nix.dev tutorial when first
encountering the language.

**Tags**

`#community` `#language` `#concept` `#beginner` `#determinate`

---

#### Nix Manual — Language Section

**Website**

https://nix.dev/manual/nix/stable/language/

**Description**

The formal language chapter of the Nix reference manual: data types,
operators, the module/laziness semantics, and built-in constants. The
authoritative reference when behavior is ambiguous or you need to cite the
spec.

**Tags**

`#official` `#manual` `#language` `#specification` `#nix`

---

#### Built-in Functions (Nix Reference Manual)

**Website**

https://nix.dev/manual/nix/stable/language/builtins.html

**Description**

Reference page enumerating every function in the global `builtins` set
(`builtins.mapAttrs`, `builtins.derivation`, `builtins.fetchurl`, etc.). An
essential bookmark when writing non-trivial Nix code or reading other
people's flakes.

**Tags**

`#official` `#manual` `#language` `#builtins` `#reference`

---

### 3. nix.dev — The Official Learning Hub

nix.dev is the official documentation hub for getting things done with Nix.
It is organized along the Diátaxis framework (tutorials, guides, reference,
explanation) and is the single best place to send a developer who is learning
Nix for the first time.

#### nix.dev — Home

**Website**

https://nix.dev

**Description**

The landing page for the official Nix ecosystem learning hub, maintained by
the Nix documentation team. It links to all tutorials, guides, recipes, the
FAQ, the glossary, and the Nix reference manual. Make this your homepage when
onboarding to NixOS.

**Tags**

`#official` `#nix-dev` `#learning` `#documentation` `#hub`

---

#### Tutorials Index (nix.dev)

**Website**

https://nix.dev/tutorials/index.html

**Description**

The full index of nix.dev tutorials, sequenced from first steps through
packaging, cross-compilation, the module system, and NixOS-specific work.
Follows the Diátaxis "learning" axis and is designed to be read in order.

**Tags**

`#official` `#nix-dev` `#tutorials` `#learning` `#index`

---

#### Install Nix (nix.dev)

**Website**

https://nix.dev/install-nix.html

**Description**

The official guide for installing Nix on Linux, macOS, WSL2, and inside CI.
Covers prerequisites, the Determinate Systems installer as an alternative,
and post-install verification. The right starting point before any other
nix.dev tutorial.

**Tags**

`#official` `#nix-dev` `#installation` `#nix` `#tutorial`

---

#### Ad hoc Shell Environments (nix.dev First Steps)

**Website**

https://nix.dev/tutorials/first-steps/ad-hoc-shell-environments.html

**Description**

A first-steps tutorial showing how to use `nix shell` and `nix run` to get
ephemeral, reproducible shells for any package in Nixpkgs without permanently
installing it. The fastest way to demonstrate Nix's value on a homelab box
before committing to NixOS.

**Tags**

`#official` `#nix-dev` `#tutorial` `#nix-shell` `#beginner`

---

#### Packaging Existing Software with Nix (nix.dev Tutorial)

**Website**

https://nix.dev/tutorials/packaging-existing-software.html

**Description**

A hands-on tutorial that walks through packaging real C/C++ software using
`stdenv.mkDerivation`, including phases, dependencies, and testing with
`nix-build`/`nix build`. The natural next step when you need to package a
homelab service that is not yet in Nixpkgs.

**Tags**

`#official` `#nix-dev` `#tutorial` `#packaging` `#stdenv`

---

#### Best Practices (nix.dev Guides)

**Website**

https://nix.dev/guides/best-practices.html

**Description**

A guide covering recommended Nix patterns: pinning `nixpkgs` revisions,
prefering flakes over channels for reproducibility, structuring derivations,
and quoting. Read this once you can write Nix and want to write it well in a
homelab setting shared with other machines.

**Tags**

`#official` `#nix-dev` `#guide` `#best-practices` `#reproducibility`

---

#### Recipes (nix.dev Guides)

**Website**

https://nix.dev/guides/recipes/index.html

**Description**

A growing collection of solution-oriented recipes for common Nix tasks (custom
binary caches, signing, remote builds, etc.). The Diátaxis "how-to" section —
jump here when you have a specific problem to solve rather than a topic to
learn.

**Tags**

`#official` `#nix-dev` `#guide` `#recipes` `#howto`

---

#### Frequently Asked Questions (nix.dev)

**Website**

https://nix.dev/guides/faq.html

**Description**

The official nix.dev FAQ, addressing recurring questions about channels vs
flakes, garbage collection, disk usage, multi-user vs single-user installs,
and reproducibility pitfalls. Worth scanning before asking on Discourse.

**Tags**

`#official` `#nix-dev` `#faq` `#troubleshooting` `#nix`

---

#### Glossary (nix.dev Reference)

**Website**

https://nix.dev/reference/glossary.html

**Description**

The official Nix glossary defining store path, derivation, closure, profile,
flake, channel, and other jargon. Essential for new users reading the rest of
the documentation or community discussions.

**Tags**

`#official` `#nix-dev` `#reference` `#glossary` `#terminology`

---

#### Documentation Framework — Diátaxis (nix.dev)

**Website**

https://nix.dev/contributing/documentation/diataxis.html

**Description**

Explains the Diátaxis documentation framework (tutorials / how-to guides /
reference / explanation) used to organize nix.dev. Useful if you want to
contribute documentation upstream or organize your own internal NixOS
knowledge base coherently.

**Tags**

`#official` `#nix-dev` `#meta` `#documentation` `#diataxis`

---

### 4. Nix Pills

Nix Pills is the classic, low-level tutorial series by Luca Bruno
("Lethalman"), originally blog posts from 2014–2015, now maintained under
the NixOS organization. It explains how Nix and Nixpkgs actually work
internals-first — the store, derivations, stdenv, fixed-output builds, and
the module system.

#### Nix Pills — Preface & Index

**Website**

https://nixos.org/guides/nix-pills

**Description**

The official, hosted Nix Pills series — a chapter-by-chapter tour from "Why
you should give it a try" through "Fundamentals of stdenv" and beyond. Best
read after a first pass through nix.dev when you want to understand *why*
Nixpkgs is structured the way it is.

**Tags**

`#official` `#tutorial` `#nix-pills` `#nixpkgs` `#internals`

---

#### Nix Pills — Source Repository

**Website**

https://github.com/NixOS/nix-pills

**Description**

The GitHub source for the Nix Pills, written in DocBook and buildable into
multi-page HTML or an EPUB e-book. Useful for offline reading, contributing
fixes, or generating a custom PDF via pandoc.

**Tags**

`#official` `#github` `#source` `#nix-pills` `#docbook`

---

#### Pill 4 — The Basics of the Language (Nix Pills)

**Website**

https://nixos.org/guides/nix-pills/04-basics-of-language.html

**Description**

The fourth Nix Pill: a focused introduction to the Nix expression language
(derivations, `nix-build`, attribute sets, and lazy evaluation). A good
standalone reference if you want the language explained from the
Nixpkgs-builder perspective rather than the nix.dev tutorial perspective.

**Tags**

`#official` `#nix-pills` `#language` `#tutorial` `#derivations`

---

#### Pill 6 — Our First Derivation (Nix Pills)

**Website**

https://nixos.org/guides/nix-pills/06-our-first-derivation.html

**Description**

The sixth Nix Pill walks through writing a derivation from scratch and
inspecting what `nix-build` actually produces in the Nix store. Read it to
demystify what `mkDerivation` is doing behind the scenes.

**Tags**

`#official` `#nix-pills` `#derivations` `#tutorial` `#store`

---

#### Pill 19 — Fundamentals of Stdenv (Nix Pills)

**Website**

https://nixos.org/guides/nix-pills/19-fundamentals-of-stdenv.html

**Description**

The nineteenth Nix Pill explains `stdenv`, the core wrapper around
`derivation` that powers almost every Nixpkgs package, including phases,
setup hooks, and environment variables. Essential when debugging real
packaging problems.

**Tags**

`#official` `#nix-pills` `#stdenv` `#tutorial` `#packaging`

---

#### Original Nix Pills (Lethalman Blog) (Archived)

**Website**

http://lethalman.blogspot.com/2014/07/nix-pill-1-why-you-should-give-it-try.html

**Description**

The original 2014–2015 Nix Pills blog posts by Luca Bruno ("Lethalman") on
Blogspot. Now superseded by the maintained version at nixos.org/guides/nix-pills,
which is the recommended reading path; this URL is kept for historical
reference and citations.

**Tags**

`#archived` `#nix-pills` `#historical` `#blog` `#lethalman`

---

### 5. Zero to Nix

Zero to Nix is the beginner-friendly, flakes-first learning resource built
and maintained by Determinate Systems. It is intentionally opinionated and
is a popular alternative or complement to the official nix.dev path.

#### Zero to Nix — Main Site

**Website**

https://zero-to-nix.com

**Description**

The full beginner-friendly Nix and flakes learning hub from Determinate
Systems. Covers installing Nix (via the Determinate installer), running
programs, building dev shells and packages, deploying to NixOS, and best
practices — all flakes-first. A strong on-ramp for homelab users who want
reproducible dev environments without first learning channels.

**Tags**

`#community` `#determinate` `#learning` `#flakes` `#beginner`

---

#### Zero to Nix — Source Repository

**Website**

https://github.com/DeterminateSystems/zero-to-nix

**Description**

The GitHub source for the Zero to Nix website, built with Astro and deployed
on Vercel. Useful if you want to contribute corrections, run an offline
mirror, or study the structure of a large Nix documentation project.

**Tags**

`#community` `#determinate` `#github` `#source` `#learning`

---

#### Introducing Zero to Nix (Determinate Systems Blog)

**Website**

https://determinate.systems/blog/zero-to-nix

**Description**

The launch announcement and rationale for Zero to Nix, explaining its
flakes-first, beginner-friendly philosophy and how it fits alongside nix.dev
and Nix Pills. Good context for understanding the modern Nix learning
landscape.

**Tags**

`#community` `#determinate` `#blog` `#announcement` `#learning`

---

#### Learn Nix — Determinate Systems Guide

**Website**

https://docs.determinate.systems/guides/learn-nix

**Description**

A short pointer page on the Determinate Systems docs site recommending Zero
to Nix as the official starting point. Useful if you are already in the
Determinate ecosystem (installer, Nixup, etc.) and want the canonical
next-step link.

**Tags**

`#community` `#determinate` `#guide` `#learning` `#nix`

---


---

## Part II — Core Tooling

### 6. Nixpkgs

Nixpkgs is the single repository that defines every package, every NixOS
module, and the `lib` standard library used across the ecosystem. The
references below cover the source tree, the contributor workflow, the official
manual, the library, the package layout (including the new `by-name` scheme),
the `staging` branch used for mass rebuilds, and Hydra — the CI that produces
the binary cache your homelab pulls from.

#### NixOS/nixpkgs GitHub Repository

**Website**

https://github.com/NixOS/nixpkgs

**Description**

The canonical source repository for all Nix packages, NixOS modules, and the
`lib` standard library. With tens of thousands of contributors and pull
requests merged daily, it is one of the largest open-source repositories on
GitHub. For a homelab, this is the source of truth for package versions,
security patches, and the NixOS modules you import via `imports = [ ... ];`.

**Tags**

`#nixpkgs` `#source` `#packages` `#modules`

---

#### nixpkgs CONTRIBUTING.md

**Website**

https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md

**Description**

The official contributor guide for Nixpkgs, covering how to fork and clone the
repository, how to choose the correct base branch (`master`, `staging`,
`staging-next`, release branches), how to format commits, and how to submit
pull requests. Essential reading before opening a PR to package a tool your
homelab depends on, or to fix a broken upstream package.

**Tags**

`#nixpkgs` `#contributing` `#workflow` `#pull-requests`

---

#### Nixpkgs Reference Manual

**Website**

https://nixos.org/manual/nixpkgs/unstable/

**Description**

The official Nixpkgs manual, documenting how to author package expressions,
how to use `stdenv.mkDerivation`, how to write language-specific builders
(Go, Python, Rust, Haskell), and how the `lib` standard library is organized.
This is the first stop when you need to know how to package something for your
own overlay or for upstream contribution.

**Tags**

`#nixpkgs` `#manual` `#packaging` `#stdenv` `#reference`

---

#### Nixpkgs Library (lib) Functions

**Website**

https://nixos.org/manual/nixpkgs/unstable/#sec-functions-library

**Description**

The reference for the `lib` standard library shipped with Nixpkgs — covering
`lib.attrsets`, `lib.lists`, `lib.strings`, `lib.trivial`, `lib.generators`,
and more. These functions are the building blocks of every NixOS configuration
and reusable module. A homelab operator writing custom modules or refactoring
a `configuration.nix` will reference this constantly.

**Tags**

`#nixpkgs` `#lib` `#stdlib` `#functions` `#reference`

---

#### Nixpkgs Top-Level pkgs Directory

**Website**

https://github.com/NixOS/nixpkgs/tree/master/pkgs

**Description**

The `pkgs/` directory in Nixpkgs holds all package definitions, organized
historically by topic (`development/`, `servers/`, `tools/`, `applications/`)
and increasingly by name under `pkgs/by-name/`. Browsing this tree is the
quickest way to find a real-world example expression when packaging a similar
tool for your homelab.

**Tags**

`#nixpkgs` `#pkgs` `#source` `#packages`

---

#### Nixpkgs pkgs/by-name Layout

**Website**

https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md

**Description**

The newer, scalable package layout that places each package at a path derived
from its attribute name (e.g. `hello` → `pkgs/by-name/he/hello/package.nix`).
All newly-added packages are required to follow this scheme, which makes
discovery and automation far easier than the legacy topic-based tree.
Understanding this layout matters when contributing new packages or navigating
recent commits.

**Tags**

`#nixpkgs` `#architecture` `#by-name` `#packaging`

---

#### Nixpkgs Stdenv Chapter

**Website**

https://nixos.org/manual/nixpkgs/unstable/#part-stdenv

**Description**

The stdenv chapter of the Nixpkgs manual documents `stdenv.mkDerivation`,
the phases (`configurePhase`, `buildPhase`, `installPhase`, etc.), and the
hooks used to build packages idiomatically (`buildGoModule`,
`buildPythonApplication`, `buildRustPackage` rely on stdenv). This is the
canonical reference for understanding what a Nix derivation actually does
when you read a package expression.

**Tags**

`#nixpkgs` `#stdenv` `#mkderivation` `#packaging` `#reference`

---

#### Nixpkgs Staging Branch

**Website**

https://github.com/NixOS/nixpkgs/tree/staging

**Description**

The `staging` branch is where mass-rebuild PRs (anything that touches many
packages, such as a `gcc` upgrade or a `glibc` bump) are batched before being
promoted to `staging-next` and then to `master`. Knowing the staging workflow
is essential when contributing changes that affect large parts of the package
set, and explains why some PRs sit open for weeks.

**Tags**

`#nixpkgs` `#staging` `#branches` `#ci` `#workflow`

---

#### Hydra — NixOS Continuous Integration

**Website**

https://hydra.nixos.org/

**Description**

Hydra is the continuous integration system that builds every commit to
Nixpkgs, producing the binaries that populate `cache.nixos.org`. Public jobsets
include `nixos/trunk-combined`, `nixpkgs/staging-next`, and the release
channels (`nixos-24.11`, `nixos-unstable`). A homelab operator can check Hydra
to see whether a package is currently building successfully on a given
architecture or to debug why a channel has not advanced.

**Tags**

`#hydra` `#ci` `#binary-cache` `#build-farm` `#nixpkgs`

---

#### NixOS Wiki: Nixpkgs

**Website**

https://nixos.wiki/wiki/Nixpkgs

**Description**

The community-maintained NixOS Wiki overview page for Nixpkgs, covering
channels, branches, how to pin a specific commit, and how to use overlays.
Useful as a quick reference for concepts that span both Nixpkgs-the-repo and
NixOS-the-distribution, with cross-links to the official manual.

**Tags**

`#nixpkgs` `#wiki` `#channels` `#overlays`

---

#### Nixpkgs README

**Website**

https://github.com/NixOS/nixpkgs/blob/master/README.md

**Description**

The top-level README of the Nixpkgs repository, with a high-level overview of
what the repository contains, links to the manuals, the support matrix, and
quick pointers for getting started with NixOS or the Nix package manager. A
useful orientation document when first navigating the repository.

**Tags**

`#nixpkgs` `#readme` `#overview` `#getting-started`

---

#### Nixpkgs Manual — Hooks and Builders

**Website**

https://nixos.org/manual/nixpkgs/unstable/#sec-language-frameworks

**Description**

The "Languages and frameworks" chapter of the Nixpkgs manual cataloging the
language- and ecosystem-specific builders and hooks (`buildGoModule`,
`buildPythonApplication`, `buildRustPackage`, `buildNpmPackage`, `buildMix`,
etc.) that wrap `stdenv.mkDerivation`. The canonical reference when packaging
a tool from a specific language ecosystem for a homelab overlay or upstream
contribution.

**Tags**

`#nixpkgs` `#manual` `#builders` `#hooks` `#packaging`

---

### 7. NixOS

NixOS is the Linux distribution built on top of Nix and Nixpkgs. The
references below cover the project website, the official manual (stable and
unstable), the `nixos-rebuild` workflow, the `configuration.nix` structure,
the module system, the options search, release notes, and the community wiki.

#### NixOS Manual (Unstable)

**Website**

https://nixos.org/manual/nixos/unstable/

**Description**

The NixOS manual built from the `master` branch, documenting in-progress
features, new modules, and breaking changes before they ship in a stable
release. Use this when tracking `nixos-unstable` in a homelab to preview
upcoming options or services.

**Tags**

`#nixos` `#manual` `#unstable` `#reference`

---

#### NixOS Manual: Changing the Configuration (nixos-rebuild)

**Website**

https://nixos.org/manual/nixos/stable/#sec-changing-config

**Description**

The manual chapter covering `nixos-rebuild switch|test|boot`, the difference
between generations, and how rollbacks work. This is the canonical reference
for the day-to-day workflow of editing `configuration.nix` and applying
changes to a homelab host.

**Tags**

`#nixos` `#nixos-rebuild` `#configuration` `#generations` `#rollback`

---

#### NixOS Manual: Configuration File (configuration.nix)

**Website**

https://nixos.org/manual/nixos/stable/#sec-configuration-file

**Description**

The manual section describing the structure of `/etc/nixos/configuration.nix`,
including the top-level attributes (`boot`, `services`, `users`, `networking`,
`environment.systemPackages`), imports, and how `lib.mkDefault` /
`lib.mkForce` interact. Essential reading for any NixOS homelab operator
authoring or refactoring a system configuration.

**Tags**

`#nixos` `#configuration-nix` `#manual` `#reference`

---

#### NixOS Manual: Writing Modules

**Website**

https://nixos.org/manual/nixos/stable/#sec-writing-modules

**Description**

The chapter that teaches how to write a NixOS module, including
`options = { ... }` declarations with types, `config = { ... }` definitions,
and the use of `mkIf`, `mkMerge`, and `mkDefault`. This is the reference for
anyone refactoring a sprawling `configuration.nix` into reusable modules or
publishing a NixOS module for a self-hosted service.

**Tags**

`#nixos` `#modules` `#options` `#mkif` `#reference`

---

#### NixOS Manual: Module System

**Website**

https://nixos.org/manual/nixos/stable/#sec-module-system

**Description**

The deeper chapter on how the NixOS module system evaluates and merges module
declarations, including priority, `mkOverride`, `mkOptionDefault`, and the
evaluation order. Useful when debugging surprising interactions between
modules in a complex homelab configuration.

**Tags**

`#nixos` `#module-system` `#mkoverride` `#evaluation` `#reference`

---

#### NixOS Release Notes

**Website**

https://nixos.org/manual/nixos/unstable/release-notes.html

**Description**

The accumulated release notes for every NixOS release, documenting new
services, breaking changes, deprecations, and migration steps between
versions (e.g. 24.05 → 24.11). Reading the release notes is the single most
important pre-upgrade step for a homelab NixOS host.

**Tags**

`#nixos` `#release-notes` `#upgrades` `#changelog`

---

#### NixOS Options Search

**Website**

https://search.nixos.org/options

**Description**

The official searchable index of every NixOS option across all channels and
Nixpkgs versions, with type information, default values, descriptions, and
the source file that declares each option. Indispensable when discovering how
to configure a service like `services.nginx` or `services.postgresql` in a
homelab.

**Tags**

`#nixos` `#options` `#search` `#reference`

---

#### NixOS Wiki

**Website**

https://nixos.wiki/

**Description**

The community-maintained NixOS Wiki, covering practical topics that often sit
between the official manuals — GPU drivers, proprietary software, filesystem
setup, troubleshooting, and FAQ entries. A useful first stop for
homelab-specific how-tos, though it can lag behind official documentation for
brand-new features.

**Tags**

`#nixos` `#wiki` `#community` `#how-to`

---

#### NixOS Wiki: Configuration.nix

**Website**

https://nixos.wiki/wiki/Configuration.nix

**Description**

A focused community wiki page on `configuration.nix`, with annotated example
snippets for common homelab tasks (bootloader setup, networking, users,
services) and links to deeper topic pages. Useful as a quick-start reference
alongside the official manual.

**Tags**

`#nixos` `#configuration-nix` `#wiki` `#examples`

---

#### NixOS Manual: Containers

**Website**

https://nixos.org/manual/nixos/stable/#ch-containers

**Description**

The manual chapter on NixOS declarative and imperative containers, including
`containers.<name> = { ... }` options, port forwarding, bind mounts, and how
to run a container as a NixOS module on the host. Useful for homelab
operators who want lightweight, declaratively-managed containerized services
without adopting Docker Compose.

**Tags**

`#nixos` `#containers` `#manual` `#reference`

---

#### NixOS Manual: NixOS Tests

**Website**

https://nixos.org/manual/nixos/stable/#sec-nixos-tests

**Description**

The manual section on NixOS tests — integration tests written in Nix that
spin up a network of VMs in a QEMU test driver and assert that services
behave as expected. Invaluable for a homelab operator validating a
non-trivial module (e.g. a multi-host service with a database) before
deploying it to real hardware.

**Tags**

`#nixos` `#tests` `#qemu` `#integration` `#reference`

---

#### NixOS Wiki: NixOS Overview

**Website**

https://nixos.wiki/wiki/NixOS

**Description**

The main community wiki overview page for NixOS itself, with summaries of
installation, package management, configuration, and links to dozens of
topic-specific sub-pages (boot, networking, X11/Wayland, sound, virtualisation).
A practical landing page when looking for community-curated guidance on a
specific NixOS subsystem.

**Tags**

`#nixos` `#wiki` `#community` `#overview`

---

### 8. Home Manager

Home Manager (nix-community/home-manager) brings NixOS-style declarative
configuration to the user environment — dotfiles, user packages, per-user
systemd services, and shell configuration. The references below cover the
repository, the manual, the options search, the two installation modes
(standalone vs. NixOS module), and the community wiki page.

#### nix-community/home-manager Repository

**Website**

https://github.com/nix-community/home-manager

**Description**

The official Home Manager source repository, providing declarative management
of user-environment packages and dotfiles using the Nix module system. It is
the de-facto standard for managing per-user state on NixOS hosts (and on
non-NixOS Linux/macOS with standalone Nix). Homelab operators use it to keep
shell, Git, editor, and CLI tool configuration reproducible across machines.

**Tags**

`#home-manager` `#dotfiles` `#user-environment` `#nix-community`

---

#### Home Manager Manual

**Website**

https://nix-community.github.io/home-manager/

**Description**

The official Home Manager manual, covering installation (standalone and as a
NixOS module), the `home.nix` structure, the `home-manager` CLI tool, and how
to write custom modules. The canonical starting point for adopting Home
Manager in a homelab.

**Tags**

`#home-manager` `#manual` `#installation` `#reference`

---

#### Home Manager Configuration Options

**Website**

https://nix-community.github.io/home-manager/options.html

**Description**

The full, searchable list of every Home Manager option, organized by
namespace (`programs.*`, `services.*`, `home.*`, `accounts.*`, etc.), with
types, defaults, and descriptions. This is the equivalent of NixOS's options
search but for user-level configuration — essential for finding the option
that controls a specific program's behavior.

**Tags**

`#home-manager` `#options` `#search` `#reference`

---

#### Home Manager Manual: Standalone Installation

**Website**

https://nix-community.github.io/home-manager/#sec-install-standalone

**Description**

The manual section describing how to install Home Manager as a standalone
tool, independent of NixOS — usable on any Linux distribution or macOS where
Nix is installed. Relevant for homelab operators who manage non-NixOS hosts
(alpine VMs, macOS laptops) but still want declarative user-environment
management.

**Tags**

`#home-manager` `#standalone` `#installation` `#multi-platform`

---

#### Home Manager Manual: NixOS Module Installation

**Website**

https://nix-community.github.io/home-manager/#sec-install-nixos-module

**Description**

The manual section describing how to integrate Home Manager as a NixOS
module via `imports = [ <home-manager/nixos> ]` and
`home-manager.users.<name> = { ... }`. This is the recommended approach for
homelab NixOS hosts, since it pins Home Manager to the system channel and
makes user configuration part of the system generation.

**Tags**

`#home-manager` `#nixos-module` `#installation` `#integration`

---

#### NixOS Wiki: Home Manager

**Website**

https://nixos.wiki/wiki/Home_Manager

**Description**

The community wiki page for Home Manager, with a concise overview, common
patterns, troubleshooting tips, and links to community dotfiles and example
configurations. Useful for cross-referencing practical advice that may not yet
be in the official manual.

**Tags**

`#home-manager` `#wiki` `#community` `#examples`

---

#### Home Manager Manual: Writing Modules

**Website**

https://nix-community.github.io/home-manager/#sec-writing-modules

**Description**

The manual section teaching how to author custom Home Manager modules,
including the `programs.<name>` and `services.<name>` option patterns, the
use of `mkIf`, `mkEnableOption`, and how to integrate a program's
configuration files via `xdg.configFile` / `home.file`. Essential when
packaging your own dotfiles or self-hosted CLI tool as a reusable Home
Manager module.

**Tags**

`#home-manager` `#modules` `#writing-modules` `#reference`

---

#### Home Manager Manual: Nix Flakes

**Website**

https://nix-community.github.io/home-manager/#sec-flakes-standalone

**Description**

The manual section describing how to use Home Manager in a flakes-based
workflow — both as a standalone flake (`home-manager init` / `home-manager
switch`) and as a flake input imported into a NixOS flake. The recommended
path for a modern, reproducible homelab configuration that pins Home Manager
via `flake.lock`.

**Tags**

`#home-manager` `#flakes` `#installation` `#reference`

---

### 9. Flakes

Nix Flakes are the modern, hermetic, reproducible way to structure Nix
projects — replacing ad-hoc channels with explicit input declarations pinned
in a `flake.lock`. The references below cover the official RFC repository, the
original Flakes tracking PR, the Nix manual chapter on flakes, the flake
format schema, the popular `flake-utils` helper library, the community wiki
page, and the official `nix.dev` tutorial.

#### Flakes — Original Tracking PR (rfcs#49)

**Website**

https://github.com/NixOS/rfcs/pull/49

**Description**

The original tracking pull request for the Flakes feature, opened in 2018 and
closed in 2020 when Flakes were merged into Nix as experimental. While not a
formally accepted RFC, this thread is the canonical historical record of the
design discussion, motivation, and trade-offs behind flakes. Useful context
for understanding why certain flake behaviors (e.g. pure evaluation) are the
way they are.

**Tags**

`#flakes` `#rfc` `#history` `#design`

---

#### Nix Manual: Flakes Chapter

**Website**

https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html

**Description**

The official Nix manual chapter on flakes, documenting the `nix flake`
subcommands (`init`, `update`, `lock`, `show`, `check`, `archive`), the
`--inputs-from` flag, and how flake references (`github:owner/repo`,
`path:`, `git+https:`) resolve. The primary reference for the day-to-day
flake CLI used in a homelab.

**Tags**

`#flakes` `#nix-manual` `#cli` `#reference`

---

#### Nix Manual: Flake Format

**Website**

https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-format

**Description**

The section of the Nix manual that specifies the `flake.nix` schema — the
`description`, `inputs`, and `outputs` attributes, how `inputs` propagates to
`outputs`, and the conventions for naming outputs (`packages`,
`devShells`, `nixosModules`, `homeModules`, `overlays`, etc.). The
authoritative reference when authoring a `flake.nix` for a homelab
configuration repository.

**Tags**

`#flakes` `#schema` `#flake-nix` `#reference`

---

#### numtide/flake-utils

**Website**

https://github.com/numtide/flake-utils

**Description**

A small, widely-used library that simplifies writing `flake.nix` outputs by
providing `eachSystem` and `mkApp` helpers, eliminating the boilerplate of
enumerating `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`, etc. by hand.
Common in community flakes and homelab repos that need to support multiple
systems without adopting the heavier `flake-parts` framework.

**Tags**

`#flakes` `#flake-utils` `#library` `#multi-system`

---

#### NixOS Wiki: Flakes

**Website**

https://nixos.wiki/wiki/Flakes

**Description**

The community wiki page on Flakes, covering enabling experimental features,
the `flake.nix` structure, `flake.lock`, migrating from channels, and common
pitfalls (e.g. pure vs. impure evaluation, `--impure` flag). A practical
companion to the official Nix manual chapter, with real-world examples for
homelab use.

**Tags**

`#flakes` `#wiki` `#community` `#examples`

---

#### nix.dev — Working with Flakes

**Website**

https://nix.dev/tutorials/working-with-flakes

**Description**

The official `nix.dev` tutorial on flakes, walking through creating a
`flake.nix`, defining `devShells`, consuming flake inputs, and reproducibly
pinning dependencies. The best guided introduction for a homelab operator
migrating from channels to flakes.

**Tags**

`#flakes` `#nix-dev` `#tutorial` `#learning`

---

#### Nix Reference Manual

**Website**

https://nixos.org/manual/nix/stable/

**Description**

The official Nix package manager manual, covering the Nix language, the
built-in functions, the classic CLI (`nix-env`, `nix-build`, `nix-instantiate`),
the new CLI (`nix build`, `nix run`, `nix profile`), and the experimental
feature flags (including flakes). The foundational reference underneath
everything NixOS-specific.

**Tags**

`#nix` `#manual` `#reference` `#cli` `#language`

---

### 10. Flake Parts

flake-parts (hercules-ci/flake-parts) is a module-system framework for
structuring flakes — turning the ad-hoc `outputs` function into a set of
declarative modules that compose cleanly. The references below cover the
repository, the documentation site, the getting-started guide, the options
reference, and the module reference.

#### hercules-ci/flake-parts Repository

**Website**

https://github.com/hercules-ci/flake-parts

**Description**

The official source repository for flake-parts, a framework that applies the
NixOS module system to flakes — letting you split a `flake.nix` into reusable
modules with declared options, rather than writing one monolithic `outputs`
function. Increasingly the standard way to structure non-trivial homelab
configuration flakes.

**Tags**

`#flake-parts` `#flakes` `#module-system` `#hercules-ci`

---

#### flake.parts Documentation

**Website**

https://flake.parts/

**Description**

The official documentation site for flake-parts, covering the philosophy, the
`mkFlake` entry point, the standard flake attributes (`packages`,
`devShells`, `checks`, `apps`), and how modules compose. The starting point
for adopting flake-parts in a homelab flake.

**Tags**

`#flake-parts` `#documentation` `#flakes` `#modules`

---

#### flake.parts Getting Started

**Website**

https://flake.parts/getting-started.html

**Description**

The official getting-started guide for flake-parts, showing how to add
`flake-parts.url = "github:hercules-ci/flake-parts"` to a flake's inputs and
wrap the `outputs` function with `flake-parts.lib.mkFlake { ... }`. A concise
tutorial that takes a homelab operator from a bare `flake.nix` to a
module-structured one in a few minutes.

**Tags**

`#flake-parts` `#getting-started` `#tutorial` `#flakes`

---

#### flake-parts Options Reference

**Website**

https://flake.parts/options/flake-parts-options.html

**Description**

The reference for all options provided by the core `flake-parts` module,
including `flake.packages`, `flake.devShells`, `flake.checks`, `flake.apps`,
`flake.lib`, `perSystem`, and `flake.flakeModules`. The equivalent of the
NixOS options search, but for the flake-parts module system.

**Tags**

`#flake-parts` `#options` `#reference` `#flakes`

---

#### flake-parts Reference (Module Definitions)

**Website**

https://flake.parts/reference/

**Description**

The reference index for flake-parts module definitions, library functions,
and the `mkFlake` arguments. Useful when authoring your own flake-parts
module to share across homelab hosts or to publish as a reusable part.

**Tags**

`#flake-parts` `#reference` `#modules` `#library`

---

### 11. Search Tools

The NixOS ecosystem is enormous, and discovery is half the battle. The
references below cover the official NixOS package and options search, the NUR
(Nix User Repository) and its package search, Noogle (the nix function
search engine), the Home Manager options search, and MyNixOS (a community
site for finding options and examples).

#### NixOS Package Search

**Website**

https://search.nixos.org/packages

**Description**

The official searchable index of every package in every NixOS channel and
Nixpkgs revision, filterable by channel, architecture, and license, with the
exact `nix-shell -p` / `nix profile install` invocation for each result. The
first tool a homelab operator reaches for when looking for a package name to
add to `environment.systemPackages` or `home.packages`.

**Tags**

`#search` `#packages` `#nixos` `#discovery`

---

#### NUR — Nix User Repository

**Website**

https://github.com/nix-community/NUR

**Description**

The Nix User Repository: a community-driven meta-repository that aggregates
hundreds of user-maintained Nix package repos, accessible via a single
`nur.<repo>.<package>` attribute namespace. Useful in a homelab for packages
not yet (or never) accepted into Nixpkgs — pre-built binaries are provided
through the NUR binary cache where available.

**Tags**

`#nur` `#community` `#packages` `#nix-community`

---

#### NUR Package Search

**Website**

https://nur.nix-community.org/

**Description**

The official search site for the NUR, listing all repos and packages
registered with the NUR project, with build status indicators. Use this to
discover whether a tool you need is already packaged by a NUR contributor
before packaging it yourself.

**Tags**

`#nur` `#search` `#community` `#packages`

---

#### Noogle — Nix Function Search

**Website**

https://noogle.dev/

**Description**

Noogle is a community-built search engine and reference for Nix builtins and
Nixpkgs `lib` functions, with type signatures, examples, and
cross-references. It fills the gap left by the official `lib` documentation,
which can be hard to navigate, and is invaluable when looking for the right
`lib.strings.*` or `lib.attrsets.*` function while writing a NixOS module.

**Tags**

`#noogle` `#search` `#lib` `#functions` `#reference`

---

#### MyNixOS

**Website**

https://mynixos.com/

**Description**

A community-built site that wraps the NixOS and Home Manager option searches
with a cleaner interface, plus curated example configurations and a library
of community-published configs. Useful as a discovery layer when learning
which options exist for a given service or program.

**Tags**

`#mynixos` `#search` `#community` `#options` `#discovery`

---

#### NUR-Combined Repository

**Website**

https://github.com/nix-community/nur-combined

**Description**

The auto-updated aggregate repository that combines all registered NUR
repositories into a single evaluable Nix expression tree, used as the
backend for the NUR search site and by users who import NUR via
`import (builtins.fetchTarball ...)`. Understanding this repo clarifies how
NUR packages are published, indexed, and consumed in a homelab flake or
channel workflow.

**Tags**

`#nur` `#aggregate` `#nix-community` `#infrastructure`

---


---

## Part III — Deployment & Provisioning

### 12. Multi-Host Flake Deployment Tools

These tools take a Nix flake (or Nix expression) and push system profiles to one or more remote NixOS machines over SSH. They layer on top of `nixos-rebuild` with parallelism, profiles, secrets handling, health checks, and rollback semantics.

#### deploy-rs

**Website**

https://github.com/serokell/deploy-rs

**Description**

A Rust-based, multi-profile Nix-flake deployment tool from Serokell. It treats NixOS systems the same way as any other profile, so you can deploy rootless application profiles (e.g. a service user's home) alongside the system profile in a single command. It supports magic rollback (auto-revert if the new generation is unreachable after switch), SSH-based remote activation, and per-node custom profiles. For a homelab, this is a good fit when you want one flake that defines both servers and per-user service profiles with safety nets.

**Status**: Active (development has slowed; still widely used). Replacements/experiments: `boinkor-net/deploy-flake`.

**Tags**

`#nixos` `#deployment` `#flakes` `#ssh` `#rollback`

---

#### Colmena

**Website**

https://github.com/nix-community/colmena (originally https://github.com/zhaofengli/colmena — now redirects)

**Description**

A simple, stateless NixOS deployment tool written in Rust and modeled after NixOps and Morph. Colmena is a thin wrapper over `nix-copy-closure`/`nixos-rebuild` that adds a "hive" (a Nix expression describing all your hosts), parallel deployment, tag-based node selection, SSH key management, local/remote build options, and a `colmena apply` workflow. It is a strong default choice for a homelab with 3+ NixOS machines because it requires almost no setup beyond a `hive.nix` and SSH access.

**Status**: Active, lives under `nix-community`. Documentation: https://colmena.cli.rs/

**Tags**

`#nixos` `#deployment` `#parallel` `#hive` `#flakes`

---

#### Morph

**Website**

https://github.com/DBCDK/morph

**Description**

A stateless NixOS deployment tool written in Go by the Danish Broadcasting Corporation (DR). Morph wraps `nix-build`, `nix-copy-closure`, `scp`, and `switch-to-configuration` to perform ordered multi-host deployments with pre-deploy and post-deploy health checks (HTTP or command-based). It uses a Nix-based "network" expression describing hosts, similar to NixOps but without state.

**Status**: Largely unmaintained / legacy. Last release (v1.6.0) was in May 2021; the repo has had sporadic commits since but no active feature development. Flake support was never officially added (see issue #124). New deployments should prefer Colmena or deploy-rs.

**Tags**

`#nixos` `#deployment` `#legacy` `#health-checks` `#stateless`

---

#### NixOps (classic)

**Website**

https://github.com/NixOS/nixops

**Description**

The original NixOS deployment tool, supporting AWS, Hetzner, libvirtd, VirtualBox, and more. NixOps introduced the "network" expression model that Morph and Colmena later borrowed, and historically supported provisioning (creating cloud resources) as well as configuration. It is written in Python and uses a stateful SQLite database to track deployed resources.

**Status**: Effectively deprecated. Per NixOS Wiki: "NixOps is not actively recommended for new projects or users." See issue #1574 ("Clarify the status of NixOps") — the community consensus is that NixOps is "de facto dead" and the repo should be archived. Replacements: **Colmena** (stateless fleet deployment), **deploy-rs** (flake-native multi-profile), **nixos-rebuild --target-host** (single-host remote deploy), and **terranix** (when you still need cloud provisioning). A community fork named **nixops-2.0** exists but is also minimally maintained.

**Tags**

`#nixos` `#deployment` `#deprecated` `#stateful` `#cloud-provisioning`

---

### 13. Bare-Metal Provisioning & Installation

Tools that install NixOS onto a fresh machine (physical or virtual) from a flake, often replacing the manual ISO installer.

#### nixos-anywhere

**Website**

https://github.com/nix-community/nixos-anywhere

**Description**

Install NixOS on any machine reachable over SSH (or via IPMI/Redfish for bare metal). It detects whether the target is already running a NixOS installer; if not, it kexecs into a minimal NixOS installer over SSH, then runs **disko** to partition/format the disks, copies the closure, and installs the bootloader. Combined with a flake + disko config, you can go from "blank server" to "booted NixOS" in a single command. Indispensable for homelab bare-metal and VPS provisioning.

**Status**: Active. Documentation: https://nix-community.github.io/nixos-anywhere/

**Tags**

`#nixos` `#installation` `#provisioning` `#ssh` `#kexec` `#bare-metal`

---

#### disko

**Website**

https://github.com/nix-community/disko

**Description**

Declarative disk partitioning for NixOS. You describe your partitions, LVM, LUKS, ZFS, btrfs subvolumes, RAID and mountpoints as a Nix attribute set; disko then generates a script that wipes and reformats the disk exactly to spec. It can be used standalone (`disko-create`) or as a NixOS module (so the same config both partitions and mounts). Pairs naturally with nixos-anywhere for reproducible bare-metal installs. Also ships `disko-install`, which combines partitioning and `nixos-install` into one step.

**Status**: Active. Documentation: https://github.com/nix-community/disko and NixOS Wiki https://nixos.wiki/wiki/Disko

**Tags**

`#nixos` `#disk-partitioning` `#luks` `#zfs` `#btrfs` `#declarative`

---

### 14. Impermanence & Ephemeral Root

Tools for running NixOS with a wiped-or-tmpfs root filesystem, persisting only the files/directories you explicitly declare. This forces true declarative state and makes "what is on this machine?" a question answerable from the flake alone.

#### Impermanence

**Website**

https://github.com/nix-community/impermanence

**Description**

NixOS modules that let you run an ephemeral root (e.g. tmpfs on `/` or btrfs/zfs snapshots rolled back on boot) while persisting only the files and directories you explicitly allow. Two modes are supported: (1) `home-manager`-style bind mounts to a persistent location, and (2) `tmpfs-home`/`tmpfs-root` patterns. The module can also be used on traditional filesystems (ext4/xfs) without repartitioning by simply listing what should survive a reboot. For a homelab, this turns "config drift" into an explicit, reviewable list and makes recovery from compromise trivial (reboot = clean).

**Status**: Active. Wiki: https://nixos.wiki/wiki/Impermanence

**Tags**

`#nixos` `#impermanence` `#ephemeral-root` `#stateless` `#bind-mounts` `#tmpfs`

---

#### systemd-tmpfiles (Impermanence alternative)

**Website**

https://systemd.io/ (NixOS option: `systemd.tmpfiles.rules`)

**Description**

A built-in systemd mechanism that NixOS exposes via `systemd.tmpfiles.rules`. It lets you declaratively create directories, files, symlinks and (crucially for impermanence) wipe patterns on boot — for example "clear `/var/log` on every restart" or "create `/var/lib/postgresql` with mode 0700 if missing". As a lighter alternative to the Impermanence module, you can combine a tmpfs `/` with `systemd.tmpfiles.rules` to declare which directories should be created fresh on each boot. Less ergonomic than Impermanence for whole-system ephemeral root, but ships with NixOS and needs no extra flake input.

**Status**: Active (part of upstream systemd and NixOS).

**Tags**

`#nixos` `#systemd` `#tmpfiles` `#impermanence` `#declarative` `#built-in`

---

### 15. Image Generation & ISO Building

Tools for building bootable NixOS images (ISO, cloud AMIs, qcow2, Proxmox VMA, etc.) from a NixOS configuration.

#### nixos-generators

**Website**

https://github.com/nix-community/nixos-generators

**Description**

A long-standing collection of NixOS "formats" — amazon (EC2 AMI), azure, cloudstack, docker, iso, install-iso, proxmox, qcow2, vmware, virtualbox, gce, kubevirt, and more — that you can apply to any NixOS configuration to produce a target image. You write `nixos-generate -f proxmox -c my-config.nix` and get a ready-to-import VMA. Particularly handy for homelab VM templates and cloud AMIs built from the same flake as bare-metal machines.

**Status**: **ARCHIVED on 2026-01-30.** As of NixOS 25.05, most of `nixos-generators` has been upstreamed into nixpkgs and is now invoked via `nixos-rebuild build-image` (replacing the `nixos-generate` CLI). For new projects on NixOS ≥25.05 prefer `nixos-rebuild build-image`; for older releases, nixos-generators still works from the archived repo.

**Tags**

`#nixos` `#image-generation` `#iso` `#cloud` `#archived` `#vm-templates`

---

#### nixos-rebuild (built-in, with image & remote support)

**Website**

https://nixos.wiki/wiki/Nixos-rebuild (source: https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/installer/tools)

**Description**

The official NixOS deployment/switchover tool, shipped with every NixOS install. Beyond local `nixos-rebuild switch`, it supports remote deployment via `nixos-rebuild switch --target-host user@host --build-host localhost` (build locally, copy closure, activate remotely), and since NixOS 25.05 it also gained `nixos-rebuild build-image` to produce ISO/qcow2/cloud images (replacing `nixos-generate`). For small homelabs with 1-3 hosts, this built-in tool is often enough and avoids extra dependencies.

**Status**: Active, official, in nixpkgs.

**Tags**

`#nixos` `#built-in` `#deployment` `#remote` `#target-host` `#official`

---

#### nixos-install (built-in installer)

**Website**

https://nixos.org/manual/nixos/stable/#sec-installing-from-other-distro (source: nixpkgs `nixos/modules/installer/tools/nixos-install.sh`)

**Description**

The classic NixOS installer invoked from a NixOS live ISO or any Linux distro with Nix installed. `nixos-install --root /mnt --flake .#myhost` mounts a target disk (typically pre-formatted by disko), copies the NixOS closure, installs the bootloader (GRUB/systemd-boot), and writes the initial `/etc/NIXOS` marker. Under the hood, `nixos-anywhere` and `disko-install` both wrap or invoke `nixos-install`. Useful when you want manual control over the install flow.

**Status**: Active, official.

**Tags**

`#nixos` `#installation` `#built-in` `#bootloader` `#official`

---

### 16. Infrastructure-as-Code Layer

Tools that bridge Nix with Terraform/OpenTofu so you can provision cloud resources (instances, DNS, networks) from the same flake that defines the NixOS machines.

#### terranix

**Website**

https://github.com/terranix/terranix — Documentation: https://terranix.org

**Description**

A Nix-based Terraform JSON generator. Instead of writing HCL, you write a Nix expression that produces Terraform JSON; you then run `terraform init/plan/apply` as usual. This lets you reuse Nixpkgs helpers, your flake's `lib`, and the NixOS module system to generate cloud infrastructure. For a homelab, terranix is the natural replacement for the provisioning half of NixOps — you declare Hetzner/DigitalOcean/AWS resources in Nix, then hand the resulting NixOS instances to Colmena/deploy-rs for configuration.

**Status**: Active. Maintained by the `terranix` GitHub org (originally by `mrVanDalo`).

**Tags**

`#nix` `#terraform` `#infrastructure-as-code` `#cloud-provisioning` `#hcl-alternative`

---

### 17. Lightweight & Niche Deployment Tools

Smaller or more opinionated deployment tools worth knowing about, including pull-based (GitOps) approaches and minimal proof-of-concept alternatives.

#### nixinate

**Website**

https://github.com/MatthewCroughan/nixinate

**Description**

A proof-of-concept NixOS deployment tool by Matthew Croughan. Instead of a separate CLI, nixinate generates a per-host `nix run .#nixinate.<hostname>` script for each `nixosConfiguration` in your flake, using the flake's `apps` output. The generated script builds the closure locally (or remotely), copies it via `nix copy`, and runs `switch-to-configuration switch` over SSH. Appealing if you want zero new tooling — the deploy command lives inside your own flake.

**Status**: Proof-of-concept / low-activity but functional.

**Tags**

`#nixos` `#deployment` `#flakes` `#ssh` `#minimal` `#proof-of-concept`

---

#### bento

**Website**

https://github.com/rapenne-s/bento

**Description**

A KISS, pull-based deployment tool for managing a fleet of NixOS servers and workstations. Bento runs a SFTP chroot on a central "bastion" host; each client polls its own configuration directory over SFTP, builds the system locally with `nixos-rebuild build`, and switches itself when a new generation appears. Because clients pull, bento works behind firewalls/NAT without inbound SSH. Good fit for homelabs with laptops or branch servers that can't be reached from a central deployer.

**Status**: Active. Introduction: https://discourse.nixos.org/t/introducing-bento-a-nixos-deployment-framework/21446

**Tags**

`#nixos` `#deployment` `#pull-based` `#fleet` `#sftp` `#gitops`

---

#### comin

**Website**

https://github.com/nlewo/comin

**Description**

A pull-based GitOps deployment agent for NixOS servers and laptops. Comin runs as a systemd service on each host, periodically polls one or more Git repositories for the NixOS configuration assigned to that machine, and runs `nixos-rebuild switch` when new commits appear. It supports multiple branches (e.g. `main` + a `testing` branch) and has a built-in HTTP status API. Ideal when your fleet can't accept inbound SSH from a deployer (e.g. consumer ISPs, NAT'd homelab nodes).

**Status**: Active. NixCon 2024 talk: https://talks.nixcon.org/nixcon-2024/talk/XRFPMU

**Tags**

`#nixos` `#deployment` `#pull-based` `#gitops` `#agent` `#systemd`

---

#### deploy-flake

**Website**

https://github.com/boinkor-net/deploy-flake

**Description**

An experimental Rust tool for deploying a Nix flake to a remote NixOS system over SSH. Explicitly described by its author as "extremely inspired by (and in some ways a reimagining of) `serokell/deploy-rs`." Slightly different activation semantics and a smaller codebase than deploy-rs; useful as a reference implementation or if you hit rough edges in deploy-rs.

**Status**: Experimental / actively developed.

**Tags**

`#nixos` `#deployment` `#flakes` `#ssh` `#experimental` `#rust`

---

#### nix-deploy

**Website**

https://github.com/awakesecurity/nix-deploy

**Description**

A Haskell-based deployment tool from Awake Security. `nix-deploy system` copies a NixOS system configuration to a remote machine over SSH and activates it; `nix-deploy` (without `system`) deploys individual Nix derivations to a remote profile, useful for shipping a single application to a non-NixOS machine via the user-mode Nix installer. Predates the flake-native tools but still useful for cross-distro binary deployment.

**Status**: Maintained but niche; not flake-first.

**Tags**

`#nixos` `#deployment` `#haskell` `#cross-distro` `#ssh`

---

### 18. ISO / Image Builders (Direct)

Concrete projects producing NixOS ISOs and installable images, complementing the (now-archived) nixos-generators.

#### Determinate Systems nixos-iso

**Website**

https://github.com/DeterminateSystems/nixos-iso

**Description**

The build logic for Determinate Systems' official NixOS ISO. The ISOs ship with the Determinate Nix installer pre-baked (rather than the upstream Nix installer), flake-support enabled by default, and a curated set of useful tools for getting a NixOS install up quickly. A practical reference if you want to build your own customized "homelab boot/install ISO" from a flake — the repo shows exactly how to assemble a custom ISO with config injected.

**Status**: Active. Pre-built ISOs linked from the README.

**Tags**

`#nixos` `#iso` `#determinate-systems` `#installer` `#image-generation`

---

#### NixOS built-in ISO/image builder (`config.system.build.isoImage`)

**Website**

https://nix.dev/tutorials/nixos/building-bootable-iso-image (source: nixpkgs `nixos/modules/installer/cd-dvd/`)

**Description**

NixOS itself ships an ISO format via the `nixos/modules/installer/cd-dvd` modules — set `imports = [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ]` in a NixOS config and `nixos-rebuild build` produces an `isoImage` output under `result/iso/`. This is the canonical way to build a custom NixOS bootable ISO with your own packages and config baked in, and is what `nixos-generate -f install-iso` (and now `nixos-rebuild build-image -f install-iso`) wraps.

**Status**: Active, official, in nixpkgs.

**Tags**

`#nixos` `#iso` `#built-in` `#bootable` `#installer` `#official`

---

### 19. Deployment (Miscellaneous)

Notes on tools that the task brief mentioned but which either don't exist as standalone projects, are absorbed into other tools, or could not be verified.

#### pixnix

**Website**

No canonical repository could be located. The name does not appear in `nix-community/awesome-nix`, the NixOS Discourse, or GitHub search as of this writing.

**Description**

Listed in the research brief as a deployment-adjacent tool worth investigating, but no widely-known NixOS tool named "pixnix" could be verified in the ecosystem. It may be a private/internal project, a typo (possibly for `nixinate`, `nix-deploy`, or a personal flake), or a placeholder. If the original brief author can supply a URL, this entry should be updated; otherwise, treat as "unknown — not a recognized public NixOS tool."

**Status**: Unverified / possibly does not exist as a public project.

**Tags**

`#nixos` `#unverified` `#misc` `#needs-clarification`

---

#### "nixos-create-iso" (concept, not a single tool)

**Website**

No standalone tool exists by this name. Equivalent functionality is provided by:
- `nixos-generate -f install-iso` (now archived; see nixos-generators entry)
- `nixos-rebuild build-image -f install-iso` (NixOS ≥25.05, the official replacement)
- The built-in `config.system.build.isoImage` (see entry above)
- Custom flake outputs using `nixos/modules/installer/cd-dvd/*` modules

**Description**

Rather than a dedicated CLI, "creating a NixOS ISO" is a NixOS module pattern: import the `installation-cd-minimal.nix` or `installation-cd-graphical-calamares.nix` module into a NixOS configuration, add any extra packages/config you want on the installer, then build with `nixos-rebuild build` (or `nix build .#nixosConfigurations.installer.config.system.build.isoImage`). The resulting `.iso` can be `dd`'d to a USB stick. For homelab use this is how you produce a "rescue/installer USB" that already contains your SSH keys, your dotfiles, and your favorite partitioning tools.

**Status**: Pattern, not a project — backed by NixOS itself.

**Tags**

`#nixos` `#iso` `#concept` `#built-in` `#installer`

---

### 20. Quick-Reference: Which Tool Should I Pick?

| Need | First choice | Alternatives |
|---|---|---|
| Install NixOS on a fresh server over SSH | **nixos-anywhere** + **disko** | `nixos-install` from a live ISO |
| Deploy to 1-2 hosts from a flake | **nixos-rebuild --target-host** | deploy-rs, nixinate |
| Deploy to 3+ hosts with parallelism & tags | **Colmena** | deploy-rs, bento (pull) |
| Multi-profile (system + per-user services) | **deploy-rs** | deploy-flake |
| GitOps / pull-based (clients behind NAT) | **comin** or **bento** | nixinate (push) |
| Cloud resource provisioning | **terranix** | (legacy) NixOps |
| Declarative disk partitioning | **disko** | manual `parted` + `nixos-install` |
| Stateless/ephemeral root | **Impermanence** | `systemd-tmpfiles.rules` + tmpfs |
| Build ISO/cloud/VM images | **nixos-rebuild build-image** (≥25.05) | `config.system.build.isoImage`, DeterminateSystems/nixos-iso |

**Avoid for new projects (2026+):** classic NixOps (deprecated — see issue #1574), Morph (unmaintained — last release 2021), nixos-generators CLI (archived Jan 2026 — superseded by `nixos-rebuild build-image`).


---

## Part IV — Secrets & Networking

### 21. Secrets Management in NixOS

NixOS stores configuration in the world-readable `/nix/store`, so passwords, tokens, and private keys must be supplied out-of-band. The NixOS ecosystem converged on three patterns: (1) encrypt a secrets file at build time with `age`/`gpg` and decrypt it on the host with a key kept outside the store (agenix, sops-nix), (2) fetch secrets at runtime from a central secrets broker (HashiCorp Vault, cloud KMS), or (3) use a Unix password-store / Bitwarden CLI workflow that lives outside Nix entirely. The first pattern is the dominant one in homelabs.

#### age

**Website**

https://github.com/FiloSottile/age

**Description**

A simple, modern, secure file-encryption tool and format by Filippo Valsorda. It uses X25519 recipients (SSH keys or age-native keys) and ChaCha20-Poly1305, with no config files, no keyring, and a tiny audited codebase. `age` is the cryptographic foundation that `agenix`, `sops-nix` (with the `age` backend), and `agenix-rekey` build on top of — you typically generate a per-host `age` key at install time and use the corresponding public key as a recipient when encrypting secrets. NixOS exposes it via the `age` package in nixpkgs.

**Tags**

`#secrets` `#encryption` `#age` `#cryptography`

---

#### rage

**Website**

https://github.com/str4d/rage

**Description**

A Rust implementation of the `age` encryption standard, fully compatible with `age` files and keys. It is a drop-in replacement for `age` with a memory-safe implementation, and ships a `rage-mount` subcommand for mounting encrypted archives. Useful on NixOS if you prefer Rust over Go for the cryptographic component, or if you want the experimental identity plugin support that `rage` implements ahead of `age`.

**Tags**

`#secrets` `#encryption` `#age` `#rust`

---

#### agenix

**Website**

https://github.com/ryantm/agenix

**Description**

The most popular age-based secrets manager for NixOS. You author `secrets.nix` listing each secret file with its list of age recipient public keys (one per host that needs to read it), then run `agenix -e secret.age` to edit the encrypted file. The accompanying NixOS module reads a per-host identity file (typically `/var/lib/sops-nix/age/keys.txt` or `/var/lib/age/key.txt`) at activation time, decrypts each secret into a `config.age.secrets.<name>.path`, and sets file ownership/mode on the decrypted output. For a homelab, this is the lowest-friction way to ship a TLS private key or a WiFi PSK into a NixOS configuration without leaking it into the git repo or the nix store.

**Tags**

`#secrets` `#nixos` `#age` `#module` `#flakes`

---

#### agenix-rekey

**Website**

https://github.com/oddlama/agenix-rekey

**Description**

A Nix flake / NixOS module that wraps `agenix` to make multi-host fleet management ergonomic. Instead of hand-listing recipients in every `secrets.nix`, you declare your fleet of hosts once (each with its age public key), and `agenix-rekey` automatically re-encrypts every secret for the correct subset of hosts when you run `agenix rekey`. It supports a YAML/JSON app store of secrets, master/host key hierarchies, and a `nix run .#agenix-rekey` workflow that is much friendlier than raw `agenix` once you have more than two or three machines. A strong upgrade path when plain `agenix` starts feeling repetitive.

**Tags**

`#secrets` `#nixos` `#age` `#flakes` `#fleet`

---

#### sops

**Website**

https://github.com/getsops/sops

**Description**

Mozilla-originated "Secrets OPerationS" tool (now maintained under `getsops`). SOPS encrypts only the *values* of YAML/JSON/ENV/INI files, leaving the keys readable, and supports multiple backends per file: AWS KMS, GCP KMS, Azure Key Vault, `age`, `pgp`, and Vault Transit. Recipients are tracked per-file so the same secret can be decrypted by different hosts using different backends. SOPS is the underlying engine that `sops-nix` consumes — you install the `sops` CLI (`nix-shell -p sops`) and edit secrets with `sops secrets.yaml`, then the NixOS module does the activation-time decryption.

**Tags**

`#secrets` `#encryption` `#kms` `#sops` `#multi-backend`

---

#### sops-nix

**Website**

https://github.com/Mic92/sops-nix

**Description**

The NixOS module for SOPS, authored by Mic92 (also a nixpkgs maintainer). You declare `sops.defaultSopsFile = ./secrets.yaml;` and per-secret `sops.secrets.<name> = { owner = ...; mode = ...; };` blocks; at activation the module decrypts each value to `/run/secrets/<name>` (or a configurable path) using the host's age/PGP key, then sets ownership. It supports per-secret file templates, age and PGP backends, secrets that depend on other secrets, and reloading units when secrets change. It is the second of the two dominant NixOS secrets solutions and the preferred choice when you want a single backend that also works with cloud KMS for production.

**Tags**

`#secrets` `#nixos` `#sops` `#age` `#module`

---

#### HashiCorp Vault

**Website**

https://github.com/hashicorp/vault  (project site: https://vaultproject.io/ )

**Description**

A widely deployed secrets broker: a central server (or HA cluster) stores secrets and exposes them via token, AppRole, Kubernetes, AWS IAM, or TLS certificate authentication. Secrets can be short-lived (dynamic database credentials, dynamic PKI certificates), audited, and revoked. In a homelab, Vault is overkill for a single host but very useful if you have many hosts and want a single source of truth for secrets, or if you want to issue short-lived database credentials to apps. NixOS ships a Vault server module (`services.vault`) and a Vault Agent module (`services.vault-agent`) that renders secrets to disk for consumption by services.

**Tags**

`#secrets` `#vault` `#hashicorp` `#centralized` `#secrets-broker`

---

#### NixOS `services.vault` module

**Website**

https://search.nixos.org/options?query=services.vault  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/vault.nix )

**Description**

The in-tree NixOS module that runs the Vault server. Options include `services.vault.enable`, `services.vault.package`, `services.vault.dev` (for local dev mode), `services.vault.storageBackend` (file, raft, consul, etc.), and `services.vault.extraConfig` to pass through arbitrary HCL. A reasonable starting point for a self-hosted Vault dev/single-node Raft instance is a few lines of Nix: enable the module, point storage at `/var/lib/vault`, expose the API on `127.0.0.1:8200`, and put a reverse proxy in front for TLS.

**Tags**

`#secrets` `#nixos` `#vault` `#module` `#nixpkgs`

---

#### NixOS `services.vault-agent` (vault-agent)

**Website**

https://search.nixos.org/options?query=services.vault-agent  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/vault-agent.nix )

**Description**

The companion NixOS module that runs `vault agent` on a host to authenticate to a Vault server, fetch secrets, and render them to disk via templates — optionally restarting services when a rendered file changes. This is the practical glue that makes Vault usable inside NixOS services: instead of baking secrets into the nix store, you let `vault-agent` write `/run/secrets/db-password` and have your service read that path. Supports AppRole, auto-auth wrapping tokens, and `template` blocks with Consul-Template syntax.

**Tags**

`#secrets` `#nixos` `#vault` `#vault-agent` `#module`

---

#### pass (the standard unix password manager)

**Website**

https://www.passwordstore.org/  (source: https://git.zx2c4.com/password-store/ )

**Description**

A Unix philosophy password manager by Jason Donenfeld (also the WireGuard author). `pass` stores each secret as a GPG-encrypted file under `~/.password-store/`, with a flat directory layout, plain-text filenames, and shell-scriptable get/insert/generate/edit commands. Many NixOS users keep their secrets outside of `agenix`/`sops-nix` entirely and just call `pass show my/host/secret` from a deploy script or a `preStart` hook. There is also a `pass` NixOS option (`programs.browserpass`) for browser integration, and home-manager has a `programs.password-store` module with package + git sync config.

**Tags**

`#secrets` `#password-manager` `#gpg` `#pass` `#cli`

---

#### gopass

**Website**

https://github.com/gopasspw/gopass

**Description**

A Go rewrite of `pass` with team features: git-backed stores, multiple "mounts" (sub-stores from different remotes), built-in JSON API for browser integration, OTP support, audit commands, and a richer CLI. gopass is fully `pass`-compatible at the storage layer (GPG-encrypted files in git) but adds the team-friendly ergonomics. NixOS users typically install it via the `gopass` package and pair it with `gopass-jsonapi` for browser autofill; secrets can then be pulled into systemd units via `LoadCredential=` or a `preStart` script.

**Tags**

`#secrets` `#password-manager` `#gpg` `#gopass` `#team`

---

#### rbw (Bitwarden CLI in Rust)

**Website**

https://github.com/doy/rbw

**Description**

An unofficial Bitwarden CLI written in Rust that is faster and more scriptable than the official `bitwarden-cli`. `rbw` supports agent mode (`rbw-agent`) so you unlock once and then `rbw get github-token` from any shell or systemd unit. For a homelab where secrets already live in a Bitwarden vault, `rbw` plus a small `ExecStartPre=` script (or a `LoadCredentialEncrypted=` pattern) is a viable alternative to agenix — secrets never touch the nix store, and Bitwarden is the source of truth.

**Tags**

`#secrets` `#bitwarden` `#cli` `#rust` `#password-manager`

---

#### Bitwarden CLI (`bitwarden-cli`)

**Website**

https://bitwarden.com/help/cli/  (nixpkgs package: `bitwarden-cli`)

**Description**

The official Bitwarden command-line client, packaged in nixpkgs as `bitwarden-cli`. It exposes the full Bitwarden vault over `bw list`, `bw get`, `bw sync` with a session-key unlock model. Heavier and slower than `rbw` but it is the canonical client and supports Bitwarden's official server as well as self-hosted Vaultwarden. Use it for ad-hoc pulls of secrets into NixOS configurations, or wrap it in a deploy-time script that renders an age-encrypted secrets file for `agenix`.

**Tags**

`#secrets` `#bitwarden` `#cli` `#vaultwarden`

---

#### Vaultwarden

**Website**

https://github.com/dani-garcia/vaultwarden

**Description**

An unofficial, Rust-based Bitwarden server API implementation that is self-hostable and resource-light. Vaultwarden is packaged in nixpkgs (`services.vaultwarden`) and is the standard way to run a self-hosted Bitwarden-compatible vault on a homelab NixOS machine. Combined with `rbw` or `bitwarden-cli`, this gives you an end-to-end self-hosted secrets workflow: Vaultwarden holds the vault, clients pull from it, and NixOS services render the pulled secrets into runtime files.

**Tags**

`#secrets` `#bitwarden` `#self-hosted` `#vaultwarden` `#nixos-module`

---

#### NixOS Wiki — Secrets management

**Website**

https://nixos.wiki/wiki/Secrets_management  (also: https://nixos.wiki/wiki/Agenix , https://nixos.wiki/wiki/Sops-nix )

**Description**

The community-maintained overview page that catalogs the available approaches (agenix, sops-nix, pass-with-Nix, nixos-rebuild build with secrets baked at deploy time, fetching secrets via systemd `LoadCredential=`, etc.) and links to each tool. A good first read before picking a secrets strategy — it also documents the common gotchas (secrets are not reproducible, so `nixos-rebuild build-vm` and `nix copy` need the secret files present, and the world-readable nix store means environment variables in `systemd.services.<name>.environment` are not secret).

**Tags**

`#secrets` `#nixos` `#documentation` `#wiki`

---

#### Comparison: agenix vs sops-nix

**Website**

agenix: https://github.com/ryantm/agenix  ·  sops-nix: https://github.com/Mic92/sops-nix

**Description**

Both tools solve the same problem (decrypt a build-time-encrypted secret on the host at activation time) and both can use the `age` backend, so the choice is largely about workflow. **agenix** uses one `.age` file per secret, edited with `agenix -e path.age`, and stores recipients in a sibling `secrets.nix` — it is minimal, has no extra file format, and is easier to reason about when each secret is independent. **sops-nix** uses a single YAML/JSON file holding many secrets, encrypts only values (so the structure is readable), supports cloud KMS alongside age/PGP, and offers richer per-secret options — better when you have dozens of related secrets, want to rotate keys across a fleet, or plan to graduate to Vault/KMS. Homelab convention: start with agenix if you have <10 secrets and a handful of hosts; reach for sops-nix if you want KMS, multi-backend, or a single browsable secrets file.

**Tags**

`#secrets` `#comparison` `#agenix` `#sops-nix` `#nixos`

---

### 22. Networking on NixOS

NixOS networking spans three layers: the kernel-level network configuration (`networking.useNetworkd`, `networking.firewall`, `networking.nftables`), overlay/mesh VPNs (WireGuard, Tailscale, Headscale, Nebula, ZeroTier, Firezone), and application-layer services such as DNS resolvers (unbound, CoreDNS, Knot, AdGuard Home), dynamic-DNS (ddclient), and reverse proxies (nginx, Caddy, Traefik, HAProxy, Cloudflare Tunnel). Almost all of these ship as first-class `services.*` modules in nixpkgs.

#### NixOS `networking.wireguard` module

**Website**

https://search.nixos.org/options?query=networking.wireguard  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/wireguard.nix )

**Description**

The in-tree WireGuard module, the canonical way to run WireGuard on NixOS. It supports interface declarations (`networking.wireguard.interfaces.wg0`), per-peer public-key/preshared-key/allowedIPs/endpoints, persistent keepalive, `postSetup`/`postShutdown` hooks, and automatic route/firewall insertion. Private keys can be supplied via a `config.age.secrets.wg-private.path` reference so the key never enters the store. This is the lowest-level, most flexible overlay option — you wire up your own site-to-site tunnels and/or road-warrior setup, and you own the routing and DNS story.

**Tags**

`#networking` `#wireguard` `#vpn` `#nixos` `#module`

---

#### WireGuard (upstream)

**Website**

https://www.wireguard.org/  (source: https://git.zx2c4.com/wireguard-tools/ )

**Description**

The WireGuard project itself — a modern, formally verified, in-kernel VPN protocol with a tiny attack surface, UDP-only transport, and crypto_routing-style handshakes. The Linux kernel implementation is upstream since 5.6; `wireguard-tools` (`wg`, `wg-quick`) is the userspace utility. NixOS hides most of this behind `networking.wireguard`, but the upstream site is the authoritative reference for protocol behavior, cross-platform clients, and `wg-quick`'s `PreUp`/`PostUp` script semantics.

**Tags**

`#networking` `#wireguard` `#vpn` `#protocol`

---

#### Tailscale

**Website**

https://tailscale.com/  (source: https://github.com/tailscale/tailscale )

**Description**

A mesh overlay network built on WireGuard with a coordination server that handles NAT traversal, key exchange, ACLs, MagicDNS, and HTTPS certificate issuance. Tailscale is the easiest path to "every homelab machine can reach every other machine regardless of where it sits" — install `services.tailscale.enable = true;`, `tailscale up`, and the host joins your tailnet. ACLs, tags, and SSH (Tailscale SSH) are managed from the admin console. Free for personal use up to 100 devices.

**Tags**

`#networking` `#tailscale` `#mesh-vpn` `#wireguard`

---

#### NixOS `services.tailscale` module

**Website**

https://search.nixos.org/options?query=services.tailscale  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix )

**Description**

The first-class NixOS module for Tailscale. Options include `services.tailscale.enable`, `services.tailscale.package`, `services.tailscale.extraUpFlags` (e.g. `--accept-routes`, `--advertise-exit-node`, `--ssh`), `services.tailscale.useRoutingFeatures` (controls `ip rule` capabilities for exit-node / subnet-router modes), and `services.tailscale.authKeyFile` for unattended onboarding via a pre-generated auth key stored as an agenix secret. This is the canonical module — older community modules (e.g. cole-h's, Mic92's experimental one) have been superseded by the in-tree implementation.

**Tags**

`#networking` `#tailscale` `#nixos` `#module`

---

#### Headscale

**Website**

https://github.com/juanfont/headscale

**Description**

An open-source, self-hostable implementation of the Tailscale control server, written in Go by Juan Font. Headscale speaks the same coordination protocol as Tailscale, so you can use unmodified Tailscale clients on every platform and pointed them at your own headscale instance via `--login-server`. It supports users, machines, pre-auth keys, ACLs, MagicDNS, and (experimentally) Taildrop. For a homelab that wants Tailscale's ergonomics without depending on the SaaS, Headscale + the official Tailscale client is the standard recipe.

**Tags**

`#networking` `#tailscale` `#self-hosted` `#headscale` `#mesh-vpn`

---

#### NixOS `services.headscale` module

**Website**

https://search.nixos.org/options?query=services.headscale  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/headscale.nix )

**Description**

The in-tree NixOS module that runs the Headscale server. Exposes `services.headscale.enable`, `services.headscale.settings` (a free-form attrset serialized to Headscale's YAML config: server URL, listen address, base domain for MagicDNS, ephemeral-node settings, ACL file path, etc.), and `services.headscale.port`. Pair it with a reverse proxy (Caddy or nginx) for TLS, point your tailnet clients at `https://headscale.example.com`, and you have a fully self-hosted Tailscale control plane.

**Tags**

`#networking` `#headscale` `#nixos` `#module` `#self-hosted`

---

#### Cloudflare Tunnel (`cloudflared`)

**Website**

https://github.com/cloudflare/cloudflared  (docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/ )

**Description**

Cloudflare's tunneling daemon: an outbound-only connection from your host to Cloudflare's edge that exposes your local services on the public internet via `https://<tunnel>.cfargotunnel.com` or your own domain, without opening any inbound ports. The daemon supports named tunnels with config files (YAML), ingress rules, and a `cloudflared access` client for zero-trust SSH/HTTP/RDP. Perfect for homelabs behind Carrier-Grade NAT or restrictive ISPs: your local nginx/Plex/HomeAssistant becomes reachable from anywhere with TLS terminated by Cloudflare.

**Tags**

`#networking` `#cloudflare` `#tunnel` `#reverse-proxy` `#zero-trust`

---

#### NixOS `services.cloudflared` module

**Website**

https://search.nixos.org/options?query=services.cloudflared  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/cloudflared.nix )

**Description**

The in-tree NixOS module for `cloudflared`. Supports both quick tunnels (`services.cloudflared.tunnel.token` — a single token from the Cloudflare dashboard runs a tunnel with no local config) and named tunnels (`services.cloudflared.tunnel.<name>.credentialsFile`, `services.cloudflared.tunnel.<name>.ingress` for routing rules). The credentials file is a JSON secret that should be supplied via agenix/sops-nix. A common homelab pattern is one named tunnel per host with an ingress rule per internal service.

**Tags**

`#networking` `#cloudflare` `#nixos` `#module` `#tunnel`

---

#### Nebula

**Website**

https://github.com/slackhq/nebula

**Description**

A scalable, peer-to-peer mesh overlay from Slack, designed for tens of thousands of hosts. Nebula uses certificates (signed by a CA you control) instead of pre-shared keys, performs NAT traversal over UDP with a configurable "lighthouse" host, and supports firewall rules in the cert itself. It is a good Tailscale alternative for users who want a fully self-hosted, cert-based mesh without depending on a coordination SaaS. Performance and scalability are competitive with WireGuard (it uses the Noise protocol under the hood).

**Tags**

`#networking` `#nebula` `#mesh-vpn` `#self-hosted` `#certificate-based`

---

#### NixOS `services.nebula` module

**Website**

https://search.nixos.org/options?query=services.nebula  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/nebula.nix )

**Description**

The in-tree NixOS module that runs one or more Nebula overlays. You configure a CA cert, per-host cert/key pair (typically via agenix), a lighthouse definition, and a list of static host mappings. The module supports multiple concurrent Nebula networks via `services.nebula.networks.<name>` attrsets, so a homelab can run separate overlays for "trusted" and "guest" networks on the same host.

**Tags**

`#networking` `#nebula` `#nixos` `#module`

---

#### ZeroTier

**Website**

https://www.zerotier.com/  (source: https://github.com/zerotier/ZeroTierOne )

**Description**

A software-defined networking overlay that abstracts the LAN across physical networks. ZeroTier uses its own (free for personal use) root servers for initial rendezvous but supports self-hosted moons/planets for lower latency. Clients join "networks" by network ID; the controller (running in the ZeroTier web admin, or self-hosted via `zerotier-controller`) authorizes members and assigns IPs. Layer-2 capable (so it carries non-IP protocols), which is unusual among overlays and occasionally useful for homelab VMs.

**Tags**

`#networking` `#zerotier` `#mesh-vpn` `#layer2` `#overlay`

---

#### NixOS `services.zerotierone` module

**Website**

https://search.nixos.org/options?query=services.zerotierone  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/zerotierone.nix )

**Description**

The in-tree NixOS module for the ZeroTier One daemon. Options include `services.zerotierone.enable`, `services.zerotierone.joinNetworks` (a list of network IDs to auto-join at boot), and `services.zerotierone.package`. The module creates the local ZeroTier controller socket; authorization of each node still happens on the controller side (web UI or API). For unattended joins, store an identity secret via agenix and supply it via `services.zerotierone.identitySecret`.

**Tags**

`#networking` `#zerotier` `#nixos` `#module`

---

#### Firezone

**Website**

https://www.firezone.dev/  (source: https://github.com/firezone/firezone )

**Description**

A self-hostable, WireGuard-based zero-trust access platform that adds user management, SSO (OIDC), device posture, and per-user DNS routing on top of WireGuard. Firezone has historically been packaged as a Docker Compose app; the newer "Firezone 1.0" Rust/Elixir rewrite is a single binary with a Postgres backend and is suitable for running on NixOS via `services.firezone` (community module) or as a systemd service. A good choice when you want Tailscale-style ACLs and SSO but need to self-host the entire stack.

**Tags**

`#networking` `#wireguard` `#zero-trust` `#firezone` `#self-hosted`

---

#### ddclient

**Website**

https://ddclient.net/  (source: https://github.com/ddclient/ddclient )

**Description**

A Perl-based dynamic-DNS updater that supports dozens of providers (Cloudflare, Route53, Gandi, Namecheap, Dynu, DuckDNS, etc.) via a small `ddclient.conf`. It periodically checks the host's public IP and pushes updates to the provider's API. For a homelab behind a dynamic-IP residential ISP, ddclient is the simplest way to keep `home.example.com` pointing at the right address so that the reverse proxy / Cloudflare Tunnel / WireGuard endpoint stays reachable.

**Tags**

`#networking` `#dns` `#dynamic-dns` `#ddclient`

---

#### NixOS `services.ddclient` module

**Website**

https://search.nixos.org/options?query=services.ddclient  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/ddclient.nix )

**Description**

The in-tree NixOS module that wraps ddclient. It accepts `services.ddclient.enable`, `services.ddclient.domain`, `services.ddclient.username`/`services.ddclient.passwordFile` (the latter should point to an agenix secret), `services.ddclient.protocol` (e.g. `cloudflare`), `services.ddclient.server`, and `services.ddclient.interval`. The module writes `/etc/ddclient.conf` and runs the daemon as a system user. A few lines of Nix is enough to keep a Cloudflare DNS record in sync with your home IP.

**Tags**

`#networking` `#dns` `#ddclient` `#nixos` `#module`

---

#### Knot DNS

**Website**

https://www.knot-dns.cz/  (source: https://gitlab.nic.cz/knot/knot-dns )

**Description**

An authoritative-only DNS server from CZ.NIC, optimized for high query rates and large zone files. Knot DNS supports DNSSEC signing with online key management, TSIG for zone transfers, Response Rate Limiting, and remote control over a Unix socket. In a homelab it is the right tool when you want to be authoritative for your own domain (e.g. serving `home.example.com` and `lab.example.com` records yourself, with DNSSEC), as opposed to running a recursive resolver.

**Tags**

`#networking` `#dns` `#authoritative-dns` `#dnssec` `#knot`

---

#### NixOS `services.knotd` module

**Website**

https://search.nixos.org/options?query=services.knotd  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/knot.nix )

**Description**

The in-tree NixOS module that runs the Knot DNS daemon (`knotd`). Options include `services.knotd.enable`, `services.knotd.package`, `services.knotd.extraArgs`, and `services.knotd.settings` — a free-form attrset that serializes to Knot's YAML configuration (server, listen interfaces, zones, ACLs, TSIG keys). Zone files themselves are typically stored under `/var/lib/knot` and managed with `knotc zone-begin`/`zone-commit` or via Git.

**Tags**

`#networking` `#dns` `#knot` `#nixos` `#module`

---

#### Knot Resolver

**Website**

https://www.knot-resolver.cz/  (source: https://gitlab.nic.cz/knot/knot-resolver )

**Description**

A caching, validating recursive resolver, also from CZ.NIC. Knot Resolver is built as a daemon with a Lua scripting layer that lets you intercept queries, rewrite responses, block ads/malware domains, and implement custom policies at runtime. For a homelab it is a strong alternative to Unbound or dnsmasq when you want both high performance and the ability to script per-domain behavior (e.g. split-horizon DNS for internal-only zones).

**Tags**

`#networking` `#dns` `#recursive-dns` `#knot` `#dnssec`

---

#### NixOS `services.knot-resolver` module

**Website**

https://search.nixos.org/options?query=services.knot-resolver  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/knot-resolver.nix )

**Description**

The in-tree NixOS module for Knot Resolver. Exposes `services.knot-resolver.enable`, `services.knot-resolver.instances` (a free-form attrset of named instances each with its own `listenAddresses`, `extraConfig` Lua, and `package`), and `services.knot-resolver.settings` for declarative YAML config. Multiple instances let you run, e.g., one resolver bound to the LAN interface for the household and another bound to a WireGuard interface for roaming clients, with different policies.

**Tags**

`#networking` `#dns` `#knot-resolver` `#nixos` `#module`

---

#### CoreDNS

**Website**

https://coredns.io/  (source: https://github.com/coredns/coredns )

**Description**

A plugin-based DNS server written in Go, descended from SkyDNS and used as the cluster DNS in Kubernetes. CoreDNS is configured via a single `Corefile` where each server block chains plugins (forward, cache, rewrite, etcd, file, auto, hosts, etc.). It is a great fit for a homelab that wants one DNS server handling split-horizon for internal services, conditional forwarding to upstream resolvers, and integration with service discovery (etcd, Consul) — all in a few lines of config.

**Tags**

`#networking` `#dns` `#coredns` `#go` `#service-discovery`

---

#### NixOS `services.coredns` module

**Website**

https://search.nixos.org/options?query=services.coredns  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/coredns.nix )

**Description**

The in-tree NixOS module for CoreDNS. Exposes `services.coredns.enable`, `services.coredns.config` (the full Corefile as a string), and `services.coredns.package`. Because CoreDNS is entirely Corefile-driven, this module is intentionally minimal — you write the Corefile as a multi-line Nix string and the module handles the systemd unit, user, and config file placement. A common pattern is to overlay CoreDNS on a WireGuard interface so all mesh clients use it for split-horizon DNS.

**Tags**

`#networking` `#dns` `#coredns` `#nixos` `#module`

---

#### dnsmasq

**Website**

https://thekelleys.org.uk/dnsmasq/doc.html  (source: https://thekelleys.org.uk/gitweb/?p=dnsmasq.git )

**Description**

A small, fast combined DNS forwarder, DHCP server, and TFTP server. dnsmasq is the classic "give every homelab machine a hostname and an address" tool: it serves local DNS records from `/etc/hosts` or a `hostsdir`, hands out DHCP leases with optional PXE/TFTP for network booting, and forwards everything else to an upstream resolver. Despite its age it remains the simplest correct answer for small home networks.

**Tags**

`#networking` `#dns` `#dhcp` `#tftp` `#dnsmasq`

---

#### NixOS `services.dnsmasq` module

**Website**

https://search.nixos.org/options?query=services.dnsmasq  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/dnsmasq.nix )

**Description**

The in-tree NixOS module for dnsmasq. Exposes `services.dnsmasq.enable`, `services.dnsmasq.settings` (a free-form attrset serialized to dnsmasq's INI-style config: `servers` upstream, `address`/`domain` overrides, DHCP ranges, etc.), and `services.dnsmasq.extraConfig` for raw config lines. A typical homelab config sets upstreams to a DoH/DoT-capable resolver, advertises the local `lab` domain, and hands out DHCP leases for the LAN segment.

**Tags**

`#networking` `#dns` `#dhcp` `#dnsmasq` `#nixos` `#module`

---

#### unbound

**Website**

https://nlnetlabs.nl/projects/unbound/about/  (source: https://github.com/NLnetLabs/unbound )

**Description**

A validating, recursive, caching DNS resolver from NLnet Labs. Unbound implements DNSSEC validation, prefetching, query-name minimization (RFC 7816), and aggressive NSEC caching. It is the most common "I want a real recursive resolver at home" choice — pair it with `pi-hole`-style block lists via `unbound`'s `local-zone`/`include:` directives, or front it with `dnscrypt-proxy` for encrypted upstream transport. Its Python and DNS-over-TLS/HTTPS support make it a good fit for privacy-focused homelabs.

**Tags**

`#networking` `#dns` `#recursive-dns` `#dnssec` `#unbound`

---

#### NixOS `services.unbound` module

**Website**

https://search.nixos.org/options?query=services.unbound  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/unbound.nix )

**Description**

The in-tree NixOS module for unbound. Exposes `services.unbound.enable`, `services.unbound.settings` (a free-form attrset serialized to unbound's YAML config), `services.unbound.resolveLocalQueries` (auto-configures the host to use the local unbound), and `services.unbound.allowedAccess` (the ACL list of upstreams allowed to query the resolver). A common homelab setup enables unbound on the router with `allowedAccess` covering the LAN and WireGuard subnets, plus `local-zone` entries for internal domains.

**Tags**

`#networking` `#dns` `#unbound` `#nixos` `#module`

---

#### AdGuard Home

**Website**

https://github.com/AdguardTeam/AdGuardHome

**Description**

A network-wide ad and tracker blocking DNS server with a web UI. AdGuard Home runs as a single binary, serves DNS (with optional DoH/DoT/DoQ upstreams and clients), provides DHCP, and exposes per-client blocklists, query logs, parental controls, and a "rewrites" panel for local DNS names. It is the spiritual successor to Pi-hole for many homelabs because it's a single Go binary with no PHP runtime and a cleaner UI.

**Tags**

`#networking` `#dns` `#adblocking` `#dhcp` `#adguard`

---

#### NixOS `services.adguardhome` module

**Website**

https://search.nixos.org/options?query=services.adguardhome  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/adguardhome.nix )

**Description**

The in-tree NixOS module for AdGuard Home. Exposes `services.adguardhome.enable`, `services.adguardhome.settings` (a free-form attrset serialized to AdGuard Home's YAML config — filters, upstreams, DHCP, rewrites), `services.adguardhome.mutableSettings` (whether the running config can be overwritten from the UI), and `services.adguardhome.host`/`port` for the admin interface. A 10-line Nix module invocation gives you a fully featured network-wide adblocker on `http://router:3000`.

**Tags**

`#networking` `#dns` `#adblocking` `#adguard` `#nixos` `#module`

---

#### dnscrypt-proxy

**Website**

https://github.com/DNSCrypt/dnscrypt-proxy

**Description**

A flexible DNS proxy that supports DNSCrypt, DNS-over-HTTPS, and DNS-over-TLS to upstream resolvers, with built-in anonymized relay routing, query logging, cloaking (local overrides), and blacklist/whitelist files. In a homelab it is typically used in front of dnsmasq or unbound as the encrypted-transport hop to a privacy-friendly upstream (Quad9, Cloudflare, Mullvad, a self-hosted DoH server).

**Tags**

`#networking` `#dns` `#dnscrypt` `#doh` `#dot` `#privacy`

---

#### blocky

**Website**

https://github.com/0xERR0R/blocky

**Description**

A fast, Go-based DNS proxy and ad-blocker with first-class Prometheus metrics, multiple upstream resolvers (with conditional routing by client/domain), blocklists from URL or file, Redis caching, DoH/DoT/DoQ listener support, and a query-log API. blocky is a good "modern AdGuard Home / Pi-hole" alternative for homelabs that already run Prometheus and want to graph DNS activity.

**Tags**

`#networking` `#dns` `#adblocking` `#prometheus` `#blocky`

---

#### Pi-hole

**Website**

https://pi-hole.net/  (source: https://github.com/pi-hole/pi-hole )

**Description**

The long-standing network-wide ad blocker: a bundled FTL DNS engine (dnsmasq-derived) plus a PHP/web UI and a CLI. Pi-hole is not packaged as a first-class NixOS module (its installer assumes a Debian-style filesystem layout), but it runs cleanly inside a NixOS OCI container (`virtualisation.oci-containers.containers.pihole`) backed by Podman or Docker. Use it when you want the Pi-hole UI/ecosystem rather than AdGuard Home or blocky.

**Tags**

`#networking` `#dns` `#adblocking` `#pihole` `#container`

---

#### Kea DHCP (ISC Kea)

**Website**

https://www.isc.org/kea/  (source: https://gitlab.isc.org/isc-projects/kea )

**Description**

ISC's modern DHCPv4/DHCPv6/DDNS server, the official successor to ISC DHCP (which is end-of-life in 2022). Kea is configured via JSON, supports MySQL/PostgreSQL lease backends, high-availability pairs, client classification, and dynamic host reservations. For a NixOS router that wants a serious DHCP server (multiple subnets, reservations, failover), Kea is the recommended modern choice over `services.dhcpd4`.

**Tags**

`#networking` `#dhcp` `#kea` `#isc` `#ipv6`

---

#### NixOS `services.kea` module

**Website**

https://search.nixos.org/options?query=services.kea  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/kea.nix )

**Description**

The in-tree NixOS module for Kea. Exposes `services.kea.dhcp4.enable`/`dhcp6.enable`/`ddns.enable`, each with a `settings` attrset serialized to Kea's JSON config (`interfaces-config`, `subnet4`, `reservations`, `lease-database`, etc.). Multiple daemons can run side by side, and the JSON config can be supplied inline in Nix or pointed at via `configFile` for a hand-maintained copy.

**Tags**

`#networking` `#dhcp` `#kea` `#nixos` `#module`

---

#### nginx

**Website**

https://nginx.org/  (source: https://github.com/nginx/nginx )

**Description**

The dominant open-source HTTP server and reverse proxy. NixOS uses nginx as the default for many web-facing services (Nextcloud, Grafana, Jellyfin, etc.) via `services.nginx.virtualHosts`. It supports TLS termination, HTTP/3, WebSocket, streaming, custom Lua (with `nginxModules`), and upstream load balancing. For a homelab reverse proxy, nginx is the most documented, most battle-tested option but also the most verbose to configure by hand.

**Tags**

`#networking` `#reverse-proxy` `#http` `#nginx` `#tls`

---

#### NixOS `services.nginx` module

**Website**

https://search.nixos.org/options?query=services.nginx  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/nginx/default.nix )

**Description**

The in-tree NixOS module for nginx. Exposes `services.nginx.enable`, `services.nginx.virtualHosts.<name>` (each with `locations`, `forceSSL`, `enableACME` for auto Let's Encrypt via `security.acme`, `basicAuth` files, etc.), `services.nginx.recommendedTlsSettings`/`recommendedGzipSettings`/`recommendedProxySettings` (sane defaults), and `services.nginx.upstreams`. This module is the glue for most TLS-terminated homelab stacks on NixOS.

**Tags**

`#networking` `#reverse-proxy` `#nginx` `#nixos` `#module` `#tls`

---

#### Caddy

**Website**

https://caddyserver.com/  (source: https://github.com/caddyserver/caddy )

**Description**

A modern HTTP server written in Go that focuses on automatic HTTPS by default — it obtains and renews Let's Encrypt / ZeroSSL certificates transparently, supports HTTP/3 out of the box, and is configured via a small "Caddyfile" DSL. Caddy is the easiest reverse proxy for a homelab: write a five-line Caddyfile (`grafana.lab.com { reverse_proxy localhost:3000 }`) and you have a TLS-terminated, HTTP/3-enabled site with auto-renewing certs.

**Tags**

`#networking` `#reverse-proxy` `#http` `#caddy` `#automatic-https`

---

#### NixOS `services.caddy` module

**Website**

https://search.nixos.org/options?query=services.caddy  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/caddy/default.nix )

**Description**

The in-tree NixOS module for Caddy. Exposes `services.caddy.enable`, `services.caddy.virtualHosts.<name>.extraConfig` (per-site Caddyfile blocks), `services.caddy.config` (the full Caddyfile as a string), `services.caddy.package` (custom Caddy builds via `caddyPlugins` or `caddy.withPlugins`), and `services.caddy.acmeCA`/`email` for controlling the ACME directory. The module also automatically opens the right firewall ports and supplies the user Caddy runs as.

**Tags**

`#networking` `#reverse-proxy` `#caddy` `#nixos` `#module` `#acme`

---

#### Traefik

**Website**

https://github.com/traefik/traefik  (docs: https://doc.traefik.io/traefik/ )

**Description**

A dynamic, cloud-native reverse proxy that discovers backends from labels (Docker, Podman, Consul, Kubernetes, etc.) and reloads without restarts. Traefik supports Let's Encrypt ACME, HTTP/3, mTLS, and a dashboard UI. For a homelab that runs many containers with frequently-changing services, Traefik's label-based routing is more ergonomic than hand-editing nginx/Caddy configs — you set labels on the container, Traefik picks it up automatically.

**Tags**

`#networking` `#reverse-proxy` `#http` `#traefik` `#container-native`

---

#### NixOS `services.traefik` module

**Website**

https://search.nixos.org/options?query=services.traefik  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/traefik.nix )

**Description**

The in-tree NixOS module for Traefik. Exposes `services.traefik.enable`, `services.traefik.staticConfigOptions` and `services.traefik.dynamicConfigOptions` (free-form attrsets serialized to Traefik's YAML/TOML config — entrypoints, certificates resolvers, routers, services, middlewares), and `services.traefik.package`. The whole Traefik configuration can be expressed in Nix, which is particularly nice when paired with `virtualisation.oci-containers` for label-driven routing.

**Tags**

`#networking` `#reverse-proxy` `#traefik` `#nixos` `#module`

---

#### HAProxy

**Website**

https://www.haproxy.org/  (source: https://github.com/haproxy/haproxy )

**Description**

A high-performance TCP/HTTP load balancer and reverse proxy. HAProxy is the right choice when you need advanced load-balancing algorithms (leastconn, source hashing, consistent hashing), slow-loris protection, detailed stats endpoints, and TCP-level (Layer 4) routing — capabilities that nginx/Caddy/Traefik handle less ergonomically. For a homelab it is overkill for serving a couple of HTTPS sites, but very useful in front of a Kubernetes API, a Redis cluster, or a Galera database.

**Tags**

`#networking` `#reverse-proxy` `#load-balancer` `#haproxy` `#tcp`

---

#### NixOS `services.haproxy` module

**Website**

https://search.nixos.org/options?query=services.haproxy  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/haproxy.nix )

**Description**

The in-tree NixOS module for HAProxy. Exposes `services.haproxy.enable`, `services.haproxy.config` (the full HAProxy CFG as a string), `services.haproxy.package`, and `services.haproxy.extraConfig` for appended directives. Because HAProxy config is so dense, most NixOS users keep the config as a heredoc string in their flake rather than building it from a Nix attrset. The module handles the systemd unit, the runtime user, and chroot setup.

**Tags**

`#networking` `#reverse-proxy` `#haproxy` `#nixos` `#module`

---

#### systemd-networkd (`networking.useNetworkd`)

**Website**

https://systemd.io/NETWORKD/  (NixOS manual: https://nixos.org/manual/nixos/stable/#sec-networking )

**Description**

systemd's native network configuration daemon: it reads `.network`/`.netdev`/`.link` files (or declarative equivalents) and brings up interfaces, VLANs, bridges, bonds, and routes. NixOS exposes it via `networking.useNetworkd = true;` plus `systemd.network.netdevs.<name>` and `systemd.network.networks.<name>` attrsets. It is the modern alternative to scripted `ip` calls in `networking.interfaces` and is strongly recommended for routers, multi-NIC hosts, VLAN trunks, and bridged VM hosts.

**Tags**

`#networking` `#systemd-networkd` `#nixos` `#routing` `#vlan`

---

#### NetworkManager

**Website**

https://networkmanager.dev/  (source: https://gitlab.freedesktop.org/NetworkManager/NetworkManager )

**Description**

The standard Linux daemon for managing network connections on desktop and mobile systems. NetworkManager provides a D-Bus API, a CLI (`nmcli`), a TUI (`nmtui`), and connections stored as keyfiles. On NixOS it is enabled via `networking.networkmanager.enable = true;` and is the default for graphical workstations/laptops where the user may roam between Ethernet, WiFi, and VPNs. Server roles typically prefer `systemd-networkd` or static `networking.interfaces` instead.

**Tags**

`#networking` `#networkmanager` `#wifi` `#desktop` `#nixos`

---

#### NixOS `networking.firewall` (iptables/nftables frontend)

**Website**

https://search.nixos.org/options?query=networking.firewall  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/firewall.nix )

**Description**

The high-level NixOS firewall abstraction that opens ports (`networking.firewall.allowedTCPPorts`, `allowedUDPPorts`, `allowedTCPPortRanges`) and supports `networking.firewall.interfaces.<ifname>` for per-interface rules. Under the hood it generates iptables or nftables rules depending on `networking.nftables.enable`. This is the first stop for "I started a service, why can't I reach it?" — open the port here, and the module handles the rest.

**Tags**

`#networking` `#firewall` `#iptables` `#nixos` `#module`

---

#### NixOS `networking.nftables`

**Website**

https://search.nixos.org/options?query=networking.nftables  (source: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/nftables.nix )

**Description**

The modern Linux packet-filtering framework (successor to iptables), exposed in NixOS via `networking.nftables.enable = true;`. Enabling it switches the firewall backend from iptables to nftables and unlocks `networking.nftables.ruleset` (a full declarative nftables ruleset as a string) and `networking.nftables.tables.<name>` for per-table declarations. Recommended for new deployments: nftables is faster, has cleaner syntax, and is the upstream direction for Linux firewalls.

**Tags**

`#networking` `#firewall` `#nftables` `#nixos` `#module`

---

#### OpenVPN

**Website**

https://openvpn.net/  (source: https://github.com/OpenVPN/openvpn )

**Description**

The classic SSL/TLS-based VPN. OpenVPN is older and heavier than WireGuard but supports TCP transport (useful behind restrictive firewalls), TLS-crypt, username/password auth, and per-client config in a way that some setups still prefer. NixOS exposes it via `services.openvpn.servers.<name>` and `services.openvpn.instances.<name>` attrsets, with the certificate/key material typically supplied via agenix. Still common for "road warrior" VPNs that need to traverse odd networks where WireGuard's UDP gets blocked.

**Tags**

`#networking` `#openvpn` `#vpn` `#tls` `#nixos`

---

#### NixOS networking chapter (manual)

**Website**

https://nixos.org/manual/nixos/stable/#sec-networking

**Description**

The official NixOS manual's networking chapter, covering `networking.interfaces`, `networking.bridges`, `networking.vlans`, `networking.bonds`, `networking.wireless`, `networking.firewall`, `networking.useDHCP`, and `networking.useNetworkd`. The right first read before reaching for any third-party module — most homelab networking needs (a bridge for libvirt, a VLAN for IoT, a bond for a dual-NIC server) are answered by stock NixOS options documented here.

**Tags**

`#networking` `#nixos` `#documentation` `#manual`

---

#### Quick reference — picking a secrets/networking stack

**Website**

(secrets) https://nixos.wiki/wiki/Secrets_management  ·  (overlay VPNs) https://nixos.org/manual/nixos/stable/#sec-networking

**Description**

A condensed "decision tree" for homelab operators: (1) **Secrets** — single host, <10 secrets → `agenix`; multi-host fleet → `agenix-rekey` (or `sops-nix` if you want one file/JSON browsing); cloud KMS or Vault already in use → `sops-nix` with KMS backend or `services.vault` + `services.vault-agent`; ad-hoc personal password store → `pass`/`gopass`/`rbw` outside Nix. (2) **Mesh VPN** — easiest ergonomics → Tailscale; self-hosted Tailscale → Headscale; fully self-hosted cert-based mesh → Nebula; layer-2 capabilities → ZeroTier; SSO + ACLs self-hosted → Firezone. (3) **Reverse proxy** — auto-HTTPS, simple DSL → Caddy; label-driven container routing → Traefik; max flexibility / battle-tested → nginx; TCP load balancing → HAProxy; no inbound ports → Cloudflare Tunnel. (4) **DNS** — recursive resolver → unbound; adblocking + UI → AdGuard Home; authoritative → Knot DNS; plugin/scriptable → CoreDNS or Knot Resolver; tiny DHCP+DNS → dnsmasq.

**Tags**

`#secrets` `#networking` `#comparison` `#homelab` `#nixos`


---

## Part V — Reverse Proxies & Containers

### 23. Reverse Proxies & TLS Termination on NixOS

NixOS ships first-class modules for every popular reverse proxy and TLS terminator, all configurable through `services.*` options that produce reproducible, declarative configurations. The same `security.acme` infrastructure backs automatic Let's Encrypt issuance for any of them.

#### Traefik (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.traefik

**Description**

The NixOS `services.traefik` module runs the modern Traefik reverse proxy as a systemd service with configuration supplied via `services.traefik.staticConfigOptions` and `services.traefik.dynamicConfigOptions` (YAML/TOML-as-Nix attrs) or `services.traefik.staticConfigFile` / `dynamicConfigFile` for file-based configs. Use it in a homelab as the single entry point for HTTP/HTTPS traffic to dozens of containerised services, leveraging automatic Let's Encrypt certificates, the Dashboard, and file/Docker/Consul providers.

**Tags**

`#reverse-proxy` `#tls` `#traefik` `#nixos-module` `#homelab`

---

#### Traefik (upstream project)

**Website**

https://traefik.io/  (source: https://github.com/traefik/traefik)

**Description**

Traefik is the open-source, cloud-native reverse proxy and load balancer written in Go that auto-discovers services from Docker, Kubernetes, Podman, Consul, and file providers. The NixOS module only wraps the upstream binary, so consulting the upstream docs is essential because the module exposes a thin layer over Traefik's own configuration schema.

**Tags**

`#reverse-proxy` `#tls` `#traefik` `#load-balancer`

---

#### Caddy (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.caddy

**Description**

The `services.caddy` module runs the Caddy web server with configuration via either `services.caddy.config` (Caddyfile syntax as a multiline string) or `services.caddy.virtualHosts` (a Nix attrset that compiles to a Caddyfile). Caddy automatically obtains and renews Let's Encrypt certificates, so for a homelab it is the lowest-effort path to HTTPS for a personal domain.

**Tags**

`#reverse-proxy` `#tls` `#caddy` `#nixos-module` `#acme`

---

#### nixos-caddy-utils

**Website**

https://github.com/vidbina/nixos-caddy-utils  (unverified — confirm the repo exists before depending on it)

**Description**

A community flake attributed to vidbina that adds helper functions around the upstream NixOS `services.caddy` module, intended to reduce boilerplate when declaring many virtual hosts with shared TLS defaults and access-log conventions. Treat as a convenience layer only; the built-in `services.caddy.virtualHosts` is sufficient for most homelabs and is what you should reach for first.

**Tags**

`#caddy` `#nixos-module` `#flake` `#unverified`

---

#### nginx (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.nginx  (wiki: https://nixos.wiki/wiki/Nginx)

**Description**

The `services.nginx` module configures the venerable nginx web server. The homelab workhorse pattern is `services.nginx.virtualHosts.<name> = { enableACME = true; addSSL = true; locations."/" = { proxyPass = "..."; proxyWebsockets = true; }; }` combined with the `recommended*` options for sane TLS, gzip, and proxy headers.

**Tags**

`#reverse-proxy` `#tls` `#nginx` `#nixos-module` `#homelab`

---

#### nginx Recommended Settings (NixOS options)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.nginx.recommended

**Description**

The `services.nginx.recommendedTlsSettings`, `recommendedProxySettings`, `recommendedGzipSettings`, `recommendedOptimisation`, and `recommendedBrotliSettings` options turn on a curated set of nginx defaults that follow modern best practices. Enabling all four is a one-liner that hardens a fresh homelab reverse proxy with sensible timeouts, headers, and TLS parameters without writing dozens of directives by hand.

**Tags**

`#nginx` `#nixos-module` `#tls` `#best-practices`

---

#### HAProxy (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.haproxy

**Description**

The `services.haproxy` module runs HAProxy with configuration supplied via `services.haproxy.config` (the full HAProxy config file as a string). HAProxy excels at L4/L7 TCP and HTTP load balancing and is a good pick for a homelab that needs to balance traffic across multiple backend instances of a service or terminate TLS for non-HTTP protocols (e.g., database connection pooling).

**Tags**

`#reverse-proxy` `#load-balancer` `#haproxy` `#nixos-module`

---

#### sniproxy (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.sniproxy

**Description**

The `services.sniproxy` module runs the SNIProxy daemon, which inspects the TLS SNI field of incoming connections and routes them to different backends based on the requested hostname — without terminating TLS. In a homelab it is the right tool when you have a single public IP and a single port 443 but want to forward different hostnames to different internal TLS-terminating servers (e.g., a Caddy host and a separate internal service that holds its own cert).

**Tags**

`#reverse-proxy` `#tls` `#sni` `#sniproxy` `#nixos-module`

---

#### sniproxy (upstream project)

**Website**

https://github.com/dlundquist/sniproxy

**Description**

The upstream SNIProxy project by Dustin Lundquist — a server that proxies incoming TCP connections based on the TLS Server Name Indication extension. The NixOS `services.sniproxy.config` string is the upstream config file format verbatim.

**Tags**

`#reverse-proxy` `#tls` `#sni` `#sniproxy`

---

#### hitch (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.hitch

**Description**

The `services.hitch` module runs Hitch, a scalable TLS proxy that terminates TLS and forwards plain TCP to a backend (typically Varnish or nginx). Use it in a homelab when you want a dedicated, high-throughput TLS terminator in front of a non-TLS or HTTP/2-agnostic backend, or when you want OCSP stapling and OpenSSL/BoringSSL flexibility without modifying the backend.

**Tags**

`#tls` `#tls-termination` `#hitch` `#nixos-module`

---

#### hitch (upstream project)

**Website**

https://github.com/varnish/hitch  (docs: https://hitch-tls.org/)

**Description**

Hitch is a libev-based, scalable TLS proxy developed by the Varnish Cache community. The NixOS `services.hitch.configFile` option takes the upstream hitch configuration file verbatim, and `services.hitch.extraConfig` lets you append directives.

**Tags**

`#tls` `#tls-termination` `#hitch` `#varnish`

---

#### oauth2-proxy (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.oauth2-proxy

**Description**

The `services.oauth2-proxy` module runs oauth2-proxy, which sits in front of an internal web service and gates access behind OAuth/OIDC login (Google, GitHub, Keycloak, Authentik, etc.). In a homelab it is the easiest way to put a single sign-on wall in front of services like Grafana, Portainer, or admin UIs that lack their own auth.

**Tags**

`#reverse-proxy` `#authentication` `#oauth2-proxy` `#sso` `#nixos-module`

---

#### Authentik (NixOS module / flake)

**Website**

https://goauthentik.io/  (source: https://github.com/goauthentik/authentik)

**Description**

Authentik is an open-source identity provider / SSO platform that can act as an OAuth2/OIDC provider, SAML IdP, and LDAP provider, and ships a "proxy provider" outpost that fronts arbitrary HTTP services the same way oauth2-proxy does (this is the "authentik-forward-proxy" outpost). The official NixOS module is published by the authentik project — add `authentik` to your flake inputs and import its `nixosModules.default` — but always verify the current import path against the upstream README, as the integration story has evolved.

**Tags**

`#authentication` `#sso` `#authentik` `#reverse-proxy` `#identity-provider`

---

#### sslh (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.sslh

**Description**

The `services.sslh` module runs sslh, a protocol-demultiplexer that inspects the first bytes of an incoming connection on a single port (typically 443) and forwards it to SSH, HTTP(S), OpenVPN, XMPP, tinc, etc., based on protocol fingerprint. In a homelab behind a single forwarded port it is the canonical trick to share 443 between an SSH daemon and a reverse proxy.

**Tags**

`#networking` `#protocol-mux` `#sslh` `#nixos-module` `#homelab`

---

#### stunnel (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.stunnel

**Description**

The `services.stunnel` module runs stunnel, which wraps arbitrary TCP connections in TLS — useful as either a TLS-terminating front-end for a non-TLS backend or as a TLS-encrypting client for a legacy service. In a homelab it is a quick way to expose an insecure internal service (e.g., a plain-text IRC daemon or legacy exporter) over TLS without modifying the service itself.

**Tags**

`#tls` `#tls-termination` `#stunnel` `#nixos-module`

---

### 24. Containers & Virtualisation on NixOS

NixOS supports the full spectrum of container and VM runtimes — from rootless OCI runtimes and declarative nspawn machines to Firecracker microVMs orchestrated by microvm.nix — and lets you build OCI images directly from the Nix store via `pkgs.dockerTools` and friends, with no Dockerfile or daemon required.

#### Docker (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.docker  (wiki: https://nixos.wiki/wiki/Docker)

**Description**

The `virtualisation.docker` module enables the Docker Engine — daemon, CLI, and (optionally) docker-compose. Set `virtualisation.docker.enable = true;` for the system daemon or enable rootless mode for unprivileged users. Common homelab knobs include `virtualisation.docker.liveRestore`, `autoPrune.enable`, `storageDriver`, and `daemon.settings` (for registry-mirror and log-driver configuration).

**Tags**

`#containers` `#docker` `#nixos-module` `#oci` `#homelab`

---

#### Docker Rootless (NixOS option)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.docker.rootless

**Description**

The `virtualisation.docker.rootless.enable` option runs the Docker daemon entirely in user namespaces, so containers run without root privileges on the host. This is the recommended mode for a multi-user homelab or any internet-exposed host, because a container escape lands the attacker in an unprivileged user namespace rather than as host root. Pair with `setSocketVariable = true` to export `DOCKER_HOST` for the user.

**Tags**

`#containers` `#docker` `#rootless` `#security` `#nixos-module`

---

#### dockerTools (pkgs.dockerTools)

**Website**

https://nixos.org/manual/nixpkgs/unstable/#sec-pkgs-dockerTools  (source: https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support/docker)

**Description**

`pkgs.dockerTools` is the in-tree Nix library for building OCI/Docker images straight from Nix derivations — no Dockerfile, no Docker daemon required. Key functions are `buildImage`, `buildLayeredImage` (multi-layer with reproducible layer hashes), `streamLayeredImage` (streams the image to stdout without materialising a tarball), and `pullImage`. For a homelab it lets you produce a single, bit-for-bit reproducible image of an internal service and ship it to your private registry.

**Tags**

`#containers` `#docker` `#image-build` `#reproducible` `#nixpkgs`

---

#### arion (hercules-ci/arion)

**Website**

https://github.com/hercules-ci/arion  (docs: https://docs.hercules-ci.com/arion/)

**Description**

Arion is a docker-compose replacement that runs containers via the Nix container-orchestration tooling while letting you declare services in Nix. Its killer feature is that host-side configuration (users, secrets, kernel modules) lives in the same Nix module as the container list, so a homelab host and its container fleet can be configured as one flake. Existing `docker-compose.yml` files can be inspected with `arion cat` to bootstrap a migration.

**Tags**

`#containers` `#docker-compose` `#arion` `#flake` `#orchestration`

---

#### nix2container (nlewo/nix2container)

**Website**

https://github.com/nlewo/nix2container

**Description**

nix2container is an alternative to `pkgs.dockerTools` that produces OCI images by writing JSON layer manifests and copying store paths into tarballs lazily, which makes image builds dramatically faster and smaller than `buildLayeredImage`. It exposes `buildImage`, `pullImage`, and a `buildLayeredImage`-equivalent helper. In a homelab with CI, switching from dockerTools to nix2container is a common one-line performance win for image builds.

**Tags**

`#containers` `#oci` `#image-build` `#nix2container` `#flake`

---

#### nixpacks

**Website**

https://github.com/railwayapp/nixpacks  (docs: https://nixpacks.com/)

**Description**

Nixpacks takes an app directory (Node, Python, Go, Rust, etc. code) and produces a reproducible OCI image using Nix under the hood, with auto-detected build and start commands — think "buildpacks, but powered by Nix." Useful in a homelab as a Heroku-style "just point it at a repo and get a runnable image" tool, especially for projects where you don't want to write a Dockerfile or a Nix expression by hand.

**Tags**

`#containers` `#oci` `#image-build` `#buildpacks` `#nixpacks`

---

#### Podman (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.podman  (wiki: https://nixos.wiki/wiki/Podman)

**Description**

The `virtualisation.podman` module enables Podman, the daemonless, rootless-by-default OCI container engine that is a near drop-in replacement for Docker. Pair it with `virtualisation.podman.dockerCompat = true` (creates a `docker` alias to `podman`) and `virtualisation.podman.defaultNetwork.settings.dns_enabled = true` so containers can resolve each other by name on the default podman network.

**Tags**

`#containers` `#podman` `#oci` `#rootless` `#nixos-module`

---

#### Podman Rootless (NixOS options)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.podman.rootless

**Description**

The `virtualisation.podman.rootless.enable` option enables the rootless Podman service for a given user, including the user-level systemd units (`podman.socket`, `podman.service`) and the `containers.conf` configuration. This is the default model for Podman and the right choice for a homelab where one or more unprivileged users run their own container stacks.

**Tags**

`#containers` `#podman` `#rootless` `#security` `#nixos-module`

---

#### Quadlet (Podman systemd integration)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.quadlet  (upstream: https://github.com/containers/quadlet)

**Description**

Quadlet is Podman's mechanism for declaring containers as systemd units via `.container`, `.volume`, `.network`, and `.kube` files under `/etc/containers/systemd/` (or `~/.config/containers/systemd/` for rootless). NixOS exposes it through `virtualisation.quadlet` and the `virtualisation.quadlet.containers`, `.networks`, and `.volumes` attrsets, which let you declare a container fleet in Nix and have NixOS generate the Quadlet unit files for you — a clean replacement for `docker-compose`+systemd glue.

**Tags**

`#containers` `#podman` `#quadlet` `#systemd` `#nixos-module`

---

#### Incus (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.incus  (upstream: https://github.com/lxc/incus)

**Description**

Incus is the Linux Containers project's successor to LXD — a system container and VM manager that offers a REST API and CLI for both LXC system containers and full VMs. The `virtualisation.incus.enable` module installs the Incus daemon and CLI; pair with `virtualisation.incus.ui.enable = true` for the web UI and `virtualisation.incus.lxcfs.enable = true` for /proc view-based container resource accounting. The recommended choice for a homelab that wants "one tool for both VMs and system containers."

**Tags**

`#containers` `#virtualisation` `#incus` `#lxc` `#nixos-module`

---

#### LXD (DEPRECATED — superseded by Incus)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.lxd  (upstream: https://github.com/canonical/lxd)

**Description**

⚠️ DEPRECATED. LXD was the Canonical-led system container and VM manager; after Canonical's licensing change in 2023 the project was forked by the Linux Containers team as Incus, and upstream LXD development has since moved to a closed-source model. The NixOS `virtualisation.lxd` module was deprecated and removed from recent NixOS releases (consult the NixOS release notes for the exact version). Existing deployments should migrate to `virtualisation.incus` using the `lxd-to-incus` migration tool shipped with Incus.

**Tags**

`#containers` `#virtualisation` `#lxd` `#deprecated` `#incus`

---

#### systemd-nspawn — Declarative (`containers.<name>`)

**Website**

https://search.nixos.org/options?channel=unstable&query=containers  (manual: https://nixos.org/manual/nixos/unstable/#sec-declarative-containers)

**Description**

The `containers.<name>` NixOS attrset spins up additional NixOS instances running under `systemd-nspawn`, sharing the host kernel but with their own users, network, services, and (optionally) root filesystem. A declarative container's configuration lives inside the host's `configuration.nix`, so a homelab host can host a Postgres container, a reverse-proxy container, and a CI runner container as reproducible sub-NixOS systems without writing a Dockerfile.

**Tags**

`#containers` `#systemd-nspawn` `#declarative` `#nixos-module` `#homelab`

---

#### systemd-nspawn — Imperative (machinectl)

**Website**

https://nixos.org/manual/nixos/unstable/#sec-imperative-containers  (upstream: https://www.freedesktop.org/software/systemd/man/machinectl.html)

**Description**

NixOS also supports imperative nspawn containers created on the fly via `nixos-container create <name>` and managed through `machinectl` (`machinectl list`, `machinectl shell`, `machinectl start/stop`). Useful when you want a one-off sandboxed NixOS environment that you can mutate at runtime without rebuilding the host, while still inheriting the host's channels/flake inputs.

**Tags**

`#containers` `#systemd-nspawn` `#machinectl` `#nixos` `#imperative`

---

#### microvm.nix (astro/microvm.nix)

**Website**

https://github.com/astro/microvm.nix

**Description**

microvm.nix is a Nix flake by Astro (Jonas Jelten) that builds declarative, ephemeral microVMs from NixOS configurations and runs them on one of several backends: `cloud-hypervisor`, `firecracker`, `crosvm`, `qemu`, `stracciatella`, or `alioxfirecracker`. In a homelab it is the natural way to run multiple isolated NixOS systems on a single host with per-VM disk, network, and flake pinning — service isolation without the overhead of full libvirt VMs.

**Tags**

`#virtualisation` `#microvm` `#firecracker` `#flake` `#nixos`

---

#### Firecracker (via microvm.nix)

**Website**

https://github.com/firecracker-microvm/firecracker

**Description**

Firecracker is Amazon's minimal, Rust-based VMM designed for short-lived microVMs with very low memory footprint and sub-second boot. NixOS does not ship a standalone `services.firecracker` module, but microvm.nix uses Firecracker as one of its backends — set `microvm.hypervisor = "firecracker"` on a microvm.nix module to run that NixOS guest under Firecracker.

**Tags**

`#virtualisation` `#firecracker` `#microvm` `#vmm` `#rust`

---

#### crosvm (via microvm.nix)

**Website**

https://crosvm.dev/book/  (source: https://chromium.googlesource.com/crosvm/crosvm/)

**Description**

crosvm is the Chrome OS virtual machine monitor, written in Rust, that backs Chrome OS's Linux app support and Android's virtualization. Like Firecracker, NixOS uses it via microvm.nix by setting `microvm.hypervisor = "crosvm"`. It is a good middle ground when you want a lightweight, Rust-based VMM but need device support (e.g., virtio-wayland) beyond what Firecracker offers.

**Tags**

`#virtualisation` `#crosvm` `#microvm` `#vmm` `#rust`

---

#### cloud-hypervisor (NixOS / microvm.nix)

**Website**

https://github.com/cloud-hypervisor/cloud-hypervisor  (options: https://search.nixos.org/options?channel=unstable&query=cloud-hypervisor)

**Description**

cloud-hypervisor is an Intel-backed VMM written in Rust, targeting standard VM workloads with a focus on security and modern device models. NixOS ships `pkgs.cloud-hypervisor` and exposes it as the `microvm.hypervisor = "cloud-hypervisor"` backend in microvm.nix; it is the most full-featured of the three Rust VMMs for a homelab running realistic Linux guests.

**Tags**

`#virtualisation` `#cloud-hypervisor` `#microvm` `#vmm` `#rust`

---

#### libvirtd / QEMU (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.libvirtd  (wiki: https://nixos.wiki/wiki/Libvirt)

**Description**

The `virtualisation.libvirtd` module enables the libvirt daemon, which exposes a unified API across QEMU/KVM, LXC, and other backends and is what `virt-manager`, `virt-install`, and `virsh` talk to. Enable `virtualisation.libvirtd.enable = true` and add yourself to the `libvirtd` group; for a homelab this is the most featureful VM stack, supporting snapshots, live migration, bridged networking, and the SPICE/VNC graphical console.

**Tags**

`#virtualisation` `#libvirt` `#qemu` `#kvm` `#nixos-module`

---

#### virt-manager (libvirt GUI)

**Website**

https://search.nixos.org/options?channel=unstable&query=virt-manager  (upstream: https://github.com/virt-manager/virt-manager)

**Description**

`virt-manager` is the desktop GUI for managing libvirt VMs (create, run, snapshot, console). Enable via `programs.virt-manager.enable = true` (which also wires the default libvirt connection and DBus permissions on GNOME) or by installing `pkgs.virt-manager` directly. The right choice for a homelab desktop that wants to manage its libvirt VMs without dropping to `virsh` for every operation.

**Tags**

`#virtualisation` `#libvirt` `#gui` `#virt-manager` `#desktop`

---

#### VirtualBox (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.virtualbox  (upstream: https://www.virtualbox.org/)

**Description**

The `virtualisation.virtualbox.host.enable` option installs the Oracle VirtualBox host modules and daemon, and `virtualisation.virtualbox.host.enableExtensionPack = true` adds the proprietary extension pack (USB 2.0/3.0, RDP, NVMe, disk encryption). Mostly relevant for desktop homelabs with guests that don't behave well under KVM (e.g., proprietary OSes that detect and refuse to run on QEMU).

**Tags**

`#virtualisation` `#virtualbox` `#gui` `#nixos-module`

---

#### Waydroid (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.waydroid  (upstream: https://waydro.id/)

**Description**

Waydroid runs a full Android userspace inside an LXC container on top of a Linux kernel with binder/ashmem support, presenting Android apps as native Wayland windows. The NixOS module (`virtualisation.waydroid.enable = true`) sets up the binder/ashmem kernel modules and the waydroid container service; a niche homelab use case is running Android apps on a Linux desktop without an emulator.

**Tags**

`#virtualisation` `#containers` `#android` `#waydroid` `#nixos-module`

---

#### containerd (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=virtualisation.containerd

**Description**

The `virtualisation.containerd` module enables the containerd daemon, the core container runtime used by Docker, K3s, and Kubernetes. In a homelab it is rarely used directly — most users will run Docker or Podman instead — but it is the right pick when you need `ctr`/`nerdctl` to manage OCI images at the runtime level, or when building a custom Kubernetes node image.

**Tags**

`#containers` `#containerd` `#oci` `#kubernetes` `#nixos-module`

---

#### distrobox (pkgs.distrobox)

**Website**

https://github.com/89luca89/distrobox  (options: https://search.nixos.org/options?channel=unstable&query=programs.distrobox)

**Description**

Distrobox creates Linux container shells (Podman or Docker backed) that integrate with the host's home directory, X/Wayland socket, audio, USB, and systemd. It is the canonical tool for running a Debian/Ubuntu/Arch/Fedora userspace on an immutable NixOS host without losing access to host resources — invaluable when a closed-source binary expects an FHS layout that NixOS does not provide. Enable via `programs.distrobox.enable = true` or install `pkgs.distrobox` directly.

**Tags**

`#containers` `#podman` `#fhs` `#distrobox` `#nixos`

---

#### Docker Registry (NixOS module)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.dockerRegistry

**Description**

The `services.dockerRegistry` module runs the upstream `registry:2` OCI distribution server, a private Docker/Podman image registry. Pair with `services.dockerRegistry.enableGarbageCollect = true` and an nginx/Caddy TLS terminator (or the registry's built-in TLS via `listenAddress`/`port`) to host your own image registry on your homelab LAN — a common pattern when combined with dockerTools / nix2container image builds.

**Tags**

`#containers` `#registry` `#oci` `#docker-registry` `#nixos-module`

---

#### buildah (pkgs.buildah)

**Website**

https://github.com/containers/buildah  (nixpkgs: https://search.nixos.org/packages?channel=unstable&query=buildah)

**Description**

buildah is a CLI tool from the `containers/` project family for building OCI images from a Shellfile-like script or a Dockerfile, without a long-running daemon. Useful on NixOS for building images from existing Dockerfiles where rewriting them as Nix derivations is not worth the effort, and where you want daemonless builds that integrate cleanly with Podman.

**Tags**

`#containers` `#oci` `#image-build` `#buildah` `#podman`

---

#### skopeo (pkgs.skopeo)

**Website**

https://github.com/containers/skopeo  (nixpkgs: https://search.nixos.org/packages?channel=unstable&query=skopeo)

**Description**

skopeo is a CLI for copying, inspecting, signing, and converting OCI/Docker images between registries and local archives (`docker-archive:`, `oci:`, `dir:`). It is the standard tool for moving images from a Nix-built `streamLayeredImage` into a private registry, or for mirroring images to air-gapped homelab hosts. Pairs naturally with dockerTools, nix2container, and the Docker Registry module.

**Tags**

`#containers` `#oci` `#image-management` `#skopeo` `#cli`

---

#### LXC userspace tools (pkgs.lxc)

**Website**

https://linuxcontainers.org/lxc/  (nixpkgs: https://search.nixos.org/packages?channel=unstable&query=lxc)

**Description**

The `lxc-*` CLI tools (`lxc-start`, `lxc-attach`, `lxc-ls`, `lxc-create`) for the classic LXC container format, packaged as `pkgs.lxc`. Largely superseded by Incus for new homelab deployments, but still relevant when you have existing LXC 1.x/2.x templates or are following older tutorials that pre-date Incus.

**Tags**

`#containers` `#lxc` `#nixpkgs` `#legacy`

---

#### Apptainer / Singularity (pkgs.apptainer)

**Website**

https://apptainer.org/  (nixpkgs: https://search.nixos.org/packages?channel=unstable&query=apptainer)

**Description**

Apptainer (formerly Singularity) is a container format and runtime popular in HPC for running rootless, immutable, single-file SIF container images. `pkgs.apptainer` runs Singularity/Apptainer containers on NixOS — a niche homelab use case but the right pick if you want to run scientific computing workloads packaged as SIF files without root privileges or a daemon.

**Tags**

`#containers` `#hpc` `#apptainer` `#singularity` `#nixpkgs`

---

#### NixOS Containers Wiki (overview)

**Website**

https://nixos.wiki/wiki/Containers

**Description**

The NixOS wiki's containers overview page, which contrasts the various container and VM options on NixOS (nspawn declarative/imperative, Podman, Docker, Incus, microvm.nix) with short examples. A good starting point when you are unsure which container primitive is the right fit for a given homelab workload.

**Tags**

`#nixos-wiki` `#containers` `#overview` `#homelab`

---


---

## Part VI — Kubernetes & Monitoring

### 25. Kubernetes on NixOS

NixOS supports two distinct paths to running Kubernetes: the lightweight `services.k3s` module (recommended for most homelabs) and the heavier, lower-level `services.kubernetes` module which exposes every component (apiserver, controllerManager, kubelet, etcd, etc.) individually. Third-party projects (xtruder/nixos-kubernetes, kubespray-nixos) layer declarative opinion on top of these modules. Talos Linux takes a different approach — it replaces the host OS entirely — but integrates with NixOS as the management node and as the source of `talosctl`.

#### NixOS k3s Module (`services.k3s`)

**Website**

https://search.nixos.org/options?query=services.k3s

**Description**

The first-class NixOS module for K3s, the lightweight Kubernetes distribution from Rancher/SUSE. Setting `services.k3s.enable = true;` produces a single-node cluster in seconds; `services.k3s.role = "server"` (or `"agent"`) plus `services.k3s.clusterInit = true;` and a `serverAddr` enables a multi-node HA-style cluster. The module handles token sharing, containerd config, extra flags (`--disable=traefik`, `--flannel-backend=vxlan`, etc.), and CNI wiring. For a NixOS homelab this is the default recommendation — it pairs cleanly with declarative manifests deployed via `kustomize`/`flux` and survives reboots because state is just `/var/lib/rancher/k3s`.

**Tags**

`#nixos` `#kubernetes` `#k3s` `#homelab` `#module`

---

#### k3s (Upstream Project)

**Website**

https://github.com/k3s-io/k3s

**Description**

The upstream lightweight Kubernetes distribution that the NixOS `services.k3s` module wraps. K3s ships as a single ~70 MB binary that bundles the apiserver, scheduler, controller-manager, kubelet, containerd, and a default CNI (flannel), with optional bundled Ingress (traefik) and ServiceLB. Reading the upstream docs is essential for understanding the flag matrix (`--cluster-init`, `--server`, `--tls-san`, `--data-dir`) that the NixOS module exposes via `services.k3s.extraFlags`.

**Tags**

`#kubernetes` `#k3s` `#lightweight` `#containerd` `#distribution`

---

#### NixOS Kubernetes Module (`services.kubernetes`)

**Website**

https://search.nixos.org/options?query=services.kubernetes

**Description**

The "raw" NixOS Kubernetes module — exposes individual options for `services.kubernetes.apiserver`, `controllerManager`, `scheduler`, `kubelet`, `proxy`, `etcd`, `addons.dns`, `flannel`, and so on. This is the path to take if you want full control over a self-managed K8s cluster on NixOS (no bundled distribution), but it is significantly more involved than k3s: you decide on CNI, RBAC, certificate authority, and bootstrap order yourself. The module lives in `nixos/modules/services/cluster/kubernetes` in nixpkgs and has been the basis of the NixOS test suite's K8s cluster for years.

**Tags**

`#nixos` `#kubernetes` `#module` `#self-managed` `#advanced`

---

#### xtruder/nixos-kubernetes

**Website**

https://github.com/xtruder/nixos-kubernetes

**Description**

A community flake/module that provides opinionated, declarative Kubernetes-on-NixOS tooling — including helpers for `kubernetes` deployments, RBAC, Helm releases, and Flux-style GitOps on top of the upstream NixOS Kubernetes module. It historically packaged `kubernetes-helm` and a Nix-flavoured Helm wrapper before these were upstreamed. Useful as a reference for patterns like rendering Helm values with Nix and templating manifests with `pkgs.writeText`. Useful but partially superseded by upstream `services.kubernetes.addons` and by modern GitOps tools (ArgoCD/Flux) deployed as plain containers.

**Tags**

`#nixos` `#kubernetes` `#helm` `#gitops` `#community`

---

#### kubespray-nixos

**Website**

https://github.com/rguillebert/kubespray-nixos

**Description**

A community adaptation of the upstream Kubespray Ansible playbook that targets NixOS hosts. Kubespray normally assumes Debian/Ubuntu/RHEL; this fork patches package names, containerd paths, and systemd unit handling for NixOS so you can use Kubespray's inventory model to provision a multi-node K8s cluster across NixOS machines. A good fit when you already standardise on Kubespray for fleet management and need to fold NixOS nodes into the same playbook — otherwise the `services.k3s` module is simpler.

**Tags**

`#nixos` `#kubernetes` `#kubespray` `#ansible` `#fleet`

---

#### Talos Linux

**Website**

https://github.com/siderolabs/talos

**Description**

Talos Linux is a security-focused, API-driven Kubernetes OS from Sidero Labs — it has no shell, no SSH, and no portage-style package manager; everything is configured via a single machine-config YAML applied through `talosctl`. Talos is a compelling alternative to running K8s on NixOS when you want the host OS itself to be immutable and Kubernetes-aware. The two ecosystems compose: NixOS is an excellent management workstation (install `talosctl` from nixpkgs) and can boot Talos via a PXE/ISO pipeline, while Talos handles the actual cluster nodes. Talos also integrates well with `nixos-anywhere` for bare-metal provisioning of the management host.

**Tags**

`#kubernetes` `#talos` `#immutable` `#api-driven` `#siderolabs`

---

#### talosctl (NixOS package)

**Website**

https://search.nixos.org/packages?query=talosctl

**Description**

The Talos Linux control-plane CLI, packaged in nixpkgs. `talosctl gen config`, `talosctl apply-config`, `talosctl kubeconfig`, and `talosctl upgrade` are the day-to-day commands used to bootstrap and maintain a Talos cluster. On a NixOS management host you typically install it with `environment.systemPackages = [ pkgs.talosctl ];` and pair it with `kubectl`, `helm`, and `k9s` from the same nixpkgs revision as the cluster you are operating.

**Tags**

`#nixos` `#talos` `#cli` `#kubernetes` `#nixpkgs`

---

#### Talos Image Factory

**Website**

https://factory.talos.dev/

**Description**

Sidero's hosted service that produces custom Talos installer images with bundled system extensions (e.g. specific kernel modules, NVIDIA drivers, QEMU tools, ZFS). You submit a schematic YAML describing extensions and the Factory returns an installer URL you pass to `talosctl install` or boot via PXE. For a NixOS-managed homelab this is the fastest way to give Talos nodes the kernel features they need (e.g. iscsi, nfs-ganesha, Intel/AMD GPU drivers) without rebuilding Talos locally.

**Tags**

`#talos` `#image` `#extensions` `#siderolabs` `#kubernetes`

---

#### MicroK8s (NixOS caveats)

**Website**

https://microk8s.io/

**Description**

Canonical's lightweight, snap-delivered Kubernetes distribution. MicroK8s is not packaged in nixpkgs because it strictly depends on `snapd` and snap confinement; running it on NixOS requires the `snapd` NixOS module (which itself has limitations — AppArmor/`snap-confine` patches, no strict confinement, periodic breakage on kernel updates). For a NixOS homelab, k3s (`services.k3s`) is the strongly preferred alternative — same lightweight footprint, native NixOS module, and no snap dependency. MicroK8s is listed here primarily so homelab operators can recognise the warning signs before trying to install it.

**Tags**

`#kubernetes` `#microk8s` `#snap` `#caveats` `#not-recommended`

---

#### KubeVirt

**Website**

https://github.com/kubevirt/kubevirt

**Description**

Kubernetes Virtualization API — lets you run full VMs (libvirt/QEMU-backed) as first-class Kubernetes workloads alongside containers. KubeVirt is fully declarative and integrates with the CDI (Containerized Data Importer) for disk images. On a NixOS K8s cluster (k3s or `services.kubernetes`), KubeVirt turns your homelab into a unified container+VM platform — useful when you want to run legacy OSes (Windows, BSD, old Linux distros) under the same GitOps pipeline as your pods. KubeVirt's operator deploys as standard manifests; NixOS only needs to provide KVM/libvirt kernel support (`virtualisation.libvirtd.enable`).

**Tags**

`#kubernetes` `#kubevirt` `#virtualization` `#kvm` `#libvirt`

---

#### NixOS Wiki — Kubernetes

**Website**

https://nixos.wiki/wiki/Kubernetes

**Description**

Community-maintained wiki page covering both the `services.kubernetes` module and `services.k3s` on NixOS, with worked examples for CNI, RBAC, joining worker nodes, and common pitfalls (DNS `cluster-dns` IP, kubelet cgroup driver, `services.kubernetes.kubelet.cadvisor`/container runtime socket path). A useful first stop before reading the nixpkgs module source — it captures field notes that the upstream module documentation does not.

**Tags**

`#nixos` `#kubernetes` `#wiki` `#documentation` `#community`

---

### 26. Monitoring (as NixOS Modules)

NixOS ships a first-class monitoring stack in nixpkgs: Prometheus and its exporter framework, Grafana with declarative provisioning, Loki and its agents, VictoriaMetrics (and Grafana Mimir) as horizontally-scalable alternatives, Alertmanager, and several standalone monitors (Uptime Kuma, Netdata, Zabbix, Telegraf). Most are enabled with a single `services.<name>.enable = true;` and configured declaratively through Nix options.

#### NixOS Prometheus Module (`services.prometheus`)

**Website**

https://search.nixos.org/options?query=services.prometheus

**Description**

The first-class NixOS module for the Prometheus time-series database. `services.prometheus.enable = true;` starts a single Prometheus instance with declaratively configured `scrapeConfigs`, `ruleFiles`, external labels, retention (`services.prometheus.retentionTime`), and a WAL directory under `/var/lib/prometheus`. The module supports `services.prometheus.listenAddress`/`port`, basic auth via `webExternalUrl`, and remote write/read for federating into a long-term store (Thanos, Mimir, VictoriaMetrics). The default choice for any NixOS homelab's metrics backend.

**Tags**

`#nixos` `#prometheus` `#metrics` `#monitoring` `#module`

---

#### NixOS Prometheus Exporters Framework

**Website**

https://search.nixos.org/options?query=services.prometheus.exporters

**Description**

A unified NixOS sub-module that exposes every Prometheus exporter shipped in nixpkgs through a single, consistent option schema: `services.prometheus.exporters.<name>.enable`, `.port`, `.listenAddress`, `.openFirewall`, `.extraFlags`, and `.enabledCollectors`. Available exporters include `node`, `smartctl`, `process`, `nginx`, `apache`, `postgres`, `mysqld`, `redis`, `bind`, `dnsmasq`, `systemd`, `jitsi`, `wireguard`, `varnish`, `minio`, and many more. This is the canonical way to instrument a NixOS fleet — each exporter drops in as a one-liner in your host config.

**Tags**

`#nixos` `#prometheus` `#exporters` `#monitoring` `#module`

---

#### Node Exporter (NixOS)

**Website**

https://search.nixos.org/options?query=services.prometheus.exporters.node

**Description**

The Prometheus node_exporter, exposed via the NixOS exporters framework. Provides CPU, memory, disk, filesystem, network, and systemd collector metrics for the host. Enabling `services.prometheus.exporters.node.enable = true; services.prometheus.exporters.node.openFirewall = true;` is the single most common monitoring line in a NixOS homelab and the foundation of any per-host Grafana dashboard. Useful collectors to enable: `systemd`, `tcpstat`, `ethtool`, `powersupplyclass`.

**Tags**

`#nixos` `#prometheus` `#node-exporter` `#host-metrics` `#monitoring`

---

#### Smartctl Exporter (NixOS)

**Website**

https://search.nixos.org/options?query=services.prometheus.exporters.smartctl

**Description**

Prometheus smartctl exporter — exposes S.M.A.R.T. attributes for all block devices via `smartctl --json`. On NixOS it runs the exporter as root (or with appropriate capabilities) so it can read `/dev/sd*` and `/dev/nvme*`. Critical for any homelab running spinning-rust or NVMe storage: gives you early-warning dashboards on reallocated sectors, temperature, and wear levelling before a disk fails.

**Tags**

`#nixos` `#prometheus` `#smartctl` `#storage` `#monitoring`

---

#### Blackbox Exporter (NixOS)

**Website**

https://search.nixos.org/options?query=services.prometheus.exporters.blackbox

**Description**

Prometheus blackbox_exporter — performs synthetic HTTP(S), ICMP, TCP, and DNS probes against external endpoints and returns them as metrics. On NixOS it is enabled with `services.prometheus.exporters.blackbox.enable = true;` and configured via a modules file (`services.prometheus.exporters.blackbox.configPath`). The backbone of any "is my service up?" check: pair with a Grafana dashboard that pings your public endpoints from inside the cluster and from outside.

**Tags**

`#nixos` `#prometheus` `#blackbox` `#synthetic` `#uptime`

---

#### NixOS Prometheus Alert Rules (`ruleFiles`)

**Website**

https://search.nixos.org/options?query=services.prometheus.ruleFiles

**Description**

The NixOS option for declaratively feeding Prometheus recording and alerting rules — written as Nix attrsets and rendered to YAML — into a running Prometheus instance. The canonical pattern is `services.prometheus.ruleFiles = [ (pkgs.writeText "rules.yml" (builtins.toJSON { groups = [ {...} ]; })) ];` or a `lib.pipe` of Nix values through `toYAML`. Combined with `services.prometheus.alertmanager` this is the foundation of an end-to-end declarative alerting pipeline on NixOS.

**Tags**

`#nixos` `#prometheus` `#alerts` `#rules` `#declarative`

---

#### Alertmanager (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.prometheus.alertmanager

**Description**

The Prometheus Alertmanager, deployed as a NixOS sub-service of `services.prometheus`. `services.prometheus.alertmanager.enable = true;` starts Alertmanager with a declarative configuration (`services.prometheus.alertmanager.configuration`) covering routing, inhibition, silences, and receivers (email, Slack, PagerDuty, webhooks, Discord via webhook). For a homelab this is the simplest path to "page me on Discord when a disk fills up" — Alertmanager is co-located on the same host as Prometheus by default and federates cleanly if you later add redundancy.

**Tags**

`#nixos` `#prometheus` `#alertmanager` `#alerts` `#notifications`

---

#### Grafana (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.grafana

**Description**

The NixOS module for Grafana — the ubiquitous visualisation and dashboarding frontend for Prometheus, Loki, VictoriaMetrics, and friends. `services.grafana.enable = true;` runs the Grafana server with declarative config under `services.grafana.settings` (the modern ini-style schema), persistent SQLite under `/var/lib/grafana`, and integrates with `services.grafana.provision` for declarative datasources, dashboards, users, and alert rules. The default UI for any NixOS homelab monitoring stack.

**Tags**

`#nixos` `#grafana` `#dashboards` `#visualization` `#module`

---

#### Grafana Provisioning (NixOS)

**Website**

https://search.nixos.org/options?query=services.grafana.provision

**Description**

NixOS-native bindings for Grafana's declarative provisioning API. `services.grafana.provision.datasources` (list of attrsets), `services.grafana.provision.dashboards` (list of named directories containing JSON), and `services.grafana.provision.alertRules` let you commit your entire Grafana state to a Nix flake — no manual UI click-ops. This is the recommended pattern for a homelab: dashboards live as JSON in the flake repo, get rebuilt with the system, and survive host reinstallation.

**Tags**

`#nixos` `#grafana` `#provisioning` `#gitops` `#declarative`

---

#### Grafana Declarative Plugins (NixOS)

**Website**

https://search.nixos.org/options?query=services.grafana.declarativePlugins

**Description**

NixOS option to install Grafana plugins (panel, datasource, app) declaratively through nixpkgs instead of Grafana's online plugin catalog. `services.grafana.declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel grafana-clock-panel ];`. Avoids the "Grafana can't write to /var/lib/grafana/plugins because it's read-only" failure mode and pins plugin versions in your flake lock.

**Tags**

`#nixos` `#grafana` `#plugins` `#nixpkgs` `#declarative`

---

#### Loki (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.loki

**Description**

The NixOS module for Grafana Loki — the horizontally-scalable, log-aggregation system designed to pair with Prometheus (it indexes only label sets, not full text). `services.loki.enable = true;` runs Loki with a declarative configuration under `services.loki.configuration` covering schema configs, compactor, ruler, limits, and storage backends (filesystem, S3, GCS). For a homelab this is the simplest "Prometheus but for logs" setup — single binary, single node, filesystem storage, queryable from Grafana.

**Tags**

`#nixos` `#loki` `#logs` `#grafana` `#module`

---

#### Promtail (NixOS Module) — deprecated, use Alloy

**Website**

https://search.nixos.org/options?query=services.promtail

**Description**

The NixOS module for Promtail — Grafana's log-shipping agent that tails files and journals, attaches labels, and ships to Loki. The module (`services.promtail.enable = true; services.promtail.configuration = {...}`) is functional and widely deployed, but is **deprecated upstream**: Grafana has consolidated Promtail and Grafana Agent into a single new agent, **Grafana Alloy** (see next entry), and Promtail is in maintenance mode. For new deployments prefer `services.alloy`; existing Promtail configs can be mechanically translated via Alloy's `convert` command.

**Tags**

`#nixos` `#promtail` `#loki` `#logs` `#deprecated`

---

#### Grafana Alloy (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.alloy

**Description**

The NixOS module for Grafana Alloy — the official successor to both Promtail and Grafana Agent, built on the OpenTelemetry Collector. Alloy collects metrics (Prometheus scrape + remote_write), logs (Loki/Promtail-style tailing), and traces (OTLP) in a single declarative `river` config. `services.alloy.enable = true; services.alloy.extraFlags = [...]` plus a config under `/etc/alloy/config.alloy` (or pinned in the Nix store via `services.alloy.settings`) gives you one agent per host doing what previously required three. The recommended log/metric shipper for any new NixOS monitoring deployment.

**Tags**

`#nixos` `#alloy` `#grafana` `#opentelemetry` `#recommended`

---

#### VictoriaMetrics (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.victoriametrics

**Description**

The NixOS module for the single-binary VictoriaMetrics — a high-performance, drop-in Prometheus replacement with significantly better compression and resource usage at homelab scale. `services.victoriametrics.enable = true;` runs the single-node `vmsingle` binary with declarative flags (`services.victoriametrics.extraOptions`) for retention, dedup, and storage path. Accepts Prometheus remote_write natively, so a NixOS Prometheus can scrape as usual and remote_write into VictoriaMetrics for long-term storage. A pragmatic upgrade path when Prometheus starts struggling with cardinality.

**Tags**

`#nixos` `#victoriametrics` `#metrics` `#prometheus-compatible` `#module`

---

#### vmagent (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.vmagent

**Description**

NixOS module for VictoriaMetrics `vmagent` — a lightweight scrape-and-forward agent that speaks Prometheus remote_write (and many other protocols) to one or more VictoriaMetrics endpoints. Useful in a homelab where you want to scrape per-node exporters from each host (avoiding a central Prometheus reaching into every box) and centralise the storage. `services.vmagent.enable = true; services.vmagent.prometheusConfig = {...}` mirrors the Prometheus `scrape_config` schema.

**Tags**

`#nixos` `#vmagent` `#victoriametrics` `#scraping` `#remote-write`

---

#### vmalert (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.vmalert

**Description**

NixOS module for VictoriaMetrics `vmalert` — the Alertmanager-equivalent rule evaluator for the VictoriaMetrics ecosystem. It evaluates recording and alerting rules against VictoriaMetrics (or any Prometheus remote_read source) and fires alerts into Alertmanager. `services.vmalert.enable = true; services.vmalert.ruleFiles = [...]` is the vm-stack analogue of `services.prometheus.ruleFiles`. Pair with `services.prometheus.alertmanager` for the notification layer — vmalert and Prometheus can share the same Alertmanager instance.

**Tags**

`#nixos` `#vmalert` `#victoriametrics` `#alerts` `#rules`

---

#### vmsingle / vmcluster (NixOS Modules)

**Website**

https://search.nixos.org/options?query=services.vmsingle

**Description**

NixOS modules for the multi-component VictoriaMetrics deployment modes. `services.vmsingle` runs the all-in-one single-node VictoriaMetrics (the simpler option, used by `services.victoriametrics`); `services.vmcluster` orchestrates a horizontally-scalable setup of `vmstorage` + `vminsert` + `vmselect` for HA and long-term retention. For a homelab `services.vmsingle` (or just `services.victoriametrics`) is sufficient; `services.vmcluster` is what you reach for once you outgrow a single host.

**Tags**

`#nixos` `#victoriametrics` `#vmsingle` `#vmcluster` `#scaling`

---

#### Grafana Mimir (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.mimir

**Description**

NixOS module for Grafana Mimir — the horizontally-scalable, multi-tenant, long-term Prometheus-compatible metrics backend that succeeds Cortex. Mimir is to Prometheus what Loki is to logs: it accepts remote_write at huge cardinality and provides query sharding, multi-tenancy, and compaction. On a NixOS homelab Mimir is **overkill** for a single node — prefer VictoriaMetrics or straight Prometheus — but it is the right choice when you outgrow a single VictoriaMetrics instance and want a vendor-neutral, OSS path to horizontal scaling.

**Tags**

`#nixos` `#mimir` `#grafana` `#prometheus-compatible` `#scaling`

---

#### Uptime Kuma (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.uptime-kuma

**Description**

NixOS module for Uptime Kuma — the popular self-hosted uptime monitor with a friendly web UI (HTTP/TCP/ping/DNS/gRPC/push/docker containers). `services.uptime-kuma.enable = true;` runs the Node service behind a systemd unit with persistent state in `/var/lib/uptime-kuma`, surfaced on port 3001 by default. Excellent "set-and-forget" uptime dashboard for a homelab: lighter than a full Prometheus+Blackbox+Grafana pipeline, with built-in notification channels (Discord, Telegram, ntfy, SMTP).

**Tags**

`#nixos` `#uptime-kuma` `#uptime` `#status-page` `#monitoring`

---

#### Netdata (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.netdata

**Description**

NixOS module for Netdata — the per-host, real-time, high-resolution metrics daemon with its own bundled web dashboard. `services.netdata.enable = true;` exposes a per-second metrics UI on port 19999 with zero config; `services.netdata.config.*` lets you tune collection, alarms, and exporting to Prometheus/Graphite. For a NixOS homelab Netdata is a great "instant dashboard" alongside a long-term Prometheus backend — it is not a replacement for Prometheus, but it answers "what is this box doing right now?" faster than any Grafana panel.

**Tags**

`#nixos` `#netdata` `#real-time` `#per-host` `#dashboard`

---

#### Zabbix Server (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.zabbixServer

**Description**

NixOS module for the Zabbix monitoring server — the classic enterprise monitoring stack with agent-based collection, a SQL-backed database (PostgreSQL/MySQL), and a PHP web frontend. `services.zabbixServer.enable = true;` runs the server daemon with declarative database, frontend (`services.zabbixWeb`), and agent wiring. Heavyweight compared to Prometheus, but the right pick if you already operate on Zabbix templates (network gear, UPSes, SNMP devices) and want to keep the same templating on NixOS hosts.

**Tags**

`#nixos` `#zabbix` `#monitoring` `#snmp` `#enterprise`

---

#### Zabbix Agent (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.zabbixAgent

**Description**

NixOS module for the Zabbix agent — runs on every NixOS host you want to monitor with an existing Zabbix server. `services.zabbixAgent.enable = true; services.zabbixAgent.server = "zabbix.example.org";` registers the host and exposes the standard Zabbix agent checks (CPU, disk, processes, custom UserParameter scripts). The complement to `services.zabbixServer` for distributed homelabs where Zabbix is the chosen monitoring backend.

**Tags**

`#nixos` `#zabbix` `#agent` `#monitoring` `#module`

---

#### Telegraf (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.telegraf

**Description**

NixOS module for Telegraf — InfluxData's plugin-driven metrics collection agent. Telegraf supports an unusually wide input plugin matrix (SNMP, MQTT, ping, docker, smartctl, ipmi, procstat, sql) and can output to Prometheus client, InfluxDB, Graphite, Datadog, etc. `services.telegraf.enable = true; services.telegraf.extraConfig = {...}` is a good single-agent choice when you need to ingest sources that the standard Prometheus exporters do not cover (IPMI sensors, modbus, OPC-UA, MQTT brokers) and still want everything in one Prometheus backend.

**Tags**

`#nixos` `#telegraf` `#influxdata` `#snmp` `#monitoring`

---

#### Prometheus Pushgateway (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.prometheus.pushgateway

**Description**

NixOS sub-module for the Prometheus Pushgateway — an intermediary service that allows ephemeral and batch jobs to push their metrics for later scraping by Prometheus (which is otherwise pull-only). `services.prometheus.pushgateway.enable = true;` runs the gateway with persistent metrics. Useful in a NixOS homelab for Nix build jobs, backup scripts, and cron-driven tasks that want to emit "I ran successfully" or "I processed N items" metrics without being long-lived services.

**Tags**

`#nixos` `#prometheus` `#pushgateway` `#batch-jobs` `#metrics`

---

#### Thanos (NixOS Module)

**Website**

https://search.nixos.org/options?query=services.thanos

**Description**

NixOS module for Thanos — the set of components that turn Prometheus into a globally-queryable, long-term-retention metrics backend using object storage (S3, GCS, MinIO) as the historical store. `services.thanos.sidecar`, `services.thanos.store`, `services.thanos.compactor`, `services.thanos.query`, and `services.thanos.receive` are each a NixOS service. Thanos is the OSS, vendor-neutral alternative to Mimir when you want Prometheus remote-read/write federation across multiple NixOS sites without adopting a new query language.

**Tags**

`#nixos` `#thanos` `#prometheus` `#object-storage` `#federation`

---

#### NixOS Wiki — Prometheus

**Website**

https://nixos.wiki/wiki/Prometheus

**Description**

Community wiki page covering the NixOS Prometheus module end-to-end: enabling the server, configuring `scrapeConfigs`, wiring up `services.prometheus.exporters.*`, defining `ruleFiles`, attaching `services.prometheus.alertmanager`, and common failure modes (loopback scrape timeouts, systemd-journald exporter permissions, retention filling `/var`). A useful companion to the option search results when bootstrapping a first monitoring stack on NixOS.

**Tags**

`#nixos` `#prometheus` `#wiki` `#documentation` `#community`

---

#### Grafana Alloy upstream

**Website**

https://github.com/grafana/alloy

**Description**

The upstream Grafana Alloy repository — source for the binary that the NixOS `services.alloy` module wraps. Reading the upstream documentation is essential because the NixOS module deliberately exposes only the most common options (`enable`, `extraFlags`, `settings`); the full River-pipeline configuration language, component reference, and migration guides from Promtail/Agent live here. The repo also publishes the `alloy fmt` and `alloy run` tooling used to validate configs before deployment.

**Tags**

`#grafana` `#alloy` `#opentelemetry` `#river` `#upstream`

---

#### kube-prometheus-stack (Bootstrap Reference)

**Website**

https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

**Description**

The de-facto standard Helm chart that bundles Prometheus, Alertmanager, Grafana, node-exporter, kube-state-metrics, and a default set of dashboards/alerts for a Kubernetes cluster. Not a NixOS module — but on a NixOS-managed k3s/`services.kubernetes` cluster it is the fastest way to get a working in-cluster monitoring stack. The chart values are easily templated from Nix (via `pkgs.kubernetes-helm` or via `helm template` + `kubectl apply`), giving you a hybrid declarative flow: NixOS owns the host and the cluster; kube-prometheus-stack owns what runs inside it.

**Tags**

`#kubernetes` `#prometheus` `#grafana` `#helm` `#cluster-monitoring`

---


---

## Part VII — Storage & Databases

### 27. Storage on NixOS

NixOS exposes nearly every popular Linux storage stack through first-class modules in `nixpkgs`. The recommended pattern for a homelab is to declare pools, datasets, snapshot policies, and backup jobs entirely in configuration so a single flake rebuild can re-create the storage layer on a fresh host.

#### ZFS (NixOS module: boot.supportedFilesystems + services.zfs)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.zfs

**Description**

First-class ZFS support in `nixpkgs` via `boot.supportedFilesystems = [ "zfs" ]` plus the `services.zfs` module. The module enables auto-scrub (`services.zfs.autoScrub.enable`, `interval`, `pools`), auto-trim, and a `zfs-mount`/`zfs-share` systemd sequence. Combined with `boot.zfs.enabled` and `networking.hostId`, it gives a fully declarative OpenZFS root pool or secondary pool, with native encryption and dataset properties set in the config rather than forgotten at the console.

**Tags**

`#zfs` `#filesystem` `#storage` `#nixos-module` `#encryption`

---

#### ZFS Auto Snapshot (services.zfs.autoSnapshot)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.zfs.autoSnapshot

**Description**

Built-in wrapper around `zfs-auto-snapshot` that installs systemd timers for frequent/hourly/daily/weekly/monthly snapshots of every dataset whose `com.sun:auto-snapshot` property is true. Controlled via `services.zfs.autoSnapshot.enable`, `services.zfs.autoSnapshot.flags`, and per-interval `keep` counts. Simple and zero-dependency; for richer retention/policy logic most users graduate to Sanoid.

**Tags**

`#zfs` `#snapshots` `#backup` `#nixos-module`

---

#### Sanoid (NixOS module: services.sanoid)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.sanoid

**Description**

Policy-driven ZFS snapshot manager with per-dataset templates (hourly/daily/weekly/monthly retention, capacity limits). On NixOS, `services.sanoid.enable = true` plus `services.sanoid.datasets.<name>....` produces a declarative `/etc/sanoid/sanoid.conf` and a `sanoid.timer`. Far more flexible than the built-in auto-snapshot service; the standard choice for homelab retention policies.

**Tags**

`#zfs` `#snapshots` `#backup` `#nixos-module` `#sanoid`

---

#### Syncoid (NixOS module: services.syncoid)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.syncoid

**Description**

Sibling module that wraps `syncoid` (shipped with Sanoid) for incremental `zfs send | zfs receive` replication to a remote host over SSH. Configured via `services.syncoid.enable` and `services.syncoid.commands.<name>` (source/target pairs), producing a per-command `syncoid-<name` systemd service + timer. Pairs naturally with Sanoid on both ends for a robust pull/push ZFS backup pipeline.

**Tags**

`#zfs` `#replication` `#backup` `#nixos-module` `#syncoid`

---

#### Sanoid / Syncoid upstream (jimsalterjrs/sanoid)

**Website**

https://github.com/jimsalterjrs/sanoid

**Description**

Upstream project for both `sanoid` and `syncoid`. Sanoid is a policy-driven snapshot manager; syncoid supports recursive replication, `-p` property propagation, and works with encrypted datasets in non-raw sends. Reading the README is the fastest way to understand the policy model that the NixOS module mirrors.

**Tags**

`#zfs` `#upstream` `#snapshots` `#replication`

---

#### zrepl (NixOS module: services.zrepl)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.zrepl

**Description**

A more sophisticated ZFS replication daemon than syncoid: continuous or scheduled replication with parallel jobs, ZFS holds/bookmarks to protect against sync loss, transport over raw TCP/TLS or SSH, and a curses-style `zrepl status` UI. On NixOS, set `services.zrepl.enable = true` and `services.zrepl.settings = { ... }` (a Nix attrset compiled to YAML). Good fit for multi-target or pull-style replication where syncoid's one-shot timer model feels too coarse.

**Tags**

`#zfs` `#replication` `#backup` `#nixos-module` `#zrepl`

---

#### zrepl upstream

**Website**

https://github.com/zrepl/zrepl

**Description**

Upstream repository for the zrepl daemon, written in Go. Includes quickstart guides for push, pull, and sink jobs, and documents the YAML schema that the NixOS `services.zrepl.settings` option maps onto. Useful when designing replication topologies between two ZFS hosts.

**Tags**

`#zfs` `#upstream` `#replication` `#zrepl`

---

#### Btrfs (NixOS module: boot.supportedFilesystems + services.btrfs)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.btrfs

**Description**

Enabling `boot.supportedFilesystems = [ "btrfs" ]` brings the kernel module, `btrfs-progs`, and `btrfs.scan`/`btrfs.devices` machinery; combined with subvolume mounts declared in `fileSystems`, this gives a fully declarative Btrfs root. The `services.btrfs.autoScrub` option periodically scrubs mounted Btrfs filesystems for bit-rot detection. No third-party modules needed for basic Btrfs on NixOS.

**Tags**

`#btrfs` `#filesystem` `#storage` `#nixos-module`

---

#### Btrfs autoScrub (services.btrfs.autoScrub)

**Website**

https://search.nixos.org/options?channel=unstable&show=services.btrfs.autoScrub.enable

**Description**

Tiny built-in module that runs `btrfs scrub` periodically (`services.btrfs.autoScrub.interval`, default weekly) across all listed `fileSystems`. Reports and (where redundancy exists) repairs corrupted blocks. For CoW filesystems like Btrfs, scrub is the rough equivalent of `zpool scrub` and is essential for catching silent data corruption.

**Tags**

`#btrfs` `#scrub` `#integrity` `#nixos-module`

---

#### Snapper (NixOS module: services.snapper)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.snapper

**Description**

NixOS module wrapping openSUSE's `snapper` for automated Btrfs (and LVM-ext4) snapshots on a timeline plus a `snapper-cleanup` timer using the "timeline" and "cleanup" algorithms. Configured via `services.snapper.configs.<name> = { SUBVOLUME = "/path"; ... }`. Note that the `.snapshots` subvolume must exist beforehand — a common stumbling block referenced in NixOS Discourse.

**Tags**

`#btrfs` `#snapshots` `#nixos-module` `#snapper`

---

#### btrbk (NixOS module: services.btrbk)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.btrbk

**Description**

Module for `digint/btrbk`, which both takes Btrfs snapshots and (uniquely) performs incremental `btrfs send`/`receive` to a remote Btrfs host. Configured via `services.btrbk.instances.<name>.settings = { ... }` (a Nix attrset compiled to YAML) plus onCalendar timer. Strongly recommended by the NixOS Wiki for off-host Btrfs backups; pairs well with snapper snapshots as the source.

**Tags**

`#btrfs` `#snapshots` `#replication` `#nixos-module` `#btrbk`

---

#### btrbk upstream (digint/btrbk)

**Website**

https://github.com/digint/btrbk

**Description**

Upstream btrbk repository. Documents the YAML schema mirrored by NixOS's `services.btrbk.instances.<name>.settings`, the snapshot naming scheme, and how btrbk can consume snapshots created by snapper. Worth reading before designing a Btrfs backup pipeline.

**Tags**

`#btrfs` `#upstream` `#replication` `#btrbk`

---

#### Btrfs Assistant (NixOS package: btrfs-assistant)

**Website**

https://search.nixos.org/packages?channel=unstable&query=btrfs-assistant

**Description**

A Qt-based GUI for managing Btrfs subvolumes, snapshots, and Snapper configs, packaged in nixpkgs. Useful as a desktop companion on a NixOS workstation to browse/restore Snapper snapshots without dropping to the CLI. Not a service module — install via `environment.systemPackages` and launch as a user.

**Tags**

`#btrfs` `#gui` `#snapper` `#package`

---

#### SnapRAID (NixOS module: services.snapraid)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.snapraid

**Description**

Module for SnapRAID, the offline parity-checking array tool popular with home NAS builds. `services.snapraid.enable` plus `services.snapraid.contentFiles`, `dataDisks`, `parityFiles`, and `services.snapraid.sync.interval` produce a `/etc/snapraid.conf` plus systemd `snapraid-sync` and `snapraid-scrub` timers. Ideal for media collections spread across disks of mixed sizes that change infrequently (SnapRAID is batch, not realtime).

**Tags**

`#snapraid` `#parity` `#nas` `#nixos-module` `#storage`

---

#### snapraid-btrfs (NixOS package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=snapraid-btrfs

**Description**

A small wrapper script that exposes Btrfs snapshots to SnapRAID so the parity run sees a consistent point-in-time view of CoW filesystems. Installed via `environment.systemPackages` and invoked in a `services.snapraid.sync.preHook` script or a custom systemd unit. Required when combining SnapRAID with Btrfs data disks to avoid "file changed during sync" warnings.

**Tags**

`#snapraid` `#btrfs` `#parity` `#package`

---

#### mergerfs (NixOS package + pool mount)

**Website**

https://search.nixos.org/packages?channel=unstable&query=mergerfs

**Description**

A FUSE-based union filesystem that pools multiple disks into a single mount, with policies like `mspmfs` (most-free-space) for writes. On NixOS, install via `environment.systemPackages` and mount via a `fileSystems` entry with `fsType = "fuse.mergerfs"` and `options = [ "defaults" "allow_other" "category.create=mfs" "moveonenospc=true" "dropcacheonclose=true" ]`. Common pairing with SnapRAID for a DIY NAS without ZFS/Btrfs overhead.

**Tags**

`#mergerfs` `#pooling` `#nas` `#package` `#fuse`

---

#### MinIO (NixOS module: services.minio)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.minio

**Description**

First-class S3-compatible object storage module. `services.minio.enable = true` plus `listenAddress`, `consoleAddress`, `rootCredentialsFile` (pointing to an env file containing `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`), and a `dataDir` (or several for erasure-coded arrays) launches the MinIO server + console under systemd. Provides the canonical S3 backend for restic/borg backups, Loki/Thanos chunk storage, or Tailscale-bound homelab "S3 at home".

**Tags**

`#minio` `#s3` `#object-storage` `#nixos-module`

---

#### MinIO upstream module source (nixpkgs)

**Website**

https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/minio.nix

**Description**

Direct link to the MinIO NixOS module source in nixpkgs. Useful for reading the exact systemd unit, environment variables, and option defaults (e.g. that `rootCredentialsFile` is required when `enable = true`) before writing your config.

**Tags**

`#minio` `#nixpkgs` `#source` `#nixos-module`

---

#### Restic backups (NixOS module: services.restic.backups)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.restic.backups

**Description**

The standard NixOS backup module: each `services.restic.backups.<name>` attrset defines `paths`, `repository` (local path, SFTP, REST server, or S3 via `rclone`), `passwordFile`, `pruneOpts`, `backupAt` (systemd `OnCalendar`), and optional `exclude`, `extraBackupArgs`, `environmentFile`. The module auto-initialises the repo, wires a systemd service + timer per backup set, and even produces a `restic-<name>` wrapper script for ad-hoc restores.

**Tags**

`#restic` `#backup` `#nixos-module` `#deduplication` `#encryption`

---

#### Restic NixOS module source (nixpkgs)

**Website**

https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/backup/restic.nix

**Description**

Direct link to the restic module source in nixpkgs. Useful when you need to understand how `rclone` remotes are wired (`rcloneOptionsFile`, `rcloneConfigFile`), how the `dynamicFilesFrom` script feeds paths to restic, or how `initialize` interacts with repo versions.

**Tags**

`#restic` `#nixpkgs` `#source` `#nixos-module`

---

#### Restic NixOS Wiki page

**Website**

https://wiki.nixos.org/wiki/Restic

**Description**

Official NixOS wiki article covering the module options, repository backends, secret handling for `passwordFile`/`environmentFile`, and worked examples for local, SFTP, and S3/MinIO repositories. Best starting point beyond the option search.

**Tags**

`#restic` `#backup` `#nixos-wiki`

---

#### BorgBackup (NixOS module: services.borgbackup.jobs)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.borgbackup.jobs

**Description**

Module for `borg` deduplicating encrypted backups. Each `services.borgbackup.jobs.<name>` declares `paths`, `repo` (local, SSH, or remote), `encryption.mode` (e.g. `repokey-blake2`), `passCommand`/`passwordFile`, `startAt`, `prune.keep`, plus `preHook`/`postHook` for snapshot integrations. Adds a `borg-job-<name>` wrapper script to `systemPackages` for manual maintenance.

**Tags**

`#borg` `#backup` `#nixos-module` `#deduplication` `#encryption`

---

#### BorgBackup NixOS module source (nixpkgs)

**Website**

https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/backup/borgbackup.nix

**Description**

Direct link to the borgbackup module source. Useful when integrating with LVM snapshots (`preHook` mounts the snapshot, `postHook` removes it) or understanding how the `borg-job-<name>` wrapper assembles environment variables for the SSH-based remote case.

**Tags**

`#borg` `#nixpkgs` `#source` `#nixos-module`

---

#### Borg Backup NixOS Wiki page

**Website**

https://wiki.nixos.org/wiki/Borg_backup

**Description**

NixOS wiki article with practical examples for local and remote (SSH) Borg backups, including secrets handling, retention/pruning schedules, and per-machine `jobs` patterns from real configs.

**Tags**

`#borg` `#backup` `#nixos-wiki`

---

#### resticprofile (NixOS package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=resticprofile

**Description**

A configuration manager for restic that bundles profiles (paths, retention, repository), schedules, and hooks into a single declarative YAML/TOML config — useful when the built-in `services.restic.backups` is too coarse (e.g. many profiles, pre/post scripts, multi-repo). Install via `environment.systemPackages`; wire schedules into systemd yourself or via a `systemd.services.resticprofile.<profile>` unit.

**Tags**

`#restic` `#backup` `#package` `#resticprofile`

---

#### rustic (NixOS package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=rustic

**Description**

A fast Rust restic client/library compatible with restic repositories. Useful as a drop-in for restic when initialising or restoring very large repositories (parallel file walks, faster `backup`/`restore`). On NixOS, install via `environment.systemPackages`; it shares your `RESTIC_REPOSITORY`/`RESTIC_PASSWORD_FILE` environment variables so it interops with existing `services.restic.backups` repos.

**Tags**

`#restic` `#backup` `#package` `#rustic` `#performance`

---

#### zfs-replication patterns (Discourse / Wiki)

**Website**

https://discourse.nixos.org/t/syncoid-questions/26411

**Description**

Community discussion on running multiple syncoid jobs in a single NixOS config, including timer overlap issues and per-job scheduling. Useful reference when the `services.syncoid.commands.<name>` timers all fire at the same instant and you want to stagger them.

**Tags**

`#zfs` `#syncoid` `#replication` `#community`

---

### 28. Databases (as NixOS services)

NixOS ships first-class modules for every major database server and most of the auxiliary tooling around them. Because the modules are declarative, a homelab operator can stand up Postgres + Postgres backups + pgbouncer + pgAdmin4 + a Redis cache in a single rebuild, all with explicit versions and ensureDatabases/ensureUsers semantics.

#### PostgreSQL (NixOS module: services.postgresql)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.postgresql

**Description**

The flagship NixOS database module. `services.postgresql.enable = true` plus `package` (pin to a specific major, e.g. `pkgs.postgresql_16`), `enableTCPIP`, `authentication`, `settings` (rendered to `postgresql.conf`), and `ensureDatabases`/`ensureUsers` for declarative provisioning of DBs and roles. Extensions are wired through `services.postgresql.extensions` and `package = pkgs.postgresql_<ver>.withPackages (p: [ p.postgis p.pgvector ... ])`. Default Unix socket in `/var/run/postgresql` with peer auth.

**Tags**

`#postgresql` `#database` `#nixos-module` `#relational`

---

#### PostgreSQL ensureDatabases / ensureUsers

**Website**

https://search.nixos.org/options?channel=unstable&show=services.postgresql.ensureDatabases

**Description**

Declarative database/role provisioning: `ensureDatabases = [ "firefly" "nextcloud" ]` and `ensureUsers = [ { name = "firefly"; ensureDBOwnership = true; } ]`. The module creates the listed DBs and roles on activation; it never deletes existing roles or revokes ownership, so it is safe to extend incrementally. Pairs with app modules that consume these DBs without requiring manual `psql` work.

**Tags**

`#postgresql` `#provisioning` `#nixos-module`

---

#### PostgreSQL extensions

**Website**

https://search.nixos.org/options?channel=unstable&show=services.postgresql.package

**Description**

Extensions on NixOS are pulled in by selecting a `postgresql.withPackages` build, e.g. `services.postgresql.package = pkgs.postgresql_16.withPackages (p: [ p.postgis p.pgvector p.timescaledb p.pgcron ])`. After rebuild, run `CREATE EXTENSION ...;` inside the database. The `pg_jsonschema`, `pg_cron`, `pgsodium`, and `hypopg` packages are all already in nixpkgs for homelab workloads.

**Tags**

`#postgresql` `#extensions` `#postgis` `#pgvector` `#nixos-module`

---

#### PostgreSQL backups (services.postgresqlBackup)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.postgresqlBackup

**Description**

Built-in `pg_dump`-based backup module: `services.postgresqlBackup.enable = true` plus `databases` (or `backupAll = true`), `location` (default `/var/backup/postgresql`), `startAt`, and `compression = "zstd"` produce one systemd service per database. Output is plain SQL (or `-Fc` custom format with `pgdumpOptions`). For PITR or block-level backups, layer pgbackrest or restic on the data directory.

**Tags**

`#postgresql` `#backup` `#pgdump` `#nixos-module`

---

#### PostgreSQL NixOS Wiki page

**Website**

https://wiki.nixos.org/wiki/PostgreSQL

**Description**

Official NixOS wiki page extending the manual: covers socket authentication, ensureDatabases/ensureUsers semantics, upgrading between major Postgres versions (data dir migration), and enabling TCP/IP. Essential reading before any major-version upgrade.

**Tags**

`#postgresql` `#nixos-wiki` `#upgrade`

---

#### PostgreSQL major version upgrade (community guide)

**Website**

https://kevincox.ca/2025/08/24/nixos-postgres-upgrade

**Description**

Step-by-step community article on migrating a NixOS Postgres data directory between major versions using the `pg_upgrade` binary that nixpkgs ships per-version. Covers the common trap of forgetting to include extensions in both `$pg_old` and `$pg_new` `withPackages` builds.

**Tags**

`#postgresql` `#upgrade` `#community` `#pg_upgrade`

---

#### MariaDB (NixOS module: services.mariadb)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.mariadb

**Description**

The recommended MySQL-compatible server on NixOS. `services.mariadb.enable = true` plus `package` (default `pkgs.mariadb`), `settings` (rendered to `.cnf` files under `/etc/my.cnf.d/`), `ensureDatabases`, and `ensureUsers` give declarative provisioning analogous to the Postgres module. Use this in preference to the legacy `services.mysql` module.

**Tags**

`#mariadb` `#mysql` `#database` `#nixos-module` `#relational`

---

#### MySQL (NixOS module: services.mysql)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.mysql

**Description**

Legacy module (still in nixpkgs) for Oracle MySQL / MySQL-compatible servers. Mostly superseded by `services.mariadb` and `services.mysql` flavour switching. Still useful when an application explicitly requires Oracle MySQL rather than MariaDB; check the option `services.mysql.package` to choose between `pkgs.mysql80`, `pkgs.mariadb`, etc.

**Tags**

`#mysql` `#database` `#nixos-module` `#relational`

---

#### Redis (NixOS module: services.redis)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.redis

**Description**

Module for Redis key/value cache & store. Each `services.redis.servers.<name>` is an isolated Redis instance with its own `bind`, `port`, `unixSocket`, `databases`, `logfile`, `save` (RDB schedule), and `appendOnly` config. The NixOS module writes a separate systemd unit per server, so you can run a cache instance and a queue instance side-by-side on the same host.

**Tags**

`#redis` `#cache` `#database` `#nixos-module` `#keyvalue`

---

#### Redis Sentinel (services.redis.servers.<name>.sentinel)

**Website**

https://search.nixos.org/options?channel=unstable&query=sentinel

**Description**

NixOS can run a Redis Sentinel instance alongside a Redis server by setting `services.redis.servers.<name>.sentinel = true` plus `sentinelMaster`, `sentinelMasterHost`, `sentinelMasterPort`, and `sentinelQuorum`. Provides automatic failover for a primary/replica Redis setup — useful when Redis is on the critical path for Nextcloud session storage or an Authentik cache.

**Tags**

`#redis` `#sentinel` `#failover` `#nixos-module`

---

#### MongoDB (NixOS module: services.mongodb)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.mongodb

**Description**

NixOS module for MongoDB. `services.mongodb.enable = true` plus `bind_ip`, `port`, `enableAuth`, `initialRootPassword`, `dbpath`, and `extraConfig` configure `mongod`. Useful for older homelab stacks (e.g. greylog, unpoller). Note that newer MongoDB versions are not freely redistributable due to the SSPL licence; the nixpkgs package may lag behind upstream for that reason.

**Tags**

`#mongodb` `#database` `#nosql` `#nixos-module`

---

#### ClickHouse (NixOS module: services.clickhouse)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.clickhouse

**Description**

Module for the ClickHouse column-oriented OLAP database. `services.clickhouse.enable = true` plus `package = pkgs.clickhouse` runs the server under systemd with config rendered from `services.clickhouse.config` and `extraConfig` to `/etc/clickhouse-server/`. Excellent for storing high-cardinality metrics or logs from Vector/Telegraf in a homelab.

**Tags**

`#clickhouse` `#olap` `#database` `#nixos-module` `#analytics`

---

#### ClickHouse on NixOS (upstream docs)

**Website**

https://clickhouse.com/docs/get-started/setup/self-managed/nixos

**Description**

Official ClickHouse documentation page describing installation on NixOS via nixpkgs. Covers the package, the `services.clickhouse` module, and how to apply configuration changes through NixOS rebuilds. Good complement to the option search page.

**Tags**

`#clickhouse` `#upstream` `#docs` `#nixos`

---

#### InfluxDB 2.x (NixOS module: services.influxdb2)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.influxdb2

**Description**

Module for InfluxDB v2 (Flux query language, token-based auth, bundled UI). `services.influxdb2.enable = true` plus `settings` (rendered to `config.toml`), `bolt-path`, `engine-path`, and a systemd unit. Use this — not the legacy `services.influxdb` module — for new time-series workloads (Home Assistant long-term stats, Telegraf metrics, ESPHome sensor data).

**Tags**

`#influxdb` `#timeseries` `#database` `#nixos-module`

---

#### SQLite usage patterns on NixOS

**Website**

https://search.nixos.org/packages?channel=unstable&query=sqlite

**Description**

SQLite is not a *service* on NixOS; it is a library that ships via `pkgs.sqlite` (and per-app builds link against it). The NixOS pattern is: install the app (e.g. `services.nextcloud`, headscale, komga) which creates its own SQLite DB in `services.<app>.dataDir`, then back up that file via `services.restic.backups` or `services.borgbackup.jobs` with a `preHook` that runs `sqlite3 file '.backup' /tmp/snapshot.db` to avoid torn writes. Most small homelab apps default to SQLite with no module configuration needed.

**Tags**

`#sqlite` `#embedded` `#backup` `#pattern`

---

#### pgAdmin4 (NixOS module: services.pgadmin)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.pgadmin

**Description**

Module for the pgAdmin4 web UI. `services.pgadmin.enable = true` plus `initialEmail`, `initialPasswordFile`, `port`, `settings` (server-side config), and `listenAddress` launch the pgAdmin4 application server behind systemd. Pairs naturally with a local Postgres instance on a homelab; recommended to put it behind a TLS-terminating reverse proxy (Caddy/Traefik/nginx) and restrict access.

**Tags**

`#pgadmin` `#postgresql` `#gui` `#nixos-module`

---

#### pgbouncer (NixOS module: services.pgbouncer)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.pgbouncer

**Description**

Module for the Postgres connection pooler. `services.pgbouncer.enable = true` plus `settings` (a Nix attrset rendered to `pgbouncer.ini`) including `databases`, `users`, `pool_mode = "transaction"`, `max_client_conn`, and `listen_addr`/`listen_port`. Essential in front of Postgres when an app uses many short-lived connections (Grafana, Nextcloud, Authentik, Synapse) to avoid Postgres connection-setup overhead.

**Tags**

`#pgbouncer` `#postgresql` `#pooling` `#nixos-module`

---

#### pgbackrest (NixOS package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=pgbackrest

**Description**

Powerful Postgres backup tool with full, incremental, and differential backups, WAL archiving for PITR, repository encryption, and parallelism. Install via `environment.systemPackages`; there is no dedicated `services.pgbackrest` module in nixpkgs, so wire it as a systemd service + timer yourself (or via `systemd.services.pgbackrest` and a `systemd.timers.pgbackrest`), pointing the stanza config at your Postgres data dir. A heavier alternative to `services.postgresqlBackup` when you need PITR.

**Tags**

`#pgbackrest` `#postgresql` `#backup` `#pitr` `#package`

---

#### PostgreSQL module source (nixpkgs)

**Website**

https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.nix

**Description**

Direct link to the upstream NixOS Postgres module source. Useful for reading the exact `ensureUsers` semantics (e.g. `ensureDBOwnership` grants ownership to a same-named database), how `settings` are rendered into `postgresql.conf`, and how `services.postgresql.enableJIT` flips LLVM JIT on.

**Tags**

`#postgresql` `#nixpkgs` `#source` `#nixos-module`

---


---

## Part VIII — Self-Hosted Applications & Identity

### 29. Self-Hosted Applications on NixOS

NixOS ships first-class modules for almost every popular self-hosted application, meaning `services.<name>.enable = true;` is usually all that is needed to get a declarative, reproducible service with a systemd unit, a dedicated system user, and a sane data directory under `/var/lib/<name>`. The entries below pair the NixOS module option search (canonical source of truth for option names and defaults) with the upstream project and, where applicable, the NixOS wiki guide.

#### Nextcloud (NixOS module)

**Website**

https://search.nixos.org/options?query=services.nextcloud

**Description**

The `services.nextcloud` module provisions a Nextcloud instance with PHP-FPM, nginx (or your own webserver), and an auto-configured database. It supports declarative configuration (`services.nextcloud.config.*`) for admin password, DB credentials, and trusted domains, plus automated major-version upgrades via `services.nextcloud.package` and `systemd.services.nextcloud-setup`. For a homelab this means a single flake rebuild can move a Nextcloud install between machines or roll back a botched upgrade.

**Tags**

`#nixos-module` `#file-sync` `#self-hosted` `#php`

---

#### Nextcloud Caching (Redis)

**Website**

https://search.nixos.org/options?query=services.nextcloud.config.redis

**Description**

Nextcloud strongly recommends Redis for both memory caching (memcache.distributed, memcache.locking) and transactional file locking. On NixOS you set `services.nextcloud.config.redis.host = "/run/redis-nextcloud/redis.sock";` together with `services.redis.servers.nextcloud.enable = true;` — the module writes the correct `config.php` entries for you. This is the difference between a Nextcloud install that stalls under concurrent load and one that stays responsive.

**Tags**

`#nixos-module` `#nextcloud` `#redis` `#performance`

---

#### Nextcloud Apps (extraApps)

**Website**

https://search.nixos.org/options?query=services.nextcloud.extraApps

**Description**

The `services.nextcloud.extraApps` option lets you declaratively install Nextcloud apps from nixpkgs (e.g. `pkgs.nextcloud-apps.calendar`, `pkgs.nextcloud-apps.contacts`, `pkgs.nextcloud-apps.news`, `pkgs.nextcloud-apps.tasks`) and have them enabled at provisioning time via `services.nextcloud.extraAppsEnable = true;`. Apps are pinned to the NixOS generation, so an unintended app upgrade can never surprise you — and a rollback reverts app versions too.

**Tags**

`#nixos-module` `#nextcloud` `#declarative-apps` `#php`

---

#### nextcloud-occ (occ wrapper)

**Website**

https://search.nixos.org/packages?query=nextcloud-occ

**Description**

Nixpkgs ships a `nextcloud-occ` package — a wrapper script that invokes Nextcloud's `occ` console correctly under the NixOS PHP-FPM environment (correct user, correct `NEXTCLOUD_CONFIG_DIR`, correct PHP). Combined with the `services.nextcloud.occ` option (which makes `occ` available system-wide), it removes the need to `sudo -u nextcloud php occ ...` boilerplate. Useful for cron-driven `files:scan`, app:install, and user provisioning in a homelab.

**Tags**

`#nixos-package` `#nextcloud` `#cli` `#admin`

---

#### Home Assistant

**Website**

https://search.nixos.org/options?query=services.home-assistant

**Description**

The `services.home-assistant` module runs Home Assistant as a systemd service using Nixpkgs' `home-assistant` Python package, with declarative `configDir` (default `/var/lib/hass`) and `configWritable` toggling whether HA may write to its own YAML. The NixOS module also lets you pass extra Python components via `services.home-assistant.customComponents`, and `services.home-assistant.customLovelaceModules` for HACS-style dashboard widgets — all reproducible from a flake.

**Tags**

`#nixos-module` `#home-automation` `#iot` `#python`

---

#### simple-nixos-mailserver (SNM)

**Website**

https://gitlab.com/simple-nixos-mailserver/nixos-mailserver

**Description**

The canonical "batteries-included" mailserver flake for NixOS — wraps Postfix, Dovecot, Rspamd, ClamAV, OpenDKIM, and Postfixadmin-style declarative user/domain config behind a single `mailserver.*` option namespace. Imported as a flake input (`inputs.simple-nixos-mailserver.nixosModule`), it gives you SPF/DKIM/DMARC, per-domain mailboxes under `/var/vmail`, and a single declarative `mailserver.users` list. Still the most popular way to host mail on NixOS.

**Tags**

`#nixos-flake-module` `#mail-server` `#postfix` `#dovecot` `#rspamd`

---

#### Stalwart Mail Server

**Website**

https://search.nixos.org/options?query=services.stalwart-mail

**Description**

Stalwart is a modern all-in-one Rust mail server (SMTP, IMAP4rev2, JMAP, POP3) with built-in DKIM/SPF/DMARC/ARC and an integrated ACME client. The NixOS `services.stalwart-mail` module ships in nixpkgs and exposes `services.stalwart-mail.settings` (a freeform attrset written to the TOML config) plus `services.stalwart-mail.enable`. A good choice for homelabs that want a single binary mailserver with strong defaults and no separate MTA/MDA/antispam stack to glue together.

**Tags**

`#nixos-module` `#mail-server` `#jmap` `#rust`

---

#### mailcow:dockerized (on NixOS)

**Website**

https://github.com/mailcow/mailcow-dockerized

**Description**

mailcow is a popular Dockerized mail suite (Postfix, Dovecot, SOGo, Rspamd, ACME, admin UI). There is **no native `services.mailcow` module in nixpkgs** — the supported pattern on NixOS is to run the upstream `mailcow-dockerized` compose via `virtualisation.docker.compose` or `virtualisation.arion.projects`. Useful if you want the mailcow admin UI but be aware you're stepping outside the declarative NixOS module model; back up `/var/lib/docker/volumes/mailcowdockerized_*` separately.

**Tags**

`#docker-compose` `#mail-server` `#not-in-nixpkgs` `#arion`

---

#### Postfix (NixOS module)

**Website**

https://search.nixos.org/options?query=services.postfix

**Description**

The `services.postfix` module is the lowest-level building block for an MTA on NixOS — `services.postfix.enable = true;` plus `services.postfix.domain`, `services.postfix.origin`, `services.postfix.destination`, `services.postfix.relayHost` (for smarthost setups), and `services.postfix.config` for arbitrary `main.cf` keys. For a homelab it is commonly used as a send-only relay (via a tunnel like SendGrid, SES, or a smarthost) for system cron/raid/fail2ban notifications.

**Tags**

`#nixos-module` `#mta` `#postfix` `#smtp`

---

#### Dovecot (NixOS module)

**Website**

https://search.nixos.org/options?query=services.dovecot

**Description**

The `services.dovecot` module configures Dovecot IMAP/POP3/LMTP with declarative `services.dovecot.mailLocation` (e.g. `maildir:/var/mail/%u` or the vmail-style `mdbox:~/mail`), `services.dovecot.sslServerCert`, and `services.dovecot.extraConfig` for arbitrary `dovecot.conf` stanzas. Pair with Postfix for delivery and an authentication backend (PassDB/SQL/LDAP) for multi-user homelab IMAP.

**Tags**

`#nixos-module` `#imap` `#dovecot` `#mail-server`

---

#### Rspamd (NixOS module)

**Website**

https://search.nixos.org/options?query=services.rspamd

**Description**

Rspamd is a fast, modular spam-filtering system that has largely replaced SpamAssassin in modern mailstacks. The NixOS `services.rspamd` module starts the `rspamd` controller and worker processes, exposes `services.rspamd.overrides` for dropping in custom lua/local.d configuration, and ships with sensible DKIM/SPF/DMARC module defaults. The bundled web UI (`services.rspamd.workers.controller.bindSocket`) is the easiest way to tune scores and watch spam flow in real time.

**Tags**

`#nixos-module` `#antispam` `#rspamd` `#mail-server`

---

#### Vaultwarden

**Website**

https://search.nixos.org/options?query=services.vaultwarden

**Description**

Vaultwarden is the lightweight Rust reimplementation of the Bitwarden server API. The `services.vaultwarden` module in nixpkgs configures the binary, the database (SQLite by default, configurable to PostgreSQL/MySQL), and a reverse-proxy-friendly listening socket (`services.vaultwarden.config.ROCKET_ADDRESS`). For a homelab it is the recommended way to self-host Bitwarden clients (mobile + browser extension + desktop) without running the heavy official `bitwarden-server` Docker stack.

**Tags**

`#nixos-module` `#password-manager` `#bitwarden` `#rust`

---

#### Paperless-ngx

**Website**

https://search.nixos.org/options?query=services.paperless

**Description**

Paperless-ngx is a document management system that OCRs and indexes scanned PDFs. The NixOS `services.paperless` module sets up the Django app, a Redis broker, a Tika/Gotenberg consumer pipeline, and the `document-consumer` systemd service that watches an input directory (`services.paperless.consumptionDir`). For a homelab it provides a one-stop "scan → OCR → full-text-search" pipeline that is fully reproducible from a flake.

**Tags**

`#nixos-module` `#document-management` `#ocr` `#python`

---

#### Forgejo

**Website**

https://search.nixos.org/options?query=services.forgejo

**Description**

Forgejo is the community-owned soft fork of Gitea (Codeberg / forgejo.org). The `services.forgejo` module mirrors the Gitea module shape (`services.forgejo.settings.database.*`, `services.forgejo.settings.server.*`, `services.forgejo.lfs.enable`) but runs the Forgejo binary and serves the Forgejo UI. Recommended over Gitea for homelabs that want long-term community governance and the Forgejo Actions runner (`services.gitea-actions-runner` works for both).

**Tags**

`#nixos-module` `#git` `#forgejo` `#ci`

---

#### Gitea

**Website**

https://search.nixos.org/options?query=services.gitea

**Description**

The `services.gitea` module runs the upstream Gitea binary with a declarative `services.gitea.settings` attrset that maps directly to `app.ini`. It supports SQLite, MySQL, and PostgreSQL backends, built-in LFS (`services.gitea.lfs.enable`), and ships alongside `services.gitea-actions-runner` for hosted CI. Still a solid choice, though many NixOS homelabs have migrated to Forgejo.

**Tags**

`#nixos-module` `#git` `#gitea` `#ci`

---

#### Immich

**Website**

https://search.nixos.org/options?query=services.immich

**Description**

Immich is a self-hosted Google Photos alternative (photo/video backup, machine-learning-powered search, face recognition, shared albums). It landed in nixpkgs in late 2024 (PR #324127) as a `services.immich` module that provisions the server, machine-learning, and redis containers/units in one go. `services.immich.settings` accepts the upstream JSON config (with `file`/`envFile` for secrets) and `services.immich.mediaLocation` controls the `/var/lib/immich` library path.

**Tags**

`#nixos-module` `#photos` `#machine-learning` `#self-hosted`

---

#### BookStack

**Website**

https://search.nixos.org/options?query=services.bookstack

**Description**

BookStack is a simple, opinionated wiki/CMS for documentation, organized as Books → Chapters → Pages. The `services.bookstack` module in nixpkgs runs the PHP app under PHP-FPM, auto-provisions the database schema, and exposes `services.bookstack.config` for the upstream `.env` keys (APP_URL, MAIL_* etc.). For a homelab it is a low-friction documentation platform with WYSIWYG Markdown editing and LDAP/OIDC SSO support.

**Tags**

`#nixos-module` `#wiki` `#documentation` `#php`

---

#### Mastodon

**Website**

https://search.nixos.org/options?query=services.mastodon

**Description**

The `services.mastodon` module runs the full Mastodon federated-social stack — web (Rails), streaming (Node), and Sidekiq workers — as separate systemd units, with a managed PostgreSQL/Redis, `services.mastodon.config.*` for the upstream `.env` keys, and `services.mastodon.elasticsearch.host` for full-text search. The NixOS module is one of the few turnkey ways to self-host Mastodon without Docker, and is used in production by several single-admin instances.

**Tags**

`#nixos-module` `#fediverse` `#activitypub` `#rails`

---

#### Gotify

**Website**

https://search.nixos.org/options?query=services.gotify

**Description**

Gotify is a simple self-hosted push-notification server with a clean REST API, a web UI, and Android/iOS clients. The `services.gotify` module runs the Go binary, exposes `services.gotify.config` (server.listen.port, registration, stream, database, etc. — a freeform attrset), and supports SSL via `services.gotify.config.server.ssl`. Ideal for routing Home Assistant, Grafana, and CI notifications to your phone without depending on Google/Apple push infrastructure.

**Tags**

`#nixos-module` `#push-notifications` `#go` `#self-hosted`

---

#### ntfy.sh

**Website**

https://search.nixos.org/options?query=services.ntfy-sh

**Description**

ntfy is a pub/sub-based notification service (HTTP PUT/POST → everyone subscribed on a topic receives the message) with both a web UI and excellent Android/iOS clients. The `services.ntfy-sh` module exposes `services.ntfy-sh.settings` (a freeform attrset written to `server.yml`) covering listen address, attachment storage, auth (SQLite/MySQL/Postgres), and upstream ntfy servers to forward to. A modern, open alternative to Gotify with a cleaner protocol.

**Tags**

`#nixos-module` `#push-notifications` `#pubsub` `#go`

---

#### Matrix Synapse

**Website**

https://search.nixos.org/options?query=services.matrix-synapse

**Description**

Synapse is the reference Matrix homeserver (Python/Twisted), still the most feature-complete server for federated, end-to-end-encrypted chat. The `services.matrix-synapse` module is mature — `services.matrix-synapse.settings` (freeform attrset → `homeserver.yaml`), `services.matrix-synapse.extraConfigFiles` for secrets, `services.matrix-synapse-with-plugins-wrapper` for opt-in plugins, and `services.matrix-synapse.enableRegistration`/`registrations-*` for application services. The default for any production-grade Matrix homelab.

**Tags**

`#nixos-module` `#matrix` `#chat` `#e2ee`

---

#### Matrix Dendrite

**Website**

https://search.nixos.org/options?query=services.matrix-dendrite

**Description**

Dendrite is Element's second-generation Matrix homeserver written in Go — lighter on memory and faster on cold start than Synapse, at the cost of some protocol edge cases. The `services.matrix-dendrite` module exposes `services.matrix-dendrite.settings` (freeform → `dendrite.yaml`), supports SQLite or PostgreSQL backends, and runs the monolith server. A reasonable choice for a small single-admin homelab where Synapse's RAM footprint is too high.

**Tags**

`#nixos-module` `#matrix` `#chat` `#go`

---

#### Matrix Conduit / Conduwuit

**Website**

https://search.nixos.org/options?query=services.matrix-conduit

**Description**

Conduit is a community Rust Matrix server focused on simplicity and low resource use; conduwuit is a popular hard fork that supersedes it upstream. The `services.matrix-conduit` module in nixpkgs runs the upstream Conduit binary, with `services.matrix-conduit.settings` (freeform → `conduit.toml`) and a SQLite or PostgreSQL backend. For the conduwuit fork specifically, install the `conduwuit` package and reuse the same module. Smallest Matrix server you can run on a homelab.

**Tags**

`#nixos-module` `#matrix` `#rust` `#chat`

---

#### Element Web

**Website**

https://search.nixos.org/options?query=services.element-web

**Description**

Element Web is the reference Matrix client (browser-based). The `services.element-web` module in nixpkgs serves a pre-built static bundle via nginx and lets you declaratively configure it through `services.element-web.config` (default homeserver, server name, branding, integration manager, Jitsi config). Pair with Synapse/Dendrite/Conduit to give homelab users a friendly client URL (`https://chat.example.com`) without sending them to app.element.io.

**Tags**

`#nixos-module` `#matrix` `#web-client` `#element`

---

#### Linkding

**Website**

https://search.nixos.org/options?query=services.linkding

**Description**

Linkding is a lightweight, self-hosted bookmark manager with a clean web UI, REST API, browser extension, and tag-based search. The `services.linkding` module in nixpkgs runs the Python/Django app under uwsgi, auto-provisions the SQLite DB, and exposes `services.linkding.config` for upstream settings. A great "low-end-box" replacement for Pinboard — runs comfortably on a Raspberry Pi.

**Tags**

`#nixos-module` `#bookmarks` `#python` `#self-hosted`

---

#### Wallabag

**Website**

https://search.nixos.org/options?query=services.wallabag

**Description**

Wallabag is a self-hosted "read-it-later" service (alternative to Pocket / Instapaper) that extracts article content, caches it offline, and supports tagging and RSS/ATOM export. The `services.wallabag` module runs the PHP/Symfony app under PHP-FPM, auto-installs the database schema, and exposes `services.wallabag.config` for the upstream parameters (domain name, mailer, Redis, RabbitMQ). Useful for archiving articles behind paywalls or to strip ad/JS bloat before reading.

**Tags**

`#nixos-module` `#read-it-later` `#php` `#self-hosted`

---

#### Joplin Server

**Website**

https://search.nixos.org/options?query=services.joplin-server

**Description**

Joplin Server is the official self-hostable sync server for Joplin (the open-source Evernote alternative), supporting E2EE, sharing, and user accounts. The `services.joplin-server` module runs the Node.js app under systemd, manages a PostgreSQL database, and exposes `services.joplin-server.config` for the upstream env vars (APP_BASE_URL, MAILER_*, etc.). Lets you sync Joplin desktop/mobile clients across devices without depending on Dropbox/WebDAV.

**Tags**

`#nixos-module` `#notes` `#joplin` `#self-hosted`

---

#### Radicale (CalDAV/CardDAV)

**Website**

https://search.nixos.org/options?query=services.radicale

**Description**

Radicale is a small, fast CalDAV/CardDAV server in Python — perfect for self-hosting calendar and contact sync for DAVx5 on Android, Apple Calendar, Thunderbird, etc. The `services.radicale` module exposes `services.radicale.config` (freeform → `radicale.conf` sections, including the new-style `services.radicale.config.auth.type = "htpasswd"`), and `services.radicale.rightsPath` for ACL files. A pragmatic lightweight alternative to running Nextcloud just for calendar/contacts.

**Tags**

`#nixos-module` `#caldav` `#carddav` `#calendar`

---

### 30. Identity & Access Management (SSO) on NixOS

These modules provide the central identity layer (LDAP, OIDC, SAML, SCIM) that every other self-hosted service on a NixOS homelab can authenticate against. Most ship as native `services.<name>` modules in nixpkgs; **Authentik is the notable exception** — as of NixOS 26.05 it has no upstream module and must be installed via the `nix-community/authentik-nix` flake, or run as a Docker/arion stack.

#### Authentik (community module)

**Website**

https://github.com/nix-community/authentik-nix

**Description**

Authentik is a flexible identity provider supporting OIDC, SAML, LDAP outpost, and SCIM provisioning, with a flow-based visual policy engine. There is **no `services.authentik` module in nixpkgs as of NixOS 26.05** — the supported path is `nix-community/authentik-nix`, which provides `services.authentik-server` and `services.authentik-worker` (each with `settings`), a local PostgreSQL by default, and Redis. Import the flake input in your config and pair with `services.authentik-server` for the web/API and `services.authentik-worker` for background tasks.

**Tags**

`#nixos-flake-module` `#sso` `#oidc` `#saml` `#not-in-nixpkgs`

---

#### Keycloak

**Website**

https://search.nixos.org/options?query=services.keycloak

**Description**

Keycloak is the well-known enterprise-grade IAM server (OIDC, SAML 2.0, LDAP federation, social login). The NixOS `services.keycloak` module is one of the most polished in nixpkgs — `services.keycloak.settings` (freeform → `keycloak.conf`), `services.keycloak.database` (auto-provisions PostgreSQL or supports an external host), `services.keycloak.initialAdminPassword`, and `services.keycloak.themes` for packaging custom themes. The default "boring, reliable SSO" choice for a homelab.

**Tags**

`#nixos-module` `#sso` `#oidc` `#saml` `#java`

---

#### Authelia

**Website**

https://search.nixos.org/options?query=services.authelia

**Description**

Authelia is an IAM server that shines as a forward-auth companion to Traefik/nginx — it does OIDC, SAML, and (most importantly) 2FA-enforced reverse-proxy auth with a polished login portal. The `services.authelia` module exposes `services.authelia.instances.<name>` (multi-instance capable), `services.authelia.instances.<name>.settings` (freeform → `configuration.yml`), and `services.authelia.instances.<name>.secrets` for file-based secret injection. Great for protecting services that don't natively speak OIDC.

**Tags**

`#nixos-module` `#sso` `#forward-auth` `#2fa` `#go`

---

#### Kanidm

**Website**

https://search.nixos.org/options?query=services.kanidm

**Description**

Kanidm is a modern Rust identity platform (LDAPv3, OIDC, RADIUS, SCIM) with strong defaults around mTLS and a clean REST API. The `services.kanidm` module runs both `kanidmd` (`services.kanidm.serverSettings`) and an optional `kanidm-unixd` for PAM/NSS (`services.kanidm.clientSettings`), plus `services.kanidm.provision` for declarative bootstrap of users, groups, and OAuth2 client configurations on first start. A great fit for homelabs that want one modern identity backend for both apps and shell logins.

**Tags**

`#nixos-module` `#iam` `#ldap` `#oidc` `#rust`

---

#### Kanidm unixd (PAM/NSS integration)

**Website**

https://search.nixos.org/options?query=services.kanidm.enableUnixd

**Description**

`kanidm-unixd` is the userspace daemon that exposes Kanidm accounts to Linux via NSS/PAM (so `getent passwd` and SSH logins resolve against Kanidm). On NixOS it is enabled by default when `services.kanidm.enableUnixd = true;` (or `services.kanidm.enable = true;`), with `services.kanidm.clientSettings` pointed at your Kanidm server. Lets you centralize shell/SSH logins across multiple NixOS machines without copying `/etc/shadow` around.

**Tags**

`#nixos-module` `#pam` `#nss` `#kanidm` `#ssh`

---

#### ZITADEL

**Website**

https://search.nixos.org/options?query=services.zitadel

**Description**

ZITADEL is an enterprise-style cloud-native IAM (multi-tenant by design, OIDC, SAML, SCIM 2.0, actions/flows) written in Go. The `services.zitadel` module exposes `services.zitadel.settings` (freeform → `zitadel.yaml`), `services.zitadel.masterKeyFile`/`secretKeyFile` for secrets, and `services.zitadel.stepSchema` for idempotent bootstrap. Note: as of 2024 the module has known issues with PostgreSQL backend (defaulting to CockroachDB) — see nixpkgs issue #338094 if you intend to use Postgres.

**Tags**

`#nixos-module` `#sso` `#oidc` `#saml` `#go`

---

#### lldap

**Website**

https://search.nixos.org/options?query=services.lldap

**Description**

lldap is a deliberately simple LDAP server with an integrated web admin UI, written in Rust — it focuses on authentication only (no fancy group-policy engine). The `services.lldap` module exposes `services.lldap.settings` (freeform → `lldap_config.toml`), `services.lldap.environmentFile` for secrets like `LLDAP_LDAP_USER_PASS_FILE`, and out-of-the-box reverse-proxy-friendly HTTP and LDAP(S) ports. The "I just want LDAP for Authelia/Keycloak/proxy auth" choice.

**Tags**

`#nixos-module` `#ldap` `#auth` `#rust`

---

#### Ory Kratos

**Website**

https://search.nixos.org/packages?query=ory-kratos

**Description**

Ory Kratos is an API-first identity management system (registration, login, MFA, account recovery, social/oidc sign-in, identity schemas) designed to be embedded into your own UI rather than providing a hosted one. Nixpkgs ships the `ory-kratos` binary; there is no first-class `services.ory-kratos` module in nixpkgs, so you wire it up via `systemd.services.ory-kratos` with `EnvironmentFile` and your own `kratos.yaml`. Pair with Ory Hydra for OAuth2/OIDC provider capabilities and Ory Keto for fine-grained authorization.

**Tags**

`#nixos-package` `#identity` `#api-first` `#go` `#no-module`

---

#### Ory Hydra

**Website**

https://search.nixos.org/packages?query=ory-hydra

**Description**

Ory Hydra is a certified OAuth 2.0 and OpenID Connect provider — API-only, so you build the login/consent UI yourself (or use Kratos for the identity layer). Nixpkgs ships the `ory-hydra` binary; like Kratos there is **no first-class `services.ory-hydra` module**, so deployment is via a custom `systemd.services.ory-hydra` with `hydra.yaml` and a `--public`/`--admin` port split. A common building block for homelabs that need to act as their own OIDC IdP without adopting Keycloak's UI.

**Tags**

`#nixos-package` `#oauth2` `#oidc` `#go` `#no-module`

---

#### Dex

**Website**

https://search.nixos.org/options?query=services.dex

**Description**

Dex is an OIDC identity provider that acts as a **connector** to upstream IdPs (LDAP, SAML, GitHub, Google, Microsoft, GitLab, etc.) — useful when your apps speak OIDC but your real identity source is, say, lldap or an upstream SAML IdP. The `services.dex` module exposes `services.dex.settings` (freeform → `config.yaml`), `services.dex.environmentFile` for client secrets, and runs the dex binary under systemd. A pragmatic way to "OIDC-ify" an LDAP-backed homelab.

**Tags**

`#nixos-module` `#oidc` `#saml-bridge` `#go`

---

#### OAuth2 Proxy

**Website**

https://search.nixos.org/options?query=services.oauth2-proxy

**Description**

OAuth2 Proxy is the canonical reverse-proxy-side authentication shim — it sits in front of an arbitrary HTTP service, redirects unauthenticated users to an OIDC provider (Google, GitHub, Keycloak, Authentik, Dex, …), validates the returned token, and forwards the request with `X-Forwarded-User`/`X-Forwarded-Email`/`X-Forwarded-Preferred-Username` headers. The `services.oauth2-proxy` module exposes `services.oauth2-proxy.config` (cookie secret, client ID/secret, upstream, email domains, OIDC issuer URL, allowed groups). The easiest way to SSO-protect services like Prometheus, Alertmanager, or Radicale that lack native OIDC support.

**Tags**

`#nixos-module` `#sso` `#reverse-proxy` `#oidc` `#forward-auth`

---


---

## Part IX — Media Stack

### 31. Media Servers on NixOS

NixOS ships first-class modules for every major self-hosted media server, so a homelab operator can deploy Jellyfin/Plex/Emby/Navidrome/Audiobookshelf/Komga/Kavita/calibre-web purely declaratively. Enable the module, point `dataDir`/`library` at a ZFS or mergerfs-backed pool, and the systemd unit + user + firewall openings are handled for you.

#### Jellyfin (services.jellyfin)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.jellyfin

**Description**

Free, open-source, self-hosted media server — an Emby/Plex alternative with no telemetry. The NixOS `services.jellyfin.enable` module pulls in jellyfin-web, jellyfin-server, and ffmpeg, opens the firewall for 8096, and creates the `jellyfin` user. Combine with `hardware.opengl` (or `hardware.graphics` on 24.11+) and `nixpkgs.config.allowUnfree = false` to keep a fully FOSS stack with VA-API/NVENC hardware transcoding.

**Tags**

`#media-server` `#nixos-module` `#jellyfin` `#transcoding`

---

#### Jellyfin Upstream

**Website**

https://github.com/jellyfin/jellyfin

**Description**

Upstream .NET server project. Useful as the canonical source for release notes, plugin matrix, and security advisories. The NixOS module wraps this directly via `pkgs.jellyfin`, so the upstream changelog is the right place to look when a NixOS upgrade bumps the Jellyfin version.

**Tags**

`#media-server` `#upstream` `#jellyfin`

---

#### Plex (services.plex)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.plex

**Description**

Closed-source but free-to-use media server with the most polished client ecosystem. The NixOS module handles the systemd service, the `plex` user, and the `/var/lib/plex` data directory. Because the official Plex Pass build is unfree, you typically need `nixpkgs.config.allowUnfree = true` (or an overlay) to enable hardware transcoding. Claiming the server still requires the Plex online flow on first boot.

**Tags**

`#media-server` `#nixos-module` `#plex` `#unfree`

---

#### Plex Upstream

**Website**

https://www.plex.tv/

**Description**

Vendor site for Plex Media Server downloads, Plex Pass subscription (required for hardware transcoding, trailer/early-releases, and DVR), and the mobile/TV client apps. The NixOS module's `services.plex.package` defaults to `pkgs.plexRaw`, the unpacked RPM that the upstream provides.

**Tags**

`#media-server` `#upstream` `#plex`

---

#### Emby (services.emby)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.emby

**Description**

The original closed-source fork that Jellyfin split from; still actively developed and a good middle ground between Plex's polish and Jellyfin's openness. The NixOS module mirrors the Jellyfin module in shape (enable, openFirewall, user, dataDir). Requires `allowUnfree` for the Premiere tier features.

**Tags**

`#media-server` `#nixos-module` `#emby`

---

#### Navidrome (services.navidrome)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.navidrome

**Description**

Lightweight Subsonic-API-compatible music server written in Go. The NixOS module (`services.navidrome.enable`, `services.navidrome.settings`) lets you set every Navidrome YAML option as a Nix attribute set, plus a first-class `services.navidrome.plugins` option for Subsonic plugins (added in nixpkgs 24.11+). Pair with the Tempo/DroidSub/Symfonium mobile clients for an Apple-Music-like homelab experience.

**Tags**

`#media-server` `#nixos-module` `#navidrome` `#music` `#subsonic`

---

#### Navidrome NixOS Wiki Page

**Website**

https://wiki.nixos.org/wiki/Navidrome

**Description**

Community-maintained wiki page with worked configuration examples (reverse proxying behind nginx, scanning a networked music library, enabling Last.fm scrobbling). Worth reading alongside the option list because it covers the gotchas the option docs don't.

**Tags**

`#media-server` `#wiki` `#navidrome`

---

#### Audiobookshelf (services.audiobookshelf)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.audiobookshelf

**Description**

Self-hosted audiobook and podcast server with a polished mobile client, automatic metadata scraping, and per-user progress sync. The NixOS module exposes `services.audiobookshelf.enable`, `services.audiobookshelf.host`, `services.audiobookshelf.port`, and `services.audiobookshelf.dataDir`. The upstream Linux install docs explicitly point at the NixOS module as the supported path.

**Tags**

`#media-server` `#nixos-module` `#audiobooks` `#podcasts`

---

#### Audiobookshelf NixOS Install Docs (Upstream)

**Website**

https://audiobookshelf.org/docs/documentation/install/linux/linux-install-nix

**Description**

The official Audiobookshelf Linux/NixOS installation page that explicitly documents `services.audiobookshelf.enable = true` as the recommended deployment path. Useful as a citable reference when convincing colleagues that NixOS is a first-class target for ABS, not a hack.

**Tags**

`#media-server` `#upstream` `#audiobooks` `#documentation`

---

#### Komga (services.komga)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.komga

**Description**

Self-hosted comic/manga/BD library server with OPDS support and a built-in web reader. The NixOS module provides `services.komga.enable`, `services.komga.port` (default 8080), `services.komga.dataDir`, and `services.komga.openFirewall`. Pair with Kavita if you want both a CBZ/CBR-focused reader (Komga) and an EPUB/manga-focused reader (Kavita).

**Tags**

`#media-server` `#nixos-module` `#comics` `#manga` `#opds`

---

#### Kavita (services.kavita)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.kavita

**Description**

Fast, self-hosted digital library for manga, comics, and books with a focus on EPUB/CBZ reading and a built-in metadata engine. The NixOS module (`services.kavita.enable`, `services.kavita.dataDir`, `services.kavita.tokenKeyFile`) ships in nixpkgs and creates the systemd service + `kavita` user. Reads from the same library path as Komga if you want to run both side-by-side for different client UXs.

**Tags**

`#media-server` `#nixos-module` `#comics` `#manga` `#epub`

---

#### calibre-web (services.calibre-web)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.calibre-web

**Description**

Web UI for a Calibre library, with OPDS, ebook conversion, and (with optional LDAP) user management. The NixOS module wraps the Python app and exposes `services.calibre-web.enable`, `services.calibre-web.calibreLibrary`, `services.calibre-web.listen.port`, and `services.calibre-web.options` for the full app config. Note: as of late 2025 there is an open build regression (nixpkgs #441911); pin to a working nixpkgs revision or run via the upstream calibre `--server` instead.

**Tags**

`#media-server` `#nixos-module` `#ebooks` `#calibre` `#opds`

---

#### calibre-server (services.calibre-server)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.calibre-server

**Description**

The built-in `calibre-server` subprocess that ships with Calibre itself — a simpler, lower-maintenance alternative to calibre-web if you only need OPDS+basic web UI and want to avoid the Flask dependency churn. Enabled with `services.calibre-server.enable` and `services.calibre-server.libraryDir`.

**Tags**

`#media-server` `#nixos-module` `#ebooks` `#calibre`

---

### 32. Servarr Stack on NixOS

The "Servarr" family — Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Whisparr, Kapowarr — plus Jackett, the torrent/usenet download clients, and the supporting glue (Tautulli, Recyclarr, Notifiarr, autobrr) all ship as NixOS modules. A homelab config is typically a single file: enable each `services.<name>` module, share a `media` group + UIDs across services so filesystem permissions "just work", and front the whole thing with Caddy/Traefik.

#### Sonarr (services.sonarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.sonarr

**Description**

TV series manager — monitors RSS/Torznab feeds, sends downloads to your torrent/usenet client, renames and moves files into your library. The NixOS module (`services.sonarr.enable`, `services.sonarr.dataDir`, `services.sonarr.openFirewall`) is a one-liner; bind it to a `media` group so it can write into the same path Sonarr hands off to Jellyfin.

**Tags**

`#servarr` `#nixos-module` `#sonarr` `#tv`

---

#### Radarr (services.radarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.radarr

**Description**

Movie manager — Sonarr's sibling for films. Same NixOS module shape (`services.radarr.enable`, `dataDir`, `openFirewall`, `user`). Often paired with Recyclarr to auto-sync TRaSH quality profiles.

**Tags**

`#servarr` `#nixos-module` `#radarr` `#movies`

---

#### Lidarr (services.lidarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.lidarr

**Description**

Music manager — Sonarr's sibling for albums, with metadata tagging via Beets integration. NixOS module: `services.lidarr.enable`. Output directory typically feeds into Navidrome's library path.

**Tags**

`#servarr` `#nixos-module` `#lidarr` `#music`

---

#### Readarr (services.readarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.readarr

**Description**

Ebook/audiobook manager — Sonarr's sibling for books. NixOS module: `services.readarr.enable`. Pairs naturally with calibre-web/Kavita as the consumption layer.

**Tags**

`#servarr` `#nixos-module` `#readarr` `#ebooks`

---

#### Prowlarr (services.prowlarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.prowlarr

**Description**

Indexer manager that syncs Torznab/Newznab indexers into Sonarr/Radarr/Lidarr/Readarr automatically, replacing the older Jackett-per-app pattern. NixOS module: `services.prowlarr.enable`. Single source of truth for indexers across the whole *arr stack.

**Tags**

`#servarr` `#nixos-module` `#prowlarr` `#indexers`

---

#### Bazarr (services.bazarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.bazarr

**Description**

Subtitle manager that watches Radarr/Sonarr libraries and downloads missing subtitles from OpenSubtitles/addic7ed/etc. NixOS module: `services.bazarr.enable`. Triggers on Radarr/Sonarr webhooks so new releases get subtitled automatically.

**Tags**

`#servarr` `#nixos-module` `#bazarr` `#subtitles`

---

#### Whisparr (services.whisparr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.whisparr

**Description**

Adult-content manager — a Sonarr fork for the adult video niche. NixOS module: `services.whisparr.enable`. Same workflow as Sonarr (indexer → download client → library move) but pointed at sites that specialize in that content.

**Tags**

`#servarr` `#nixos-module` `#whisparr`

---

#### Kapowarr (services.kapowarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.kapowarr

**Description**

Comic book manager — the *arr equivalent for CBZ/CBR collections, with metadata scraping from ComicVine and direct integration with Mylar3-style libraries. NixOS module: `services.kapowarr.enable`. Output typically feeds Komga/Kavita for the reading UX.

**Tags**

`#servarr` `#nixos-module` `#kapowarr` `#comics`

---

#### Jackett (services.jackett)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.jackett

**Description**

The pre-Prowlarr indexer translator — exposes private trackers as a Torznab API Sonarr/Radarr/etc. can consume. Still useful for niche trackers Prowlarr hasn't integrated yet. NixOS module: `services.jackett.enable`, `services.jackett.openFirewall`. For new stacks, prefer Prowlarr unless you need Jackett's broader tracker coverage.

**Tags**

`#servarr` `#nixos-module` `#jackett` `#indexers`

---

#### Servarr Wiki

**Website**

https://wiki.servarr.com

**Description**

The official documentation hub covering Sonarr, Radarr, Lidarr, Readarr, and Whisparr. Includes the canonical Docker→bare-metal migration notes and the TRaSH-Guides integration recipes. Cite this when validating that your NixOS module's defaults match upstream's recommended paths.

**Tags**

`#servarr` `#documentation` `#upstream`

---

#### awesome-arr

**Website**

https://github.com/Ravencentric/awesome-arr

**Description**

A community-curated list of every *arr-flavoured project — the *arr managers, the supporting tools (Bazarr, Prowlarr, Jackett, Recyclarr, Notifiarr, autobrr, Kapowarr, Tautulli, etc.), and quality/profile guides. Excellent map of the ecosystem when you're scoping a NixOS homelab config.

**Tags**

`#servarr` `#reference` `#awesome-list`

---

#### Transmission (services.transmission)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.transmission

**Description**

The most popular NixOS torrent client module — `services.transmission.enable` + `services.transmission.settings` (a Nix attrset mapping 1:1 to Transmission's settings.json). Supports the `media` group pattern, dedicated `transmission` user, and a `services.transmission.openPeerPorts`/`openRPCPort` shortcut for the firewall. The default choice for a NixOS homelab torrent client.

**Tags**

`#download-client` `#nixos-module` `#transmission` `#torrents`

---

#### qBittorrent (services.qbittorrent)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.qbittorrent

**Description**

The dominant alternative to Transmission — supports WebUI, built-in search, and per-tracker RSS rules that Transmission lacks. The NixOS module (`services.qbittorrent.enable`, `services.qbittorrent.openFirewall`, `services.qbittorrent.webuiPort`) was added to nixpkgs in late 2023 and now ships with sensible systemd defaults. Note: the module runs the daemon headless; you'll need to set the WebUI admin password on first login.

**Tags**

`#download-client` `#nixos-module` `#qbittorrent` `#torrents`

---

#### Deluge (services.deluge)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.deluge

**Description**

Lightweight Python+libtorrent client with a daemon/WebUI split that's convenient for headless servers. NixOS module: `services.deluge.enable`, `services.deluge.web.enable`, `services.deluge.dataDir`, declarative `services.deluge.config`. The daemon-mode lets *arr apps connect via the Deluge RPC port without exposing the full WebUI to the network.

**Tags**

`#download-client` `#nixos-module` `#deluge` `#torrents`

---

#### rtorrent (services.rtorrent)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.rtorrent

**Description**

The classic C++/libtorrent (rakshasa) client — preferred by seedbox operators for low resource overhead and high connection counts. NixOS module: `services.rtorrent.enable`, `services.rtorrent.dataDir`, `services.rtorrent.openFirewallPorts`, plus `services.rtorrent.rpcAddress` for the SCGI socket that ruTorrent/flood speak to. The right choice when you're moving from a seedbox and want the exact same daemon behaviour.

**Tags**

`#download-client` `#nixos-module` `#rtorrent` `#torrents`

---

#### ruTorrent (nixpkgs package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=rutorrent

**Description**

The classic PHP web UI for rtorrent. NixOS doesn't ship a dedicated `services.rutorrent` module — the canonical pattern is to enable `services.rtorrent` (with the SCGI socket bound to localhost), install `pkgs.rutorrent` into `services.phpfpm.pools`, and front it with nginx following the upstream ruTorrent docs. Heavier than flood but most familiar to ex-seedbox users.

**Tags**

`#download-client` `#package` `#rutorrent` `#torrents`

---

#### flood (services.flood)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.flood

**Description**

Modern Node.js web UI for rtorrent (and Transmission/Deluge/qBittorrent via the `--allowedpath` socket). NixOS module: `services.flood.enable`, `services.flood.host`, `services.flood.port`, `services.flood.extraArgs` for the `--rtsocket` flag. The cleanest way to give rtorrent a UI on NixOS without standing up PHP.

**Tags**

`#download-client` `#nixos-module` `#flood` `#torrents`

---

#### SABnzbd (services.sabnzbd)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.sabnzbd

**Description**

The most popular usenet binary downloader — pairs with Sonarr/Radarr's Newznab/Torznab support to fetch NZB files from indexers. NixOS module: `services.sabnzbd.enable`, `services.sabnzbd.user`, `services.sabnzbd.group`, `services.sabnzbd.configFile`. The right usenet client for a NixOS homelab; first-run setup happens in the WebUI on port 8080.

**Tags**

`#download-client` `#nixos-module` `#sabnzbd` `#usenet`

---

#### Nzbget (services.nzbget)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.nzbget

**Description**

The lighter-weight C++ alternative to SABnzbd — lower memory footprint, faster unpacking, and a script-extension system. NixOS module: `services.nzbget.enable`, `services.nzbget.openFirewall`, `services.nzbget.configFile`, declarative `services.nzbget.settings`. Note: nzbget upstream went into maintenance-only mode in 2023; new deployments should consider SABnzbd unless they specifically need the perf edge.

**Tags**

`#download-client` `#nixos-module` `#nzbget` `#usenet` `#maintenance-only`

---

#### Tautulli (services.tautulli)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.tautulli

**Description**

Statistics and monitoring companion for Plex (and historically Emby/Jellyfin via plugins) — tracks play sessions, sends notifications on play/start/stop, and provides a per-user watch history dashboard. NixOS module: `services.tautulli.enable`, `services.tautulli.dataDir`, `services.tautulli.openFirewall`. Indispensable for a Plex homelab; less critical for Jellyfin where the stats are first-party.

**Tags**

`#servarr` `#nixos-module` `#tautulli` `#monitoring` `#plex`

---

#### Recyclarr (services.recyclarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.recyclarr

**Description**

CLI tool that syncs TRaSH-Guides recommended quality profiles, custom formats, and release profiles into Sonarr/Radarr. The NixOS module (`services.recyclarr.enable`, `services.recyclarr.configuration` as a Nix attrset, `services.recyclarr.interval`) ships a systemd timer so your library always has the latest TRaSH recommendations without manual WebUI clicks. Replaces the legacy TRaSH-Guides wiki copy/paste workflow.

**Tags**

`#servarr` `#nixos-module` `#recyclarr` `#trash-guides`

---

#### Recyclarr Upstream

**Website**

https://github.com/recyclarr/recyclarr

**Description**

The .NET CLI upstream — useful for the canonical YAML schema reference and the latest release notes. The NixOS module wraps `pkgs.recyclarr` directly; bumping the package version typically requires no module-side changes.

**Tags**

`#servarr` `#upstream` `#recyclarr`

---

#### Notifiarr (services.notifiarr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.notifiarr

**Description**

Unified notification + monitoring agent for the *arr/Plex stack — pushes Discord alerts on grab/import/failure, syncs TRaSH guides (alternative to Recyclarr), and exposes a plex/tautulli dashboard. NixOS module: `services.notifiarr.enable`, `services.notifiarr.configFile`, `services.notifiarr.openFirewall`. Some features require a paid Notifiarr.com account; the self-hosted notification core is free.

**Tags**

`#servarr` `#nixos-module` `#notifiarr` `#notifications`

---

#### autobrr (services.autobrr)

**Website**

https://search.nixos.org/options?channel=unstable&query=services.autobrr

**Description**

Modern replacement for radarr/sonarr RSS feeds — IRC announce bot that grabs a release seconds after it's announced on a private tracker's announce channel, filters against your *arr-approved release profiles, and pushes straight to your torrent client. NixOS module: `services.autobrr.enable`, `services.autobrr.user`, `services.autobrr.openFirewall`. Indispensable for racing on private trackers; pairs with qBittorrent/Deluge/rtorrent/Transmission/SABnzbd.

**Tags**

`#servarr` `#nixos-module` `#autobrr` `#irc` `#private-trackers`

---

#### Radarr-Sync (nixpkgs package)

**Website**

https://search.nixos.org/packages?channel=unstable&query=radarr-sync

**Description**

A Python utility that syncs two Radarr instances (e.g., a 4K and a 1080p library) so a single add in one triggers a matching add in the other. NixOS ships it as a package (`pkgs.radarr-sync`) rather than a service module — wrap it in a systemd timer via `systemd.services.radarr-sync` and a `systemd.timers.radarr-sync`. Useful for the classic "4K + 1080p dual Radarr" homelab pattern.

**Tags**

`#servarr` `#package` `#radarr` `#multi-instance`

---

### 33. Nix-Specific Media Projects

Beyond the per-app modules in nixpkgs, a few community projects provide opinionated, end-to-end media-stack orchestration on NixOS. These are most valuable when you want the *arr stack, download clients, Jellyfin, and reverse proxy to be configured together from a single declarative entry-point — but they are also younger, more moving parts, and more likely to drift from upstream module defaults.

#### nixarr

**Website**

https://github.com/nix-media-server/nixarr

**Description**

The headline NixOS media-stack project — an opinionated module that wires Jellyfin, the full *arr family, transmission/qBittorrent, and (optionally)VPN glue into a single declarative config (`nixarr.<thing>.enable = true`). Originally authored by Rasmus Kirk (formerly `rasmus-kirk/nixarr`, now under the `nix-media-server` org). The closest thing to a "one-stop" NixOS media homelab flake; read the issue tracker before committing because the module API is still evolving.

**Tags**

`#nix-project` `#flake` `#media-stack` `#opinionated` `#jellyfin`

---

#### NixFlix

**Website**

https://github.com/kiriwalawren/nixflix

**Description**

A declarative NixOS configuration/flake that bundles Jellyfin + Sonarr + Radarr + Lidarr + Prowlarr + Seerr with all the inter-service wiring (API keys, base URLs, shared media paths) generated automatically. The stated aim is "automate all the connective tissue required to get Starr and Jellyfin services working together." Announced on r/NixOS in late 2025; newer and less battle-tested than nixarr but more focused on the "turn it on and it works" UX.

**Tags**

`#nix-project` `#flake` `#media-stack` `#jellyfin` `#seerr`

---

#### declarative-jellyfin

**Website**

https://github.com/Sveske-Juice/declarative-jellyfin

**Description**

A Nix flake that extends the upstream `services.jellyfin` module to make Jellyfin's library/users/permissions fully declarative — i.e., users, libraries, and API keys are Nix expressions rather than WebUI clicks. Designed as a drop-in replacement for the standard Jellyfin NixOS module. The right choice when you want Jellyfin itself (not just the systemd service) under version control.

**Tags**

`#nix-project` `#flake` `#jellyfin` `#declarative`

---

#### nixos-jellyfin (matt1432)

**Website**

https://github.com/matt1432/nixos-jellyfin

**Description**

A NixOS module/flake that bundles most packages released by the Jellyfin organisation (jellyfin-web, jellyfin-server, ffmpeg-jellyfin, plugin SDK) and adds declarative Jellyfin config on top of the upstream `services.jellyfin` module. Useful as a source of bleeding-edge Jellyfin builds and plugins that haven't yet landed in nixpkgs.

**Tags**

`#nix-project` `#flake` `#jellyfin` `#plugins`

---

#### servarr-nix (unverified)

**Website**

https://github.com/search?q=servarr-nix&type=repositories

**Description**

**Unverified.** A `servarr-nix` umbrella project was referenced in the task brief but no canonical public repository under that exact name could be confirmed via search at the time of writing. Treat any repo found under this name with caution and verify the maintainer, license, and last-commit date before importing it. The closest verified equivalents are `nix-media-server/nixarr` and `kiriwalawren/nixflix` (above).

**Tags**

`#nix-project` `#unverified` `#media-stack`

---


---

## Part X — Security & Development

### 34. Security on NixOS

NixOS ships first-class NixOS modules for nearly every hardening primitive you would want on a Linux server or workstation — LUKS, PAM U2F, ACME, nftables, fail2ban, USBGuard, AppArmor, and CrowdSec. The entries below cover both the NixOS option surface and the upstream tool it wraps, so you can decide when to lean on the module and when to drop down to the raw binary.

#### NixOS LUKS option (`boot.initrd.luks.devices`)

**Website**

https://search.nixos.org/options?query=boot.initrd.luks.devices

**Description**

The canonical NixOS module option for configuring LUKS-encrypted block devices at boot. Each device entry accepts `device`, `keyFile`, `luks` (LUKS2 metadata), `crypttabOptions`, `preLVM`, `allowDiscards` (for SSD TRIM on encrypted volumes), and `fallbackToPassword`. Pair with `boot.initrd.secrets` to ship keyfiles into the initrd without baking them into the world-readable system closure. For a homelab, this is what you set on every laptop and every bare-metal node that leaves the house.

**Tags**

`#nixos-module` `#luks` `#full-disk-encryption` `#boot`

---

#### systemd-cryptenroll

**Website**

https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html

**Description**

Upstream systemd tool for enrolling keys (TPM2 PCR-bound keys, FIDO2 tokens, PKCS#11 smartcards, recovery passphrases) into a LUKS2 volume. On NixOS it is available via the `systemd` package (or the standalone `cryptsetup`); under `boot.initrd.systemd.enable = true` the initrd will use `systemd-cryptenroll`-compatible enrollment at boot. Use it to add TPM2-bound slots to a LUKS2 volume that was created with `cryptsetup luksFormat --type luks2`, so the homelab node unlocks automatically when the firmware has not been tampered with.

**Tags**

`#luks2` `#tpm2` `#systemd` `#fido2`

---

#### Clevis & Tang (`boot.initrd.clevis`)

**Website**

https://search.nixos.org/options?query=boot.initrd.clevis

**Description**

NixOS module that wraps [Clevis](https://github.com/latchset/clevis) — a pluggable framework for automated decryption of LUKS volumes — and the Tang network binding server. Clevis pins can bind decryption to a TPM2, a Tang server on your LAN, or both (the recommended `sss` shamir-secret-sharing policy). In a homelab, run Tang on your router/NAS and let every Clevis-bound laptop decrypt itself automatically when it is on the home network, while still requiring a passphrase elsewhere.

**Tags**

`#nixos-module` `#clevis` `#tang` `#nbde` `#luks`

---

#### TPM2-bound LUKS (Clevis / systemd-cryptenroll)

**Website**

https://wiki.nixos.org/wiki/TPM

**Description**

Pattern, not a single package: bind a LUKS2 volume to a TPM2 PCR policy so the disk unlocks only when the firmware-measured boot chain is intact. Two supported paths on NixOS: (1) `boot.initrd.clevis.devices.<name>.useTpm = true`, or (2) `systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7` against a LUKS2 volume when `boot.initrd.systemd.enable = true`. Pair with Secure Boot (Lanzaboote) so the measured chain actually means something. Without measured boot, TPM2-bound LUKS only protects against casual offline access, not evil-maid attacks.

**Tags**

`#tpm2` `#luks` `#measured-boot` `#clevis`

---

#### `services.udev.yubikey`

**Website**

https://search.nixos.org/options?query=services.udev.yubikey

**Description**

NixOS module that installs the upstream Yubico udev rules so YubiKey devices get stable names, correct permissions, and the `consolekit`/`plugdev` group tagging that user-space tools (ykman, pam_u2f, scdaemon) depend on. Enable it on every workstation that will touch a YubiKey; without it you will get `permission denied` errors when running `ykman` as a non-root user, and pcscd will not see the token.

**Tags**

`#nixos-module` `#yubikey` `#udev` `#hardware-token`

---

#### PAM U2F (`security.pam.u2fAuth`)

**Website**

https://search.nixos.org/options?query=security.pam.u2fAuth

**Description**

NixOS option, exposed under each PAM service, that adds the `pam_u2f` module to the auth stack so a YubiKey (or any FIDO U2F token) can be used as a second factor for `login`, `sudo`, `su`, `polkit`, `sddm`, etc. The per-user mapping file is configured via `security.pam.u2f.authFile` (or, with `security.pam.u2f.appId` / `origin`, the user's own `~/.config/Yubico/u2f_keys`). For a homelab, set `security.pam.services.<svc>.u2fAuth = true` selectively — typically `sudo` and `login` — so a stolen password alone cannot escalate.

**Tags**

`#nixos-module` `#pam` `#u2f` `#2fa` `#yubikey`

---

#### age-plugin-yubikey

**Website**

https://github.com/str4d/age-plugin-yubikey

**Description**

Plugin for the `age` encryption tool that uses a YubiKey's OpenPGP smartcard slot as the identity, so secrets encrypted with `age` can be decrypted only by someone physically holding the YubiKey and tapping its button. Packaged in nixpkgs as `age-plugin-yubikey`. In a NixOS homelab this pairs beautifully with `sops-nix` or `agenix` to encrypt host secrets in a git repo and decrypt them at boot only when the correct YubiKey is plugged into the server.

**Tags**

`#age` `#yubikey` `#secrets-management` `#encryption`

---

#### yubikey-manager (`ykman`)

**Website**

https://github.com/Yubico/yubikey-manager

**Description**

Yubico's official CLI for configuring a YubiKey: enable/disable OTP/U2F/FIDO2/CCID interfaces, manage OpenPGP slots, set PINs, generate attestation certificates, switch OTP slots. Packaged in nixpkgs as `yubikey-manager`. On NixOS you typically install it as a user package and pair it with `services.udev.yubikey` and `services.pcscd.enable = true`. Essential for initial provisioning of any YubiKey before it can be used as a PAM factor or `age` identity.

**Tags**

`#yubikey` `#cli` `#hardware-token` `#provisioning`

---

#### piv-agent

**Website**

https://github.com/smlx/piv-agent

**Description**

A standalone SSH and GnuPG agent that uses PIV-enabled smartcards (YubiKey 4/5, Nitrokey, etc.) for authentication and signing — a drop-in replacement for the leaky `gpg-agent` and the OpenSSH builtin `sk-ssh` keys. Packaged in nixpkgs. Useful on NixOS workstations where you want one YubiKey to serve both `ssh` and `git commit -S` without juggling two agent processes; configure with `programs.ssh.startAgent = false` and a per-user systemd user unit for `piv-agent`.

**Tags**

`#ssh-agent` `#yubikey` `#piv` `#smartcard`

---

#### `security.acme` (Let's Encrypt module)

**Website**

https://search.nixos.org/options?query=security.acme

**Description**

The NixOS ACME module — one of the most polished in nixpkgs. Declares a `security.acme.certs.<name>` attribute set where each entry requests a Let's Encrypt (or any other ACME RFC 8555) certificate, renews it 30 days before expiry, installs the chain to `/var/lib/acme/<name>/`, and reloads a configured list of services (`reloadServices`) after renewal. Defaults to HTTP-01 on port 80; switch to DNS-01 with `dnsProvider` for wildcard certs and homelab setups behind a firewall. The default ACME client is `lego`.

**Tags**

`#nixos-module` `#acme` `#lets-encrypt` `#tls` `#lego`

---

#### ACME DNS-01 challenge

**Website**

https://search.nixos.org/options?query=security.acme.certs

**Description**

Configuration pattern on top of the `security.acme` module: set `security.acme.certs.<name>.dnsProvider = "route53"` (or `"cloudflare"`, `"porkbun"`, `"hetzner"`, …), provide credentials via `environmentFile`, and you can issue wildcard certificates (`*.homelab.example.com`) and certificates for hosts that are not reachable from the public internet. This is the recommended path for a homelab where HTTP-01 cannot reach the host. Lego ships ~80 DNS provider plugins; the NixOS module wires them up transparently.

**Tags**

`#acme` `#dns-01` `#wildcard-cert` `#homelab`

---

#### tpm2-tss

**Website**

https://github.com/tpm2-software/tpm2-tss

**Description**

Upstream TPM2 Software Stack — the user-space library that talks to the kernel `tpm_crb`/`tpm_tis` driver. Packaged in nixpkgs as `tpm2-tss`, with the accompanying CLI tools `tpm2-tools` and the abstracted resource manager `tpm2-abrmd`. On NixOS enable `security.tpm2.enable = true` to pull in `tpm2-tss`, set up `/dev/tpmrm0` permissions, and install the PKCS#11 provider. Required base layer for anything else on this page that mentions "TPM2".

**Tags**

`#tpm2` `#tss` `#library` `#hardware-security`

---

#### tpm-luks

**Website**

https://github.com/fox-it/tpm-luks

**Description**

Older, simpler alternative to Clevis+Tang for binding a LUKS volume to a local TPM2: a small shell+Python wrapper around `tpm2_createpolicy` and `cryptsetup luksAddKey` that enrols a TPM2-PCR-bound keyfile into an existing LUKS1/LUKS2 volume. Packaged in nixpkgs as `tpm-luks`. Predates `systemd-cryptenroll`; for new deployments prefer Clevis or `systemd-cryptenroll --tpm2`. Listed here because it is the only packaged tool whose single purpose is TPM-bound LUKS without a Tang dependency.

**Tags**

`#tpm2` `#luks` `#legacy` `#prefer-systemd-cryptenroll`

---

#### Lanzaboote (Secure Boot for NixOS)

**Website**

https://github.com/nix-community/lanzaboote

**Description**

nix-community project that brings UEFI Secure Boot to NixOS without giving up reproducibility. Lanzaboote generates a per-system UEFI keypair, enrols the public half into the firmware, signs every `systemd-boot` loader and unified kernel image (UKI), and rewires the NixOS boot path so the bootloader itself is signed. Without Lanzaboote, NixOS Secure Boot is a forest of manual `sbsign` invocations that the next `nixos-rebuild` will silently blow away. Pairs with TPM2-bound LUKS for a full measured-boot story.

**Tags**

`#secure-boot` `#uefi` `#nix-community` `#lanzaboote` `#measured-boot`

---

#### systemd-boot

**Website**

https://search.nixos.org/options?query=boot.loader.systemd-boot

**Description**

NixOS module for the upstream systemd-boot UEFI boot manager (formerly gummiboot). Configure via `boot.loader.systemd-boot.enable = true`, with `boot.loader.systemd-boot.configurationLimit` controlling how many generations are kept on the EFI System Partition, `editor = false` to harden the boot menu, and `consoleMode` for HiDPI displays. The default NixOS boot manager; required (or at least strongly recommended) when you also enable Lanzaboote for Secure Boot.

**Tags**

`#nixos-module` `#bootloader` `#uefi` `#systemd-boot`

---

#### sbctl

**Website**

https://github.com/Foxboron/sbctl

**Description**

Upstream Secure Boot key manager by Morten Linderud (also a NixOS contributor). Generates, enrols, and manages UEFI Secure Boot keys, signs binaries, and verifies the boot chain. Packaged in nixpkgs as `sbctl`. On NixOS it is mostly useful for one-off manual Secure Boot setups (e.g. dual-booting with Windows while trusting your own keys) — for a pure-NixOS host, prefer Lanzaboote which automates the same workflow declaratively.

**Tags**

`#secure-boot` `#uefi` `#key-management` `#sbctl`

---

#### fail2ban (`services.fail2ban`)

**Website**

https://search.nixos.org/options?query=services.fail2ban

**Description**

NixOS module wrapping the upstream fail2ban daemon — watches log files for repeated authentication failures and temporarily bans the offending source IP via the firewall. Configure with `services.fail2ban.enable = true`, then enable jails (`services.fail2ban.jails.sshd = ''enabled = true''` or via the structured `services.fail2ban.jails.<name>.settings` attrset introduced in NixOS 23.11). The first line of defence for any exposed SSH/HTTP service; for a homelab behind Cloudflare/Tailscale it is mostly belt-and-braces, but cheap to enable.

**Tags**

`#nixos-module` `#fail2ban` `#intrusion-prevention` `#ssh` `#log-monitoring`

---

#### AppArmor (`security.apparmor`)

**Website**

https://search.nixos.org/options?query=security.apparmor

**Description**

NixOS module for the upstream AppArmor mandatory access control system. Set `security.apparmor.enable = true` to mount the AppArmor filesystem and load policy; `security.apparmor.policies.<name>.profile` lets you ship profiles declaratively inside your NixOS config. Useful for locking down a specific binary on a multi-tenant homelab host (e.g. a torrent client, a browser, an experimental daemon) without depending on containers. NixOS does not ship profiles for arbitrary packages by default — you write or upstream them yourself.

**Tags**

`#nixos-module` `#apparmor` `#mac` `#mandatory-access-control`

---

#### USBGuard (`services.usbguard`)

**Website**

https://search.nixos.org/options?query=services.usbguard

**Description**

NixOS module for USBGuard — a policy daemon that whitelists USB devices by their ID/product/serial and rejects everything else. Configure via `services.usbguard.enable = true`, `services.usbguard.rules` (the declarative allowlist), `services.usbguard.IPCPolicy` (which users may talk to the daemon), and `services.usbguard.presentControllerPolicy`. On a homelab, deploy on any laptop or kiosk-style machine that someone could plug a malicious rubber-ducky into; on a headless server you usually leave it disabled because physical USB access is already controlled.

**Tags**

`#nixos-module` `#usbguard` `#usb-security` `#device-whitelist`

---

#### CrowdSec (`services.crowdsec`)

**Website**

https://search.nixos.org/options?query=services.crowdsec

**Description**

NixOS module for CrowdSec — the modern, collaborative replacement for fail2ban. The local agent parses logs (nginx, sshd, caddy, etc.), the local API stores decisions, and the central API pushes blocklists gathered from the global CrowdSec network. Configure with `services.crowdsec.enable = true`, `services.crowdsec.settings`, `services.crowdsec.hub` (collections, parsers, appsec rules), and `services.crowdsec.decisions`. The module landed in nixpkgs in 2024; the nixpkgs #445342 issue tracks ongoing default-config improvements so be prepared to set a few knobs before it Just Works.

**Tags**

`#nixos-module` `#crowdsec` `#intrusion-prevention` `#threat-intelligence` `#fail2ban-successor`

---

### 35. Development Environments (Nix Dev Tooling)

Nix gives you reproducible, per-project dev shells without Docker. The tools below fall into four rough buckets: shell runners (devenv, devshell, nix-shell), automatic activation (direnv + nix-direnv), flake helpers (flake-utils, nix-systems, dream2nix), pinning (niv, npins), running prebuilt binaries (nix-ld, nix-alien), linting/formatting (nixfmt, alejandra, deadnix, statix), and the LSP / quality-of-life tooling (nil, nixd, treefmt-nix, pre-commit-hooks.nix, comma).

#### devenv

**Website**

https://devenv.sh/

**Description**

High-level dev-shell framework from Cachix, built on top of Nix flakes and process-compose. A `devenv.nix` file declaratively describes languages, packages, services (Postgres, Redis, etc.), processes, and hooks; `devenv up` boots the whole stack in one tmux-like terminal. Integrates with direnv, supports `.envrc`, and can export a `devShell` flake output for non-devenv users. The most ergonomic "I just want a working dev environment" choice in the Nix ecosystem in 2024-2025; free for individuals, paid for teams via Cachix.

**Tags**

`#devshell` `#cachix` `#flakes` `#process-compose` `#devenv`

---

#### direnv

**Website**

https://direnv.net/

**Description**

Upstream shell extension that loads and unloads environment variables based on the current directory. On NixOS you install the `direnv` package, hook it into `eval "$(direnv hook bash)"` (or zsh/fish) in your shell rc, then drop a `.envrc` in each project. The de facto interface that devenv, nix-direnv, and most flake-based repos target; without direnv you would have to remember to `nix develop` after every `cd`.

**Tags**

`#direnv` `#shell-hook` `#env-management` `#workflow`

---

#### nix-direnv

**Website**

https://github.com/nix-community/nix-direnv

**Description**

nix-community plugin for direnv that replaces the slow `use_nix` and `use_flake` helpers with a much faster implementation that caches the built shell derivation. Without nix-direnv, every `cd` into a flake project blocks on a `nix develop --command bash` invocation; with it, the first `cd` builds the shell once and subsequent `cd`s are instant. The single most-recommended quality-of-life install for any Nix user; wire it up with `programs.direnv.enableNixDirenvIntegration = true` under home-manager.

**Tags**

`#nix-community` `#direnv` `#caching` `#flakes` `#performance`

---

#### numtide/devshell

**Website**

https://github.com/numtide/devshell

**Description**

numtide's framework for declarative interactive dev shells — a `devshell.nix` file (or a `devshell.toml` exported from it) lists packages, env vars, and alias-style commands that show up in `devshell menu`. Predates devenv; simpler and lower-magic, with no built-in process-compose or services layer. Still the right choice if you want a `nix develop` shell with a discoverable help menu and you do not need devenv's services; many numtide repositories use it.

**Tags**

`#numtide` `#devshell` `#flakes` `#declarative`

---

#### nix-shell (classic)

**Website**

https://nixos.org/manual/nix/unstable/command-ref/nix-shell.html

**Description**

The original, channel-based Nix dev shell command (`nix-shell -p pkgA pkgB`). Predates flakes; still works with channels and `shell.nix` files. Largely superseded for new projects by `nix develop` (the flake-based equivalent) and by devenv/devshell, but every Nix user should still know the syntax because the `nix-shell -p <pkg>` invocation is the canonical way to drop into a one-off shell with an extra package, e.g. `nix-shell -p git` to get git on a system that doesn't have it installed.

**Tags**

`#nix` `#classic` `#channels` `#legacy` `#shell`

---

#### nix-systems

**Website**

https://github.com/nix-systems/nix-systems

**Description**

Tiny set of flake outputs that just enumerate systems (`github:nix-systems/x86_64-linux`, `github:nix-systems/aarch64-darwin`, …) so you can pass them as a flake input and override them in a downstream consumer. Lets a project hardcode `systems = nixpkgs.lib.systems.flakeExposed;` while still allowing an overlay consumer to extend the system list by overriding the `systems` input. The recommended modern replacement for the hardcoded `[ "x86_64-linux" "aarch64-linux" ]` lists you see in flake-utils examples.

**Tags**

`#flakes` `#systems` `#overridable` `#modern`

---

#### dream2nix

**Website**

https://github.com/nix-community/dream2nix

**Description**

nix-community framework for auto-translating non-Nix dependency manifests (package.json, pyproject.toml, Cargo.toml, Gemfile.lock, Go modules, maven, etc.) into Nix derivations. Produces modular, hackable output (unlike `pkgs.buildNpmPackage`-style monolithic builders). Aimed at people who package many third-party projects and want a consistent translation layer; overkill for a homelab that just consumes packages, but invaluable if you contribute to nixpkgs or maintain an overlay of upstream JS/Python apps.

**Tags**

`#nix-community` `#packaging` `#dream2nix` `#auto-translation`

---

#### niv (SUPERSEDED — use flakes)

**Website**

https://github.com/nmattia/niv

**Description**

Lightweight dependency pinning tool for non-flake Nix projects: `niv init`, `niv add nixos/nixpkgs -b nixos-24.11`, and `niv update` to bump a single source. Stores sources in `nix/sources.json` and generates `nix/sources.nix` for import. **Marked superseded**: for any new project, use Nix flakes instead — they cover the same use case natively (`inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";`) and are accepted by the wider Nix ecosystem. niv is still maintained but new projects should not pick it.

**Tags**

`#niv` `#pinning` `#legacy` `#superseded-by-flakes` `#channels`

---

#### npins

**Website**

https://github.com/andir/npins

**Description**

Modern dependency pinning tool by Andreas Rammhold, explicitly positioned as the spiritual successor to niv. Same workflow (`npins init`, `npins add github:nixos/nixpkgs`, `npins update`) but tracks Git releases and tags by default, stores sources in `npins/sources.json`, and generates a `default.nix` for `import ./npins`. Works equally well for non-flake NixOS configurations (the famous "kill channels forever" pattern) and as a flake-input alternative. Recommended for anyone who wants pinning without committing to flakes, or who wants to pin non-flake sources alongside a flake.

**Tags**

`#npins` `#pinning` `#niv-successor` `#flakes-alternative`

---

#### nix-ld (`programs.nix-ld`)

**Website**

https://github.com/nix-community/nix-ld

**Description**

nix-community tool that solves the "I downloaded a prebuilt ELF binary and it can't find its dynamic linker" problem on NixOS. Setting `programs.nix-ld.enable = true` installs a special `nix-ld` interpreter into a well-known path and sets `NIX_LD`/`NIX_LD_LIBRARY_PATH` in the shell so unpatched binaries (VS Code extensions, FPGA tools, game downloads, proprietary vendor tools) just run. The single most important NixOS quality-of-life setting for desktop users; pair with `programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc libz ]` to choose which libraries are visible.

**Tags**

`#nix-community` `#nix-ld` `#unpatched-binaries` `#nixos-desktop`

---

#### nix-alien

**Website**

https://github.com/thiagokokada/nix-alien

**Description**

A higher-level alternative to nix-ld for running unpatched binaries: a small flake that wraps `nix-index`-style library discovery and `nix-ld`-style interpreter shimming so that `nix-alien-ld ./some-binary` produces a working wrapper script with the right libraries auto-resolved. Useful when nix-ld's blanket library list is not enough (e.g. a binary that needs an exact glibc version or an obscure shared object). Mostly superseded for everyday use by `programs.nix-ld` plus `nix-index`, but still the easiest one-shot fix for stubborn proprietary binaries.

**Tags**

`#nix-alien` `#unpatched-binaries` `#auto-patch` `#flakes`

---

#### nixpkgs-fmt (SUPERSEDED — use nixfmt)

**Website**

https://github.com/nix-community/nixpkgs-fmt

**Description**

Former nix-community Nix formatter; archived/superseded in favour of `nixfmt` (RFC 166). Was the dominant formatter from ~2019 to ~2023, but development stopped once the RFC 166 effort to pick a single official formatter landed on `nixfmt`. Existing configs that reference `nixpkgs-fmt` in pre-commit or editor integrations should migrate to `nixfmt` (or, if they want non-RFC formatting, to alejandra — though alejandra is itself effectively unmaintained, see below).

**Tags**

`#nix-community` `#formatter` `#deprecated` `#superseded-by-nixfmt`

---

#### nixfmt (RFC 166 — the official formatter)

**Website**

https://github.com/serokell/nixfmt

**Description**

The Nix formatter selected by [RFC 166](https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md) as the official, eventually-default formatter for Nix code. Written in Haskell by Serokell; adoption across nixpkgs is being rolled out incrementally. Set `formatter = pkgs.nixfmt-rfc-style` in your flake outputs (the `nixfmt-rfc-style` package enforces the RFC variant, not the original `nixfmt` classic style) and wire `nix fmt` into pre-commit / CI. The target destination for every other formatter listed here.

**Tags**

`#nixfmt` `#formatter` `#rfc-166` `#official` `#serokell`

---

#### alejandra

**Website**

https://github.com/kamadorueda/alejandra

**Description**

"The Uncompromising Nix Code Formatter" by Kamadorueda — a Rust formatter that rewrites Nix code into a single canonical layout with no configuration knobs. Fast and reliable, and for ~2 years was the most popular non-RFC formatter. **Status note**: development has effectively stalled (last release June 2023, no recent commits) and the project is widely regarded as maintenance-mode/archived; new projects should default to `nixfmt-rfc-style` and only use alejandra if they specifically want its 2-space, no-leading-trivia style.

**Tags**

`#alejandra` `#formatter` `#uncompromising` `#stalled` `#rust`

---

#### deadnix

**Website**

https://github.com/astro/deadnix

**Description**

Linter/rewriter by Astro that finds and removes dead (unused) `let`-bindings in Nix code. Run `deadnix -e` to edit files in place, or `deadnix --no-underscore` to leave `_`-prefixed bindings alone (useful when they encode intent). Pairs cleanly with `statix` (which catches a broader set of anti-patterns) and `nixfmt`/`alejandra` in a `treefmt` config. Cheap to run, no false positives in practice, and a must-have in any non-trivial flake.

**Tags**

`#deadnix` `#linter` `#dead-code` `#astro`

---

#### statix

**Website**

https://github.com/nerdypepper/statix

**Description**

Nix linter by NerdyPepper that flags a broader catalogue of anti-patterns — deprecated `builtins.fetchTarball`, manual `system` checks instead of `flake-utils`-style helpers, redundant `with`, `import <nixpkgs>` in flakes, etc. Ships a `statix fix` sub-command that rewrites many issues automatically. The complement to `deadnix`: deadnix finds unused bindings, statix finds wrong-shaped bindings. Run both in pre-commit and CI on any flake you intend to publish.

**Tags**

`#statix` `#linter` `#anti-patterns` `#rewrites`

---

#### nil (Nix Language Server)

**Website**

https://github.com/oxalica/nil

**Description**

A modern Nix language server written in Rust by oxalica. Provides completion, go-to-definition, hover, diagnostics (with `nix flake check` integration), formatting, and rename support, all driven by incremental parsing. The most actively-developed Nix LSP in 2024-2025; the recommended default for Neovim, VS Code, and Helix. Configure via your editor's LSP client pointing at the `nil` binary from nixpkgs.

**Tags**

`#nil` `#lsp` `#rust` `#editor` `#language-server`

---

#### nixd (Nix Language Server)

**Website**

https://github.com/nix-community/nixd

**Description**

nix-community Nix language server, also written in C++. Stronger on option completion and type inference for NixOS module option sets than nil — `nixd` can autocomplete `services.foo.<tab>` against the actual option set in your flake input. The choice between nil and nixd often comes down to taste: nil has wider editor integration and is faster on large files; nixd has better module-option awareness. Try both; wire one into your editor.

**Tags**

`#nixd` `#nix-community` `#lsp` `#cpp` `#option-completion`

---

#### rnix-lsp (DEPRECATED — use nil or nixd)

**Website**

https://github.com/nix-community/rnix-lsp

**Description**

The original nix-community Nix language server, written in Rust using the `rnix` parser. **Deprecated**: superseded by `nil` (also Rust, same parser lineage) and `nixd` (C++, richer module option support). The `rnix-lsp` repository is effectively unmaintained; new users should install `nil` or `nixd` instead. Listed here so you do not copy-paste an outdated Neovim config from a 2021 blog post.

**Tags**

`#rnix-lsp` `#lsp` `#deprecated` `#superseded-by-nil`

---

#### treefmt-nix

**Website**

https://github.com/numtide/treefmt-nix

**Description**

numtide Nix wrapper around [treefmt](https://github.com/numtide/treefmt), the polyglot formatter runner. A `treefmt.nix` module declares which formatter runs on which file glob (`nixfmt` on `*.nix`, `rustfmt` on `*.rs`, `shfmt` on `*.sh`, `prettier` on `*.{json,yaml,md}`, etc.) and treefmt runs them all in parallel, memoising unchanged files. Exposes `treefmt.build.checkFiles` for CI and integrates with `pre-commit-hooks.nix`. The recommended way to enforce formatting across a polyglot flake.

**Tags**

`#numtide` `#treefmt` `#formatter` `#polyglot` `#ci`

---

#### pre-commit-hooks.nix

**Website**

https://github.com/cachix/pre-commit-hooks.nix

**Description**

Cachix Nix port of `pre-commit/pre-commit-hooks`: declarative `.pre-commit-config.yaml`-equivalent that installs and runs hooks (`nixfmt`, `statix`, `deadnix`, `shellcheck`, `nixpkgs-fmt`, `typos`, etc.) via `git`'s native hooks. Set `pre-commit.settings.hooks.statix.enable = true;` in your flake, run `nix develop` to install the hooks into `.git/hooks/`, and from then on every commit is auto-checked. De facto standard for any community Nix flake; integrates natively with flake-utils and treefmt-nix.

**Tags**

`#cachix` `#pre-commit` `#git-hooks` `#developer-experience`

---

#### nix-output-monitor

**Website**

https://github.com/maralorn/nix-output-monitor

**Description**

Drop-in replacement for `nix build`/`nixos-rebuild` output by Maralorn that shows a progress bar, per-derivation download/build times, and a clean summary — wraps `nix build` so you invoke `nom build .#foo` instead. Also runs as a post-build hook via `nix-build`'s `--builders` output. The single biggest UX upgrade for anyone watching long NixOS builds; install `nix-output-monitor` and alias `nix build = nom build` in your shell.

**Tags**

`#nom` `#maralorn` `#ux` `#build-output`

---

#### comma

**Website**

https://github.com/nix-community/comma

**Description**

nix-community tool that wraps `nix run`/`nix-shell -p` into a `,` command: `, <binary>` looks up the package providing that binary via `nix-index`, drops you into a temporary shell with it on PATH, and runs it. `, cowsay 'hi'` works on a fresh NixOS install with no other setup. Pairs with `nix-index` (which generates the lookup database via `nix-index -f nixpkgs`). The fastest "I need this one CLI tool for ten seconds" UX in the Nix world.

**Tags**

`#nix-community` `#comma` `#ad-hoc-packages` `#ux`

---

#### nix-index

**Website**

https://github.com/nix-community/nix-index

**Description**

nix-community tool that builds a local SQLite index of which files each Nix package installs, exposing `nix-locate <pattern>` to find which package ships a given binary or library. Required database for `comma` and for any "I have a missing shared library" debugging. Run `nix-index` (or, on NixOS, the `programs.nix-index.enable = true` module plus the `nix-index --update` systemd timer) to keep the index fresh. Complementary to `manix` for option searching.

**Tags**

`#nix-community` `#nix-index` `#package-search` `#nix-locate`

---


---

## Part XI — CI/CD & Cloud Providers

### 36. CI/CD for Nix

Nix is uniquely well-suited to CI/CD because builds are deterministic, hermetic, and cacheable. The ecosystem spans GitHub Actions installers/cache helpers, self-hosted build farms (Hydra), SaaS CI (Hercules CI, garnix.io, nixbuild.net), and a constellation of binary-cache daemons. Together these let a homelab build once, cache everywhere, and ship reproducible systems.

#### DeterminateSystems/nix-installer-action

**Website**

https://github.com/DeterminateSystems/nix-installer-action

**Description**

GitHub Action wrapping the Determinate Nix Installer, the de-facto modern way to install Nix in CI. It is fast, supports multi-user installations on Linux/macOS/WSL, supports flakes out of the box, and integrates cleanly with DeterminateSystems' other actions. Use it as the first step of any Nix-based CI workflow to get a reliable, sandboxed Nix daemon in seconds.

**Tags**

`#github-actions` `#nix-installer` `#ci`

---

#### DeterminateSystems/determinate-nix-action

**Website**

https://github.com/DeterminateSystems/determinate-nix-action

**Description**

The newer one-stop GitHub Action from Determinate Systems that installs Determinate Nix (a hardened Nix distribution) and wires up FlakeHub Cache automatically. It supersedes the standalone installer/magic-cache combo for users in the Determinate ecosystem and supports pinning to a specific Nix version or Git hash for security-hardened supply chains.

**Tags**

`#github-actions` `#determinate-nix` `#ci`

---

#### DeterminateSystems/magic-nix-cache-action

**Website**

https://github.com/DeterminateSystems/magic-nix-cache-action

**Description**

GitHub Action that spins up a local Nix binary cache backed by the GitHub Actions cache API, transparently sharing built store paths between workflow runs at no cost. Originally deprecated in early 2025 due to GitHub API changes, it has since been brought back; for new setups the Determinate team now points users toward `cache-nix-action` or FlakeHub Cache.

**Tags**

`#github-actions` `#binary-cache` `#ci`

---

#### DeterminateSystems/flake-checker-action

**Website**

https://github.com/DeterminateSystems/flake-checker-action

**Description**

Action that wraps the Nix Flake Checker CLI to perform health checks on a repository's `flake.lock`. It verifies that Nixpkgs inputs are recent (≤30 days old), owned by the `NixOS` org, and on a supported branch — emitting a Markdown summary in the workflow run. Drop it into PR checks to catch stale or supply-chain-risky inputs.

**Tags**

`#github-actions` `#flakes` `#supply-chain`

---

#### DeterminateSystems/update-flake-lock-action

**Website**

https://github.com/DeterminateSystems/update-flake-lock-action

**Description**

Action that runs `nix flake update` and opens/updates a pull request with the resulting `flake.lock` changes. Supports scheduled runs (e.g. weekly dependency bumps), nested flake updates, and signed commits. Ideal for keeping a homelab flake's inputs fresh without manual `nix flake update && git push` cycles.

**Tags**

`#github-actions` `#flakes` `#dependency-updates`

---

#### DeterminateSystems/ci

**Website**

https://github.com/DeterminateSystems/ci

**Description**

A "one-stop shop" GitHub Action from Determinate Systems that auto-discovers flake outputs, builds them across all architectures your flake declares, and caches them via FlakeHub Cache. Recommended only for users already on FlakeHub, but it removes the boilerplate of writing per-output build matrices by hand.

**Tags**

`#github-actions` `#ci` `#flakehub`

---

#### cachix/install-nix-action

**Website**

https://github.com/cachix/install-nix-action

**Description**

Long-standing community GitHub Action that installs Nix in multi-user mode with sandboxing enabled by default. Installs in ~4 s on Linux / ~20 s on macOS, supports self-hosted runners, and exposes configuration knobs for extra Nix config, extra substituters, and trusted keys. The most popular installer action before the Determinate installer arrived and still widely used.

**Tags**

`#github-actions` `#nix-installer` `#ci`

---

#### cachix/cachix-action

**Website**

https://github.com/cachix/cachix-action

**Description**

Companion Action to `install-nix-action` that configures Nix to push to and pull from a Cachix binary cache during the workflow. After the job, store paths built during the run are pushed to your Cachix cache, making them available to developers and subsequent CI runs. Free for public/open-source caches.

**Tags**

`#github-actions` `#cachix` `#binary-cache`

---

#### nix-community/cache-nix-action

**Website**

https://github.com/nix-community/cache-nix-action

**Description**

Community-maintained GitHub Action that caches Nix store paths in the GitHub Actions cache (similar to `magic-nix-cache-action` but actively maintained). Supports purging old caches, layered save/restore, and works without any external SaaS dependency. A good drop-in after the original Magic Nix Cache deprecation.

**Tags**

`#github-actions` `#binary-cache` `#ci`

---

#### nixbuild/nix-quick-install-action

**Website**

https://github.com/nixbuild/nix-quick-install-action

**Description**

GitHub Action that installs Nix in single-user mode with near-zero overhead — the installation is fully cached and deterministic for a given action release. Supports all GitHub-hosted Linux and macOS runners. A good choice when you want the fastest possible Nix boot and don't need the multi-user daemon.

**Tags**

`#github-actions` `#nix-installer` `#ci`

---

#### NixOS/hydra

**Website**

https://github.com/NixOS/hydra

**Description**

Hydra is the Nix-based continuous build system that powers `hydra.nixos.org` itself. It evaluates Nix expressions on a schedule, builds jobs across remote build machines, exposes a web UI for jobsets/builds, and serves successful builds as a binary cache. Self-hostable via the `services.hydra` NixOS module for a private CI farm.

**Tags**

`#hydra` `#ci` `#self-hosted`

---

#### Hydra (NixOS Wiki)

**Website**

https://nixos.wiki/wiki/Hydra

**Description**

Community wiki page covering Hydra installation, jobset configuration (declarative and flake-based), remote builders, and the NixOS `services.hydra` module. The most practical starting point for setting up your own Hydra instance on a homelab NixOS box.

**Tags**

`#hydra` `#docs` `#self-hosted`

---

#### hercules-ci/hercules-ci-agent

**Website**

https://github.com/hercules-ci/hercules-ci-agent

**Description**

The agent component of Hercules CI, a CI/CD service designed around Nix flakes. The agent runs on your own machines (typically via the NixOS `services.hercules-ci-agent` module), receives build jobs from hercules-ci.com, and executes them with full local Nix store caching. Ideal for homelabs that want CI builds to happen on their own hardware.

**Tags**

`#hercules-ci` `#ci` `#agent`

---

#### Hercules CI

**Website**

https://hercules-ci.com/

**Description**

Hosted CI/CD service purpose-built for Nix flakes. It automatically discovers flake outputs, builds them across architectures, and supports `hercules-ci-effects` for downstream deploy/CI actions (e.g. push container images, run terraform). Free tier covers public repos and small private projects.

**Tags**

`#hercules-ci` `#ci-saas` `#flakes`

---

#### hercules-ci-effects

**Website**

https://github.com/hercules-ci/hercules-ci-effects

**Description**

Library that adds "effects" — side-effecting actions executed after a successful build — to Hercules CI pipelines. Examples include deploying a NixOS machine, pushing Docker images, or running a Terraform apply. Lets you treat deploys as a typed, declarative extension of your flake rather than shell scripts.

**Tags**

`#hercules-ci` `#effects` `#deploy`

---

#### cachix/cachix

**Website**

https://github.com/cachix/cachix

**Description**

The Cachix CLI client. Pushes store paths to a Cachix binary cache (`cachix push <name>`) and configures a machine to pull from one (`cachix use <name>`). Used both interactively by developers and inside CI to share built derivations. Free for public/open-source caches; paid tiers for private caches with retention controls.

**Tags**

`#cachix` `#binary-cache` `#cli`

---

#### Cachix (hosted service)

**Website**

https://www.cachix.org/

**Description**

Hosted binary-cache service for Nix. Sign up, create a cache, push with `cachix push`, and let your team/CI pull with `cachix use`. Free for public caches and open-source projects, paid plans for private caches with larger storage and bandwidth. The lowest-effort way to share a Nix cache without running your own server.

**Tags**

`#cachix` `#binary-cache` `#saas`

---

#### cachix/cachix-watch-store

**Website**

https://github.com/cachix/cachix-watch-store

**Description**

Daemon that watches the local Nix store for newly-added paths and pushes them to a Cachix cache in real time. Run it as a `systemd` user service (the NixOS module is `services.cachix-watch-store`) so anything you build locally is automatically shared with your team/CI.

**Tags**

`#cachix` `#binary-cache` `#daemon`

---

#### nix-community/nix-serve (DEPRECATED)

**Website**

https://github.com/nix-community/nix-serve

**Description**

The original Perl-based `nix-serve` script that exposed a local Nix store over HTTP as a binary cache. Long unmaintained and effectively superseded by `nix-serve-ng` and `harmonia`. Listed here for historical context — do not start new deployments with it.

**Tags**

`#binary-cache` `#deprecated` `#self-hosted`

---

#### nix-community/nix-serve-ng

**Website**

https://github.com/nix-community/nix-serve-ng

**Description**

Maintained Rust rewrite of `nix-serve` that serves a local Nix store as a binary cache over HTTP. Drop-in replacement for the original (same NixOS module name `services.nix-serve`), with better performance and active development. The simplest way to host your own Nix binary cache on a homelab box.

**Tags**

`#binary-cache` `#self-hosted` `#http`

---

#### nix-community/harmonia

**Website**

https://github.com/nix-community/harmonia

**Description**

High-performance Nix binary cache server written in Rust by Jörg Thalheim (mic92). Supports streaming `narinfo`/`nar` responses, multiple signing keys, and is notably faster than `nix-serve-ng` for high-throughput setups. Configurable via the NixOS `services.harmonia` module.

**Tags**

`#binary-cache` `#self-hosted` `#rust`

---

#### zhaofengli/attic

**Website**

https://github.com/zhaofengli/attic

**Description**

Self-hosted Nix binary cache server with multi-cache, multi-tenant support, garbage collection, and a postgres-backed metadata store. Comes with an `atticd` daemon, an `attic` CLI for push/pull, and a NixOS module. A great choice for homelabs that want their own private "Cachix" without depending on external services.

**Tags**

`#binary-cache` `#self-hosted` `#attic`

---

#### cache.nixos.org

**Website**

https://cache.nixos.org/

**Description**

The default upstream Nix binary cache operated by the NixOS Foundation, populated by Hydra builds of `nixpkgs`. Every Nix install pulls from here by default; for a homelab, it is the substituter you almost never override — you only add additional caches alongside it.

**Tags**

`#binary-cache` `#upstream` `#nixos-foundation`

---

#### nix-community/nixci

**Website**

https://github.com/nix-community/nixci

**Description**

CLI that builds **all** the outputs of a flake (including sub-flakes referenced via `dir` attributes) in a single invocation, with optional Cachix integration. Designed to be run locally or inside CI to mirror what Hydra would do for a flake — a fast way to validate "does everything in this flake still build?" before merging a PR.

**Tags**

`#ci` `#cli` `#flakes`

---

#### numtide/treefmt

**Website**

https://github.com/numtide/treefmt

**Description**

The underlying formatter-runner: one config file, multiple formatters, one `treefmt` invocation that walks the tree and only touches changed files. Useful in any repo, but pairs especially well with Nix via `treefmt-nix` for reproducible formatter versions.

**Tags**

`#formatting` `#cli` `#ci`

---

#### nix-community/nix-unit

**Website**

https://github.com/nix-community/nix-unit

**Description**

Unit-testing framework for Nix expressions. Lets you write `tests` attributes in pure Nix and execute them via a fast evaluator, with integration into `flake checks`. Particularly useful for testing NixOS module logic (e.g. config-merging, option defaults) before applying it to real hosts.

**Tags**

`#testing` `#ci` `#nix-lang`

---

#### garnix.io

**Website**

https://garnix.io/

**Description**

Hosted CI service for Nix flakes that automatically builds every output across a build matrix of Linux/macOS and x86_64/aarch64, with built-in binary caching. Free tier for public GitHub repos. A turnkey alternative to self-hosted Hydra or wiring up GitHub Actions yourself.

**Tags**

`#ci-saas` `#flakes` `#binary-cache`

---

#### nixbuild.net

**Website**

https://nixbuild.net/

**Description**

Hosted remote-build service for Nix. Instead of building locally, you point Nix at `ssh://nixbuild.net` and it executes derivations on shared infrastructure billed per build second. Especially valuable for cross-compiling to `aarch64-linux` from an `x86_64` homelab, or for bursting beyond local CPU/RAM limits.

**Tags**

`#remote-builder` `#ci-saas` `#build-farm`

---

#### nixbuild/nixbuild-action

**Website**

https://github.com/nixbuild/nixbuild-action

**Description**

GitHub Action that wires up `nixbuild.net` as a remote builder for a workflow's Nix. All `nix build` invocations inside the job are transparently offloaded to nixbuild.net, bypassing GitHub Actions runner CPU/RAM limits entirely. Useful for ARM builds or heavy derivations that timeout on standard runners.

**Tags**

`#github-actions` `#nixbuild` `#remote-builder`

---

### 37. Cloud Providers — Deploying NixOS / Nix Images

NixOS is unusually cloud-friendly: a single `nixos-generate` produces a bootable image for AWS, Azure, GCP, Hetzner Cloud, DigitalOcean, or Oracle Cloud. For servers that already run Linux (Hetzner, DigitalOcean, Oracle), `nixos-infect` and `nixos-anywhere` bootstrap NixOS in place over SSH without reinstalling. For declarative multi-cloud provisioning, `nixops` (legacy) or `nixops4` (in development) provide Terraform-like orchestration driven from a Nix expression.

#### NixOS Manual: Installing on Amazon EC2

**Website**

https://nixos.org/manual/nixos/stable/#sec-installing-amazon-ec2

**Description**

The official NixOS manual chapter covering EC2 deployment: which AMI to use, how NixOS auto-configures on first boot via EC2 user-data, and how the instance store/EBS layouts work. Required reading before booting your first NixOS EC2 instance.

**Tags**

`#aws` `#docs` `#ec2`

---

#### elitnog/nixos-infect

**Website**

https://github.com/elitnog/nixos-infect

**Description**

Shell script that "infects" a running Linux cloud instance (typically Ubuntu/Debian) with NixOS by installing Nix, building a target config, then replacing the running system in place. Works on hosts where you can't `kexec` (e.g. some LXC containers or restricted clouds). The most forked and maintained continuation of the original `nixos-infect` concept.

**Tags**

`#installer` `#cloud` `#in-place`

---

#### NixOS Manual: Installing on Google Compute Engine

**Website**

https://nixos.org/manual/nixos/stable/#sec-installing-gce

**Description**

Official manual chapter covering Google Compute Engine: how to use `nixos-generators -f gce` to produce a GCE image, upload it with `gcloud compute images create`, and launch NixOS VMs. Includes the GCE-specific NixOS options for metadata-driven configuration.

**Tags**

`#gcp` `#docs` `#cloud-image`

---

#### NixOS Manual: Installing on Microsoft Azure

**Website**

https://nixos.org/manual/nixos/stable/#sec-installing-azure

**Description**

Official manual chapter for Azure: producing a VHD with `nixos-generators -f azure`, uploading it, and registering it as an Azure image. Includes notes on the Azure agent and cloud-init interop. Useful when your homelab spans into Azure for cheap Windows VMs or specific regions.

**Tags**

`#azure` `#docs` `#cloud-image`

---

#### Hetzner Cloud + NixOS (via nixos-anywhere)

**Website**

https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md

**Description**

Documented quickstart for using `nixos-anywhere` to install NixOS onto a freshly-booted Hetzner Cloud VM in a single command. Provisions a Hetzner Cloud server (any OS), then `kexec`s into a NixOS closure built locally and uploaded over SSH. The recommended modern path, replacing the legacy `nixos-infect` flow for Hetzner.

**Tags**

`#hetzner` `#installer` `#nixos-anywhere`

---

#### nixops/nixops4

**Website**

https://github.com/nixops/nixops4

**Description**

Ground-up rewrite of NixOps led by the original NixOps maintainers. Uses a stateless, flake-first design and replaces the old plugin/backends model with composable Nix expressions. Still pre-1.0 but actively developed; track it if you want a pure-Nix alternative to Terraform for multi-cloud NixOS provisioning.

**Tags**

`#nixops` `#deploy` `#flakes`

---

#### nix-community/packer-nixos

**Website**

https://github.com/nix-community/packer-nixos

**Description**

HashiCorp Packer templates and provisioners for building NixOS images on cloud providers (AWS, DigitalOcean, GCP, etc.) using Packer's `qemu`/`amazon-ebs` builders. Useful if your existing image pipeline is already Packer-based and you want NixOS images produced by the same toolchain. Largely superseded by `nixos-generators` for new work.

**Tags**

`#packer` `#image-builder` `#legacy`

---

#### Terraform `terraform-provider-nixos`

**Website**

https://github.com/elementaryos/terraform-provider-nixos (community) — also see https://github.com/nix-community?q=terraform

**Description**

Community Terraform providers that can apply a NixOS configuration to a remote machine after Terraform provisions the underlying cloud instance. Workflow: Terraform creates the VM (AWS/Hetzner/DO/etc.), then the provider SSHes in and runs `nixos-rebuild switch` against a flake. Bridges an existing Terraform estate with a NixOS configuration repository.

**Tags**

`#terraform` `#deploy` `#iac`

---

#### DeterminateSystems/flakehub

**Website**

https://flakehub.com/

**Description**

FlakeHub is a registry and cache for Nix flakes run by Determinate Systems. It pins flake inputs to specific versions (good for supply-chain hygiene), serves cached flake outputs, and integrates with the Determinate GitHub Actions. Useful in a homelab CI pipeline to ensure reproducible, auditable flake input resolution across machines.

**Tags**

`#flakehub` `#registry` `#ci`

---

#### nix-community/nix-eval-jobs (used by Hydra/Hercules)

**Website**

https://github.com/nix-community/nix-eval-jobs

**Description**

Parallel evaluator for Nix expressions: splits a flake/jobset evaluation across multiple cores/processes and emits JSON describing each derivation. Used under the hood by Hydra and Hercules CI to evaluate large flakes quickly. Useful as a building block if you're rolling your own CI.

**Tags**

`#evaluator` `#ci` `#performance`

---

#### colmena (NixOS deployment tool)

**Website**

https://github.com/zhaofengli/colmena

**Description**

A simple, declarative NixOS deployment tool in the spirit of NixOps but focused on a narrower use case: deploy a NixOS config defined in a flake to a set of remote machines over SSH. No state file, no cloud provisioning — just `colmena apply`. A popular pick for homelabs where the underlying VMs/bare-metal already exist.

**Tags**

`#deploy` `#ssh` `#flakes`

---

#### nixos-facter / nixos-facter-modules

**Website**

https://github.com/numtide/nixos-facter

**Description**

Tool that inventories a running machine's hardware (PCI devices, kernel modules, filesystem layout) and emits a declarative NixOS module so that hardware config is captured rather than guessed at. Pairs naturally with `nixos-anywhere` to bootstrap a NixOS box with hardware enablement already correct on first boot.

**Tags**

`#hardware` `#discovery` `#installer`

---


---

## Part XII — Example Configurations & Community

### 38. Example Configurations — Dotfiles

These are widely-studied public NixOS + home-manager configurations. They demonstrate idiomatic flake structure, module decomposition, secrets handling, and multi-host layouts. Reading a few before designing your own flake is the single highest-leverage thing you can do.

#### Misterio77/nix-starter-configs

**Website**

https://github.com/Misterio77/nix-starter-configs

**Description**

The canonical "I just want to start with NixOS + flakes + home-manager" template repository (~3.5k+ stars). Provides three flake templates (minimal, standard, standard-with-overlays) that ship working boilerplate for `flake.nix`, `home-manager` as a NixOS module, and per-host configuration. Best first-stop template for a fresh homelab flake; issue #86 documents its intentionally limited scope.

**Tags**

`#starter-template` `#flakes` `#home-manager`

---

#### Misterio77/Foundry (formerly nix-config)

**Website**

https://github.com/Misterio77/Foundry

**Description**

Misterio's "production" personal monorepo — the grown-up sibling of `nix-starter-configs` (~1.5k+ stars across the original `nix-config` and the renamed `Foundry` org). Runs multiple desktops + servers from a single flake with `sops-nix`, `impermanence`, disko, and per-host hardware modules. Excellent reference for how a hobbyist can scale from a single laptop to a fleet.

**Tags**

`#multi-host` `#sops-nix` `#impermanence`

---

#### gvolpe/nix-config

**Website**

https://github.com/gvolpe/nix-config

**Description**

Gabriel Volpe's well-documented NixOS + macOS config (~1k+ stars). Covers home-manager, Neovim, Hyprland/Sway, and a QEMU-testable server config. Commonly cited on r/NixOS as a clean architectural reference and a great example of how to share modules between Linux desktops and macOS via nix-darwin.

**Tags**

`#dotfiles` `#neovim` `#nix-darwin`

---

#### Mic92/dotfiles

**Website**

https://github.com/Mic92/dotfiles

**Description**

Jörg Thalheim's (Mic92) personal NixOS configuration (~700+ stars). Author of `sops-nix`, `bento`, and numerous nixpkgs contributions, so the module style is the same one used in widely-adopted nix-community projects. A great reference for how a long-time NixOS contributor structures secrets, retentions, and multi-machine fleets.

**Tags**

`#sops-nix` `#expert` `#multi-host`

---

#### ryantm/nixos-config

**Website**

https://github.com/ryantm/nixos-config

**Description**

Ryan Mulligan's personal NixOS configuration, often referenced because the author maintains `alejandra` and the `update-flake-lock` GitHub Action. Useful as a minimal, frequently-updated example of a flakes-first NixOS config with home-manager and a small set of well-curated modules.

**Tags**

`#dotfiles` `#alejandra` `#flakes`

---

#### maynik/nixos

**Website**

https://github.com/maynik/nixos

**Description**

A frequently-recommended beginner-friendly NixOS configuration repo. Demonstrates a clean module layout, home-manager integration, and a per-machine `hosts/` directory — a useful "what does a sane flake look like?" reference for someone graduating from `nix-starter-configs`.

**Tags**

`#beginner-friendly` `#flakes` `#home-manager`

---

#### NotAShelf/nixfiles

**Website**

https://github.com/NotAShelf/nixfiles

**Description**

NotAShelf's (raf) heavily modular NixOS dotfiles, focused on the Hyprland desktop and an option-based module system. Sometimes referenced as a "blueprint" of how to make every machine a thin host module that pulls from a shared options interface. The repo has occasionally been re-organized between `NotAShelf/nixfiles` and other orgs; check the README for current canonical location before cloning.

**Tags**

`#hyprland` `#modular` `#dotfiles`

---

#### h7x4/nixos-config

**Website**

https://github.com/h7x4/nixos-config

**Description**

A well-organized personal NixOS configuration emphasizing overlays, package overrides, and a tidy `home/` and `hosts/` separation. Useful for learning how to structure per-user dotfiles alongside system-level modules without coupling them.

**Tags**

`#dotfiles` `#overlays` `#module-organization`

---

#### hendrik-l/nixos-configuration

**Website**

https://github.com/hendrik-l/nixos-configuration

**Description**

Hendrik's NixOS configuration, commonly cited for its clean flake structure with shared `modules/`, a `hosts/` directory, and `home-manager` integrated as a NixOS module. Good intermediate-level reference after starter-configs.

**Tags**

`#dotfiles` `#flakes` `#module-organization`

---

#### vimjoyer/dotfiles

**Website**

https://github.com/vimjoyer/dotfiles

**Description**

Vimjoyer's personal NixOS configuration, paired with his widely-watched YouTube tutorials. Useful companion to his video series because you can clone the exact flake shown on screen. Demonstrates a pragmatic, single-user, flakes-first layout that mirrors what he teaches.

**Tags**

`#beginner-friendly` `#flakes` `#youtube-companion`

---

#### Xe/x (Xe Iaso's NixOS configs)

**Website**

https://github.com/Xe/x

**Description**

Xe Iaso's monorepo covering NixOS, nix-darwin, home-manager, and a large collection of self-authored services and tooling. A sprawling reference for "what does an opinionated NixOS power user's repo look like" — notably including custom Docker image builds, a NAS config, and the `xesite` infrastructure. (Xe stepped back from Nix governance in 2024 but the configs remain publicly archived; see `Xe/blog-nixos-configs` for the standalone example used in blog posts.)

**Tags**

`#expert` `#nix-darwin` `#monorepo`

---

#### ryan4yin/nix-config

**Website**

https://github.com/ryan4yin/nix-config

**Description**

Ryan Yin's NixOS + nix-darwin config (~2k+ stars), companion to his `nixos-and-flakes-book`. Covers desktops (Hyprland, GNOME, KDE), servers, and Kubernetes — a strong reference if you want to manage workstations and homelab hosts from one flake.

**Tags**

`#desktop` `#kubernetes` `#book-companion`

---

#### mitchellh/nixos-config

**Website**

https://github.com/mitchellh/nixos-config

**Description**

Mitchell Hashimoto's personal NixOS configuration, often recommended on r/NixOS for its "throw every nix file into a chat" simplicity (per Evan Travers' write-up). A great counter-example to over-engineered flakes — demonstrates the minimal structure needed for a single host with home-manager.

**Tags**

`#minimal` `#dotfiles` `#beginner-friendly`

---

#### hlissner/dotfiles

**Website**

https://github.com/hlissner/dotfiles

**Description**

Henrik Lissner's (author of `doom-emacs`) NixOS dotfiles (~1.7k+ stars). One of the older and more influential configs in the community — pioneered patterns for per-host modules, overlays, and home-manager that later starter-configs borrowed from. Still actively maintained and a strong reference for advanced Emacs + Linux desktop users.

**Tags**

`#emacs` `#expert` `#influential`

---

#### nix-community/srvos

**Website**

https://github.com/nix-community/srvos

**Description**

Not a personal dotfile repo but a shared NixOS module library for "server" defaults — common hardening, Tory-approved `nix.gc` settings, RAID/ZFS defaults, and per-cloud-provider profiles (Hetzner, DigitalOcean, etc.). Nearly every serious NixOS homelab imports at least the `common` and `server` modules. Maintained by Mic92 and the nix-community org.

**Tags**

`#server-defaults` `#hardening` `#nix-community`

---

### 39. Complete Homelabs

These repositories self-describe as homelabs — multi-host NixOS deployments of self-hosted services, networking gear, and often Tailscale/Wireguard meshes. They are the closest you can get to "show me a real, running NixOS homelab."

#### Hermitter/nixos-homelab-template

**Website**

https://github.com/Hermitter/nixos-homelab-template

**Description**

Explicitly a template for homelab operators: covers encrypted secrets (sops-nix), shared module sets across machines, and automatic rollback on failed deployments. Good starting skeleton for someone who wants deploy-rs or Colmena with safe defaults built in.

**Tags**

`#template` `#sops-nix` `#rollback`

---

#### badele/nix-homelab

**Website**

https://github.com/badele/nix-homelab

**Description**

A complete homelab and dotfiles monorepo built on NixOS + Clan. Includes per-host configurations, Tailscale, and a documented `docs/features/` directory explaining each piece. Useful as a real worked example of the "Clan for fleet management" pattern.

**Tags**

`#clan` `#tailscale` `#homelab`

---

#### jhillyerd/homelab

**Website**

https://github.com/jhillyerd/homelab

**Description**

NixOS + Nomad configs for a homelab cluster. Interesting because it pairs NixOS hosts with HashiCorp Nomad rather than the more common k3s/Traefik pattern — a useful reference if you want a Nomad/Consul-style service mesh.

**Tags**

`#nomad` `#service-mesh` `#homelab`

---

#### ryanmalonzo/homelab-nixos

**Website**

https://github.com/ryanmalonzo/homelab-nixos

**Description**

A declarative homelab that pairs NixOS with Terraform — useful as a reference for the "NixOS for the hosts, Terraform for cloud/network provisioning" hybrid pattern that many homelabbers settle on.

**Tags**

`#terraform` `#declarative` `#homelab`

---

#### johtok/nix-homelab-config

**Website**

https://github.com/johtok/nix-homelab-config

**Description**

A fork of Misterio77's starter-config adapted into a personal homelab flake. Useful as a worked example of "what does the starter-config look like 6 months in, after someone has added real services."

**Tags**

`#homelab` `#starter-config-fork` `#flakes`

---

#### Eric Cheng — Using NixOS for my homelab

**Website**

https://www.chengeric.com/homelab

**Description**

Eric Cheng's blog post + accompanying NixOS config repo. Walks through migrating a homelab to NixOS, including Nextcloud, Tailscale, remote LUKS unlock, and reproducible ISO/WSL tarball releases via GitHub Actions. Frequently linked from r/NixOS homelab threads.

**Tags**

`#homelab` `#tailscale` `#nextcloud`

---

#### Gerschtli/nix-config

**Website**

https://github.com/Gerschtli/nix-config

**Description**

A flakified, multi-host NixOS configuration often shared on r/NixOS. Demonstrates a clean separation between server and desktop hosts and shows patterns for declarative service configuration.

**Tags**

`#multi-host` `#flakes` `#dotfiles`

---

#### spikespaz/dotfiles (Bird OS)

**Website**

https://github.com/spikespaz/dotfiles

**Description**

A heavily customized NixOS desktop and home-manager configuration ("Bird OS"). Useful as a reference for how to ship both NixOS and home-manager modules in one flake with shared options, particularly for desktop ricing.

**Tags**

`#desktop` `#ricing` `#home-manager`

---

#### Heinrich Hartmann — Home Lab Infrastructure 2023

**Website**

https://www.heinrichhartmann.com/posts/home-lab-2023

**Description**

Detailed write-up of a NixOS-based home lab with Tailscale VPN and secrets management. Not a repo per se but a recurring-style blog reference that pairs well with the actual dotfile repos above; covers the operational realities (backups, monitoring, remote access) that most "look at my flake" posts skip.

**Tags**

`#tailscale` `#secrets` `#operations`

---

#### not-matthias/dotfiles-nix

**Website**

https://github.com/not-matthias/dotfiles-nix

**Description**

A NixOS + flakes personal config commonly surfaced when searching GitHub topics. Compact reference for someone who wants the minimum flake structure for a desktop + a laptop with home-manager.

**Tags**

`#dotfiles` `#flakes` `#desktop`

---

### 40. Public Infrastructure Repositories

These are the configs behind real organizations running NixOS at scale. They are the only way to see how teams handle multi-tenancy, secrets, CI, and rollback in production.

#### NixOS/nixos-org-configurations

**Website**

https://github.com/NixOS/nixos-org-configurations

**Description**

The actual NixOS configuration that powers `nixos.org`, `cache.nixos.org` infrastructure-facing services, and the project's marketing/CI infrastructure. The canonical reference for "how does the NixOS project itself deploy its public infrastructure?" — uses Colmena, srvos, and a per-host module layout.

**Tags**

`#nixos-project` `#colmena` `#production`

---

#### serokell/serokell.nix

**Website**

https://github.com/serokell/serokell.nix

**Description**

Serokell's shared NixOS module library — the building blocks they use across client infrastructures. Contains opinionated hardening, monitoring, and deployment defaults. A good "what does a Nix consultancy ship as its standard library?" reference.

**Tags**

`#serokell` `#consultancy` `#hardening`

---

#### obsidian-systems/nixos

**Website**

https://github.com/obsidian-systems

**Description**

Obsidian Systems' GitHub org — contains a collection of public NixOS modules, infra configs, and tooling (e.g. `obsidian-systems/nixos-xmonad` and various internal-tooling flakes). Browse the org for examples of how a Haskell-focused consultancy structures NixOS deployments.

**Tags**

`#consultancy` `#haskell` `#infrastructure`

---

#### hercules-ci/nixflk

**Website**

https://github.com/hercules-ci/nixflk

**Description**

A "highly structured NixOS configuration template" from the Hercules CI team. Predates `flake-parts` but is still a useful reference for how to organize a flake that separates concerns cleanly across `hosts/`, `modules/`, `overlays/`, and `profiles/`.

**Tags**

`#template` `#flake-structure` `#hercules-ci`

---

#### DeterminateSystems (org)

**Website**

https://github.com/DeterminateSystems

**Description**

Determinate Systems' GitHub org — produces the Determinate Nix Installer, `flake-schemas`, FlakeHub, and a growing set of NixOS infra tooling. Their READMEs and the `nix`/`flake-schemas` repos are excellent references for how to ship opinionated Nix tooling with first-class module support.

**Tags**

`#determinate-systems` `#flakes` `#installer`

---

#### cachix/cachix-deploy

**Website**

https://github.com/cachix/cachix-deploy

**Description**

Cachix's deploy tool and NixOS agent — pushes prebuilt closures from a binary cache to remote agents, which is a popular alternative to deploy-rs/Colmena when you already use Cachix. The `docs.cachix.org/deploy` pages include worked NixOS examples that double as a "production deploy" reference.

**Tags**

`#cachix` `#deploy` `#binary-cache`

---

#### numtide/nixos-passthru-cache

**Website**

https://github.com/numtide/nixos-passthru-cache

**Description**

A drop-in pull-through (passthru) Nix binary cache from Numtide. Extremely useful for homelabs — put it on your network, point all your NixOS machines at it, and watch egress drop while first-time builds speed up. Includes a NixOS module for declarative deployment.

**Tags**

`#binary-cache` `#numtide` `#caching`

---

#### numtide (org)

**Website**

https://github.com/numtide

**Description**

Numtide's GitHub org — they are a NixOS consultancy that publishes extensively: `treefmt-nix`, `nixos-anywhere` (with Lassulus), `devenv`-adjacent tooling, and many infra reference configs. Browse the org for production-grade module patterns and tooling.

**Tags**

`#consultancy` `#numtide` `#tooling`

---

#### NixOS/ofborg

**Website**

https://github.com/NixOS/ofborg

**Description**

The CI bot that handles `@ofborg` commands on every nixpkgs PR — built on Nix itself. Reading the source is the only way to understand how nixpkgs gets built/tested at scale. Issue #68 ("Provide a binary cache for builds") is a classic historical thread on the project's caching strategy.

**Tags**

`#ofborg` `#nixpkgs-ci` `#infrastructure`

---

#### grahamc/my-nixos-cluster (and grahamc org)

**Website**

https://github.com/grahamc

**Description**

Graham Christensen's GitHub — he was instrumental in building cache.nixos.org and Amazon-backed NixOS infra. His personal repos (look for `nixos-*` and `infra-*` repos) document how to run large NixOS fleets on EC2 with spot instances, S3-backed caches, and Hydra.

**Tags**

`#hydra` `#cache-nixos-org` `#aws`

---

#### nix-community/infra

**Website**

https://github.com/nix-community/infra

**Description**

The NixOS configuration that powers nix-community services (binary caches, `nur-combined`, etc.). Useful as a small, real-world reference for how the community runs shared infra on a budget with srvos, deploy-rs, and Cachix.

**Tags**

`#nix-community` `#infrastructure` `#deploy-rs`

---

### 41. Blogs

These are recurring, often-updated sources of NixOS knowledge — from the official `nix.dev` to long-running personal blogs. Bookmark the RSS feeds.

#### nix.dev — Blog & Guides

**Website**

https://nix.dev/blog

**Description**

The official NixOS Foundation learning site and blog. Maintained by the Documentation Team and hosts the canonical "Advent of Nix" articles, flakes tutorials, and reproducible-package recipes. The first place to send anyone who asks "how do I learn Nix?"

**Tags**

`#official` `#documentation` `#tutorials`

---

#### Serokell Blog — Nix & NixOS

**Website**

https://serokell.io/blog

**Description**

Serokell's engineering blog — a prolific source of long-form Nix/NixOS posts covering profiling, cross-compilation, Haskell-on-NixOS, and reproducibility deep dives. Well-edited, technically dense, and updated weekly.

**Tags**

`#serokell` `#deep-dives` `#engineering-blog`

---

#### Determinate Systems Blog

**Website**

https://determinate.systems/blog

**Description**

Determinate Systems' blog — the most active commercial NixOS voice right now. Posts like "Nix flakes explained" (Nov 2025) and "Introducing flake schemas" (Mar 2026) define the modern flakes conversation. Required reading if you use Determinate Nix or FlakeHub.

**Tags**

`#determinate-systems` `#flakes` `#flakehub`

---

#### gvolpe — Blog

**Website**

https://gvolpe.com/blog

**Description**

Gabriel Volpe's personal blog. The "NixOS: build your system on Github Actions!" post (Aug 2021) remains a classic reference for pre-building system closures in CI. Covers home-manager, Neovim, Hyprland, and Rust-on-NixOS.

**Tags**

`#gvolpe` `#ci` `#home-manager`

---

#### Vimjoyer — YouTube Channel

**Website**

https://www.youtube.com/@vimjoyer

**Description**

The most-watched NixOS tutorial channel ("Ultimate NixOS Guide | Flakes | Home-manager", "Ultimate Nix Flakes Guide", "NixOS Explained"). Pair with his `github.com/vimjoyer/dotfiles` repo for a complete, beginner-friendly on-ramp. Frequently the first thing recommended on r/NixOS to newcomers.

**Tags**

`#video` `#beginner-friendly` `#flakes`

---

#### Xe Iaso — Blog (tonic free)

**Website**

https://xeiaso.net/blog

**Description**

Xe Iaso's long-running personal blog — heavily NixOS-focused with posts on building Docker images with Nix, the `Xe/x` monorepo, and idiosyncratic service deployments. The "So long, and thanks for all the fish" farewell-to-Nix-governance post (Jun 2024) is essential context for the project's 2024 drama. Blog is "tonic free" — no paywall, no newsletter gating.

**Tags**

`#xe-iaso` `#opinionated` `#long-form`

---

#### Ryan Yin — NixOS & Flakes Book

**Website**

https://nixos-and-flakes.thiscute.world/

**Description**

The closest thing NixOS has to an unofficial "missing manual" — a free, frequently-updated online book by Ryan Yin (`github.com/ryan4yin/nixos-and-flakes-book`). Covers the language, flakes, home-manager, modules, and idiomatic patterns with worked examples. Pairs with his `nix-config` repo.

**Tags**

`#book` `#flakes` `#beginner-friendly`

---

#### NixOS Wiki (community-run)

**Website**

https://wiki.nixos.org/

**Description**

The community-maintained NixOS wiki (rebranded from `nixos.wiki` to the project-hosted `wiki.nixos.org` in 2024). First stop for "how do I configure X service on NixOS?" before checking `search.nixos.org/options`. Many articles include copy-pasteable snippets.

**Tags**

`#wiki` `#community` `#reference`

---

#### torgeir.dev — Nix posts

**Website**

https://torgeir.dev/

**Description**

Torgeir Thordarson's blog. "More good stuff about Nix: NixOS modules" (Sep 2023) is a frequently-cited primer on module composition. Good intermediate-level reading after `nix-starter-configs`.

**Tags**

`#modules` `#intermediate` `#personal-blog`

---

#### gianarb.it — NixOS posts

**Website**

https://gianarb.it/blog

**Description**

Gianarb's blog — "How I started with NixOS" (Oct 2021) and follow-ups cover the practical transition from a "classic" Linux server to NixOS. Pragmatic, non-evangelical tone.

**Tags**

`#migration` `#personal-blog` `#practical`

---

#### guekka.github.io — NixOS as a server

**Website**

https://guekka.github.io/

**Description**

Multi-part "NixOS as a server" series covering flakes, Tailscale, secrets (agenix vs sops-nix), and deployment. A useful, narrow, server-focused companion to the desktop-heavy guides.

**Tags**

`#server` `#tailscale` `#secrets`

---

#### Perfect Media Server — NixOS Edition

**Website**

https://perfectmediaserver.com/

**Description**

Long-running, frequently-updated guide to building a Linux media server. The NixOS edition documents the SnapRAID + mergerfs + Docker-on-NixOS stack that many homelabbers converge on. A rare end-to-end "I want a NAS + media stack" reference.

**Tags**

`#media-server` `#snapraid` `#homelab`

---

#### seroperson.me — Managing dotfiles with Nix

**Website**

https://seroperson.me/2024/01/16/managing-dotfiles-with-nix/

**Description**

A focused post on using Nix and home-manager for dotfile management, including patterns for converting existing classic dotfiles into home-manager modules. Good first "why home-manager?" explainer.

**Tags**

`#home-manager` `#dotfiles` `#migration`

---

#### evantravers.com — Reorganizing My Nix Dotfiles

**Website**

https://evantravers.com/articles/2025/04/17/reorganizing-my-nix-dotfiles/

**Description**

A 2025 post on rewriting a NixOS config around `mitchellh/nixos-config`-style simplicity. A good antidote to over-engineered flakes — explicitly argues for "throw every nix file into a chat" minimalism.

**Tags**

`#minimalism` `#personal-blog` `#opinionated`

---

#### XDA Developers — NixOS homelab articles

**Website**

https://www.xda-developers.com/configured-my-entire-home-lab-with-a-single-nix-flake/

**Description**

Mainstream-press article on running an entire homelab off a single NixOS flake. Light on code, useful as a "what is NixOS good for?" explainer to send to non-technical partners or friends before you start migrating the home network.

**Tags**

`#overview` `#homelab` `#beginner-friendly`

---

#### virtualizationhowto.com — NixOS homelab tweaks

**Website**

https://www.virtualizationhowto.com/

**Description**

A sysadmin-focused blog with several NixOS posts including "The NixOS Tweaks I Wish I'd Started Using Sooner in my Home Lab" (Jul 2026). Practical operational advice from someone running NixOS in production.

**Tags**

`#sysadmin` `#operations` `#practical`

---

### 42. Reddit Threads

These are specific, high-signal Reddit threads. The NixOS subreddit is unusually technical — these particular threads are the ones most linked from Discourse and blog posts.

#### r/NixOS — How do you deploy your updated configs?

**Website**

https://www.reddit.com/r/NixOS/comments/1ein313/how_do_you_deploy_your_updated_configs/

**Description**

The canonical "what deploy tool should I use?" megathread — dozens of users describe their git-push-then-`nixos-rebuild` vs deploy-rs vs Colmena vs Cachix-deploy workflows. Read before picking a deploy tool.

**Tags**

`#deployment` `#workflow` `#megathread`

---

#### r/NixOS — Best nixos deployment for raspberry pi/home iot

**Website**

https://www.reddit.com/r/NixOS/comments/175hepu/best_nixos_deployment_for_raspberry_pihome_iot/

**Description**

Practical discussion of deploying NixOS to Raspberry Pi and IoT targets, including SD-image generation, sops-nix for secrets, and the trade-offs between NixOps (then-still-used), deploy-rs, and Colmena for ARM targets.

**Tags**

`#raspberry-pi` `#iot` `#deployment`

---

#### r/NixOS — Nix OS Inside Lxc Container

**Website**

https://www.reddit.com/r/NixOS/comments/1v2zdgf/nix_os_inside_lxc_container/

**Description**

Thread on running NixOS inside LXC/Incus containers, including secrets handling (sops-nix) and whether to use deploy-rs or Colmena for containerized NixOS hosts. Useful if you want NixOS as a guest rather than a hypervisor.

**Tags**

`#lxc` `#containers` `#sops-nix`

---

#### r/NixOS — Are Flakes and Home Manager necessary?

**Website**

https://www.reddit.com/r/NixOS/comments/1oc92fa/are_flakes_and_home_manager_necessary/

**Description**

Honest, opinionated thread on whether a newcomer actually *needs* flakes and home-manager in 2025+ — a useful counterweight to the "everyone must use flakes immediately" discourse. Good for setting realistic expectations.

**Tags**

`#flakes` `#home-manager` `#beginner`

---

#### r/NixOS — What are some tools you guys use to deploy Nix/NixOS in production?

**Website**

https://www.reddit.com/r/NixOS/comments/1f3id3q/what_are_some_tools_you_guys_use_to_deploy/

**Description**

Production-focused deployment thread — covers deploy-rs, Colmena, Cachix deploy, and Hercules CI Agent. Includes a real-world "deploy a Django app + Postgres" use case.

**Tags**

`#deployment` `#production` `#django`

---

#### r/NixOS — Using NixOS for my homelab

**Website**

https://www.reddit.com/r/NixOS/comments/1bkt4rw/using_nixos_for_my_homelab/

**Description**

Eric Cheng's r/NixOS post accompanying his blog — covers Nextcloud, remote LUKS unlock, and the migration experience. Read alongside the chengeric.com blog post above.

**Tags**

`#homelab` `#nextcloud` `#luks`

---

#### r/NixOS — Good configs to copy?

**Website**

https://www.reddit.com/r/NixOS/comments/1ffucec/good_configs_to_copy/

**Description**

A newcomer asks for configs to study; replies point to `Misterio77/nix-starter-configs`, `gvolpe/nix-config`, and others. A curated, human-filtered alternative to GitHub topic search.

**Tags**

`#beginner` `#configs-to-study` `#megathread`

---

#### r/NixOS — One repo for nixos and home-manager configurations

**Website**

https://www.reddit.com/r/NixOS/comments/1iajlws/one_repo_for_nixos_and_homemanager_configurations/

**Description**

Discussion of how to structure a single git repo that tracks both NixOS system configs and home-manager user configs. Covers the "home-manager as NixOS module vs standalone" decision in concrete terms.

**Tags**

`#repo-structure` `#home-manager` `#flakes`

---

#### r/NixOS — Advice for a completely Declarative Homelab

**Website**

https://www.reddit.com/r/NixOS/comments/1rjspzf/advice_for_a_completely_declarative_homelab/

**Description**

Thread on going fully declarative with `import-tree` + `flake-parts` to auto-discover modules. Good intermediate reading for when your `hosts/` directory starts feeling repetitive.

**Tags**

`#declarative` `#flake-parts` `#import-tree`

---

#### r/NixOS — How do I get started with NixOS? Any beginner tutorial videos or articles?

**Website**

https://www.reddit.com/r/NixOS/comments/1ulirv7/how_do_i_get_started_with_nixos_any_beginner/

**Description**

The single most-asked question on r/NixOS. Replies converge on Vimjoyer videos, the NixOS & Flakes book, and starting in a VM. Useful thread to bookmark for friends you're trying to convert.

**Tags**

`#beginner` `#onboarding` `#megathread`

---

#### r/NixOS — Announcing Determinate Nix, a distribution of Nix built for production

**Website**

https://www.reddit.com/r/NixOS/comments/1g8yu9m/announcing_determinate_nix_a_distribution_of_nix/

**Description**

The launch thread for Determinate Nix (Oct 2024). Comments capture the community's mixed-but-mostly-positive reaction — essential context for understanding why "Determinate Nix vs upstream Nix" is now a real choice for homelab operators.

**Tags**

`#determinate-nix` `#announcement` `#controversy`

---

#### r/NixOS — Trying Misterio77's simple flake setup with multiple issues

**Website**

https://www.reddit.com/r/NixOS/comments/ym8lw7/flakes_trying_misterio77s_simple_flake_setup_with/

**Description**

A beginner's troubleshooting thread for `nix-starter-configs`. Useful because the specific failure modes (VMware guest, multi-user setup) come up repeatedly for anyone trying the starter-config for the first time.

**Tags**

`#troubleshooting` `#starter-config` `#vmware`

---

#### r/NixOS — NixOS Configs! (How to search GitHub for configs)

**Website**

https://www.reddit.com/r/NixOS/comments/1c8jvdl/nixos_configs/

**Description**

Thread recommending GitHub topic/code search (`github.com/topics/nixos-configuration`) as the best way to discover configs to study. Useful meta-tactic for finding configs for specific setups (Hyprland, GNOME, server-only).

**Tags**

`#discovery` `#github-search` `#configs`

---

#### r/NixOS — Avoiding local builds (binary cache discussion)

**Website**

https://www.reddit.com/r/NixOS/comments/1t9q3gt/avoiding_local_builds/

**Description**

Thread on avoiding long local builds — strongly recommends a binary cache (Cachix, numtide/nixos-passthru-cache, self-hosted Attic) for things like custom kernels. Directly relevant to homelab operators who keep rebuilding the same expensive derivations.

**Tags**

`#binary-cache` `#performance` `#cachix`

---

#### r/NixOS — Home-manager and nixpkgs mismatch with flakes

**Website**

https://www.reddit.com/r/NixOS/comments/1639mnz/homemanager_and_nixpkgs_mismatch_with_flakes/

**Description**

The classic "Home Manager version X and Nixpkgs version Y mismatch" warning thread. Explains why pinning both inputs to the same release branch matters and how to fix it.

**Tags**

`#home-manager` `#version-mismatch` `#troubleshooting`

---

#### r/NixOS — Homeless Dotfiles With Nix Wrappers

**Website**

https://www.reddit.com/r/NixOS/comments/1okbjg5/homeless_dotfiles_with_nix_wrappers/

**Description**

Discussion of the "homeless dotfiles" pattern — using Nix wrappers to manage dotfiles that live outside the Nix store rather than in `home-manager`. Useful alternative pattern when home-manager feels like overkill.

**Tags**

`#dotfiles` `#wrappers` `#patterns`

---

#### r/NixOS — Containix: Making Nix Flakes first-class citizens in Kubernetes Pods

**Website**

https://www.reddit.com/r/NixOS/comments/1uvv2e2/containix_making_nix_flakes_first_class_citizens/

**Description**

Discussion of the Containix containerd runtime shim (Jul 2026) that runs Nix flakes directly as Kubernetes pods. Interesting for homelabbers running k3s clusters who want to skip Docker images entirely.

**Tags**

`#kubernetes` `#containerd` `#flakes`

---

#### r/selfhosted — Immutable server OS for a docker server

**Website**

https://www.reddit.com/r/selfhosted/comments/16kz0cj/immutable_server_os_for_a_docker_server/

**Description**

Cross-subreddit thread where r/selfhosted compares NixOS to Talos, Kairos, and MicroOS as immutable Docker host operating systems. Useful for the "why NixOS over Talos?" question that homelabbers keep asking.

**Tags**

`#selfhosted` `#immutable-os` `#comparison`

---

#### r/selfhosted — How do you all handle secrets management for your homelab?

**Website**

https://www.reddit.com/r/selfhosted/comments/1hwp7xh/how_do_you_all_handle_secrets_management_for_your/

**Description**

General homelab secrets-management thread — includes the NixOS-specific recommendations (sops-nix, agenix) alongside Vaultwarden, HashiCorp Vault, etc. Good for comparing NixOS-native secrets tooling to the broader self-hosted ecosystem.

**Tags**

`#secrets` `#selfhosted` `#comparison`

---

#### r/Nix — Are there any options for free nix CI builds of open-source?

**Website**

https://www.reddit.com/r/Nix/comments/tpvbqj/are_there_any_options_for_free_nix_ci_builds_of/

**Description**

Older-but-still-cited thread on free CI for open-source Nix projects. Surfaces Hercules CI (free for OSS, bring-your-own-agent), GitHub Actions + `cachix/install-nix-action`, and self-hosted Hydra as the realistic options.

**Tags**

`#ci` `#hercules-ci` `#open-source`

---

#### r/NixOS — GitHub - Gerschtli/nix-config (showcase)

**Website**

https://www.reddit.com/r/NixOS/comments/ru8hks/github_gerschtlinixconfig_a_collection_of_my/

**Description**

Showcase thread for `Gerschtli/nix-config` — covers the author's flakified, multi-host setup. Useful as a "what does a clean intermediate-level config look like?" reference.

**Tags**

`#showcase` `#multi-host` `#flakes`

---

### 43. NixOS Discourse Discussions

`discourse.nixos.org` is the project's official forum and the highest-signal discussion venue. These specific threads are referenced again and again.

#### Discourse — Comparison of different key/secret managing schemes

**Website**

https://discourse.nixos.org/t/comparison-of-different-key-secret-managing-schemes/12001

**Description**

The definitive side-by-side comparison of NixOS secrets tools — `sops-nix`, `agenix`, `git-crypt`, plain `nix-shell -p pass`, etc. (Mar 2021, still updated). The first stop before choosing a secrets tool for a homelab.

**Tags**

`#secrets` `#comparison` `#canonical`

---

#### Discourse — Managing Secrets in NixOS (2025)

**Website**

https://discourse.nixos.org/t/managing-secrets-in-nixos/72569

**Description**

A Nov 2025 update on the state of NixOS secrets management — re-surveys sops-nix and agenix and reaffirms the "configs in /nix/store, secrets via wrapper" best practice. Read alongside the 2021 comparison above.

**Tags**

`#secrets` `#best-practices` `#updated`

---

#### Discourse — Advice: which lean nixos-server devops tool to use?

**Website**

https://discourse.nixos.org/t/advice-which-lean-nixos-server-devops-tool-to-use/23778

**Description**

Discussion of lightweight deployment tools (Colmena vs deploy-rs vs `nixos-rebuild` over SSH) for a small fleet of trusted hosts. Concrete advice for homelab-scale deployments.

**Tags**

`#deployment` `#small-fleet` `#comparison`

---

#### Discourse — agenix-rekey (YubiKey/master-identity extension)

**Website**

https://discourse.nixos.org/t/agenix-rekey-an-agenix-extension-facilitating-yubikey-master-identity-use-by-automating-per-host-secret-rekeying/26746

**Description**

Announcement and discussion of `agenix-rekey`, an extension that automates per-host rekeying when you want to use a single YubiKey as the master identity. Useful for homelabbers with multiple hosts and a hardware security key.

**Tags**

`#agenix` `#yubikey` `#secrets`

---

#### Discourse — Nixverse: File-based Nix Flake Framework

**Website**

https://discourse.nixos.org/t/nixverse-file-based-nix-flake-framework/61183

**Description**

Announcement of `Nixverse`, a file-based flake framework for multi-node configs with cascading secrets and parallel deploys. Useful comparison point against `flake-parts`, `snowfall`, `easy-hosts`, and `blueprint`.

**Tags**

`#framework` `#multi-node` `#flake-parts-alternative`

---

#### Discourse — NixOS, Flakes and KISS

**Website**

https://discourse.nixos.org/t/nixos-flakes-and-kiss/10602

**Description**

A long-running thread (Dec 2020) on keeping NixOS configs simple. Often cited as a counterweight to the proliferation of frameworks. Useful when your flake starts feeling over-engineered.

**Tags**

`#simplicity` `#kiss` `#opinionated`

---

#### Discourse — Self-host-blocks: building blocks for self-hosting with best practices

**Website**

https://discourse.nixos.org/t/self-host-blocks-building-blocks-for-self-hosting-with-best-practices/26963

**Description**

Announcement of `selfhostblocks`, a composable module library that bundles best-practice defaults for self-hosted services (Nextcloud + Postgres + Redis, Vaultwarden + Caddy + Authelia, etc.). Directly relevant to homelabbers who want batteries-included modules.

**Tags**

`#self-host-blocks` `#modules` `#best-practices`

---

#### Discourse — Using SOPS to hide the IP address of the server in public repository

**Website**

https://discourse.nixos.org/t/using-sops-to-hide-the-ip-address-of-the-server-in-public-repository/61264

**Description**

Concrete walk-through of using sops-nix to keep even non-secret data (server IPs) out of public flakes. Includes the key caveat that `git-crypt` is fundamentally not secure with flakes — secrets sit in plaintext in the Git repo once `git-crypt` is unlocked.

**Tags**

`#sops-nix` `#public-flake` `#opsec`

---

#### Discourse — Nix flakes explained: what they solve, why they matter, and the future

**Website**

https://discourse.nixos.org/t/nix-flakes-explained-what-they-solve-why-they-matter-and-the-future/72302

**Description**

The Discourse mirror of Determinate Systems' Nov 2025 "flakes explained" post, with rich discussion in the replies. The single best modern explainer for what flakes actually are and where they're headed.

**Tags**

`#flakes` `#explainer` `#future`

---

#### Discourse — How do you structure your NixOS configs?

**Website**

https://discourse.nixos.org/t/how-do-you-structure-your-nixos-configs/65851

**Description**

Jun 2025 community thread on flake organization — replies show a wide range of layouts (one-file-per-host, modules-with-options, flake-parts, snowfall, easy-hosts, blueprint). Excellent starting point for picking a layout.

**Tags**

`#structure` `#flakes` `#community-survey`

---

#### Discourse — Nix: structuring Flakes with Blueprint

**Website**

https://discourse.nixos.org/t/nix-structuring-flakes-with-blueprint/59757

**Description**

Feb 2025 thread on `blueprint`, a file-based flake-structuring tool. The replies include side-by-side comparisons with `flake-parts` and `snowfall` from people who have used all three.

**Tags**

`#blueprint` `#flake-structure` `#comparison`

---

#### Discourse — DevOS: template repo for NixOS configurations using flakes!

**Website**

https://discourse.nixos.org/t/devos-template-repo-for-nixos-configurations-using-flakes/5325

**Description**

The original Jan 2020 DevOS announcement — the template that pre-dated and heavily influenced `nix-starter-configs`, `flake-parts`, and modern flake structure. Still useful as historical context and as an opinionated reference for a profiles-based layout.

**Tags**

`#devos` `#historical` `#template`

---

#### Discourse — Easy-hosts, ez-config, snowfall — what do you use?

**Website**

https://discourse.nixos.org/t/easy-hosts-ez-config-snowfall-what-do-you-use/61240

**Description**

Mar 2025 thread comparing the major flake-organization frameworks (`easy-hosts`, `ez-config`, `snowfall-lib`, `flake-parts`). Direct comparison of trade-offs; useful when deciding whether to adopt a framework at all.

**Tags**

`#frameworks` `#comparison` `#flake-parts`

---

#### Discourse — An incremental strategy for stabilizing flakes

**Website**

https://discourse.nixos.org/t/an-incremental-strategy-for-stabilizing-flakes/16323

**Description**

Nov 2021 thread that kicked off the (still-ongoing) flakes stabilization effort. Essential context for understanding why flakes are still "experimental" and what the path to stable looks like.

**Tags**

`#flakes` `#stabilization` `#governance`

---

#### Discourse — How do I modularize configuration snippets to modules?

**Website**

https://discourse.nixos.org/t/how-do-i-modularize-configuration-snippets-to-modules/37512

**Description**

Dec 2023 beginner-oriented thread on writing reusable NixOS modules — starts from "one `configuration.nix` per machine" and walks up to shared option-based modules. Concrete and copy-pasteable.

**Tags**

`#modules` `#beginner` `#patterns`

---

#### Discourse — Best practices / code structure for large deployments

**Website**

https://discourse.nixos.org/t/best-practices-code-structure-for-large-deployments/7407

**Description**

May 2020 thread on scaling a NixOS codebase — covers what should/shouldn't go into a module, how to share code between orgs, and how to handle per-environment overrides. A frequently-cited canonical reference.

**Tags**

`#best-practices` `#scaling` `#modules`

---

#### Discourse — Security category

**Website**

https://discourse.nixos.org/c/dev/security/21

**Description**

The official NixOS Discourse Security category — every CVE, hardening discussion, and security-related RFC shows up here. Subscribe if you run NixOS in production.

**Tags**

`#security` `#cve` `#hardening`

---

#### Discourse — Introducing the Determinate Nix Installer

**Website**

https://discourse.nixos.org/t/introducing-the-determinate-nix-installer/25848

**Description**

Feb 2023 announcement of the Determinate Nix Installer — the now-de-facto replacement for the official shell-script installer. Comments cover the "opinionated defaults" (flakes + new CLI enabled in `nix.conf`) that distinguish it from upstream.

**Tags**

`#determinate-systems` `#installer` `#announcement`

---

#### Discourse — So long, and thanks for all the fish (Xe Iaso farewell)

**Website**

https://discourse.nixos.org/t/so-long-and-thanks-for-all-the-fish/47384

**Description**

Jun 2024 farewell post from Xe Iaso stepping back from Nix governance. Essential reading for understanding the 2023–2024 NixOS community drama, the creation of the NixOS Foundation, and the moderation reforms that followed.

**Tags**

`#governance` `#community` `#history`

---

#### Discourse — How to use flakes as a sysadmin

**Website**

https://discourse.nixos.org/t/how-to-use-flakes-as-a-sysadmin/46800

**Description**

Jun 2024 thread on using flakes in a sysadmin context — including a "minimal config flake" pattern that behaves like cloud-init. Useful for homelabbers who want flakes without committing to a giant monorepo.

**Tags**

`#sysadmin` `#minimal-flake` `#patterns`

---

#### Discourse — Home Manager and Nixpkgs Version Mismatch

**Website**

https://discourse.nixos.org/t/home-manager-and-nixpkgs-version-mismatch/60331

**Description**

Feb 2025 thread explaining the root cause of the most common home-manager warning — when your `home-manager` flake input doesn't pin a branch, it defaults to `master` and drifts out of sync with your nixpkgs release. Concrete fix included.

**Tags**

`#home-manager` `#troubleshooting` `#version-mismatch`

---

#### Discourse — GitHub Actions and/or with Hercules CI

**Website**

https://discourse.nixos.org/t/github-actions-and-or-with-hercules-ci/13537

**Description**

Jun 2021 thread on choosing between GitHub Actions and Hercules CI for Nix projects. Covers the trade-offs (Hercules understands flake outputs natively; GHA needs `cachix/install-nix-action` and manual caching). Still relevant in 2025.

**Tags**

`#ci` `#hercules-ci` `#github-actions`

---

### 44. GitHub Discussions & Issues

These are landmark GitHub issues and discussions — the threads that shaped or continue to shape NixOS, nixpkgs, home-manager, and flakes.

#### Misterio77/nix-starter-configs — Issue #86 (Project Status)

**Website**

https://github.com/Misterio77/nix-starter-configs/issues/86

**Description**

Sep 2024 issue where the maintainer explains the project's intentionally-limited scope ("basically a gist to share a sane config") and why it isn't trying to compete with `flake-parts`/`snowfall`/etc. Read before assuming the starter-config will grow features you need.

**Tags**

`#starter-config` `#scope` `#governance`

---

#### nix-community/home-manager — Issue #1698 (Accessing flakes from inside home-manager modules)

**Website**

https://github.com/nix-community/home-manager/issues/1698

**Description**

Jan 2021 issue on passing the `flake` argument into home-manager modules — a frequently-asked question for anyone trying to reference their flake's outputs from inside a home-manager module. Contains the canonical workaround pattern.

**Tags**

`#home-manager` `#flakes` `#patterns`

---

#### nix-community/home-manager — Issue #2033 (News cannot be read when using flakes only)

**Website**

https://github.com/nix-community/home-manager/issues/2033

**Description**

May 2021 issue on the `home-manager switch` "news" feature breaking under flakes-only setups. Explains why the standalone `home-manager switch` command is intended for non-NixOS use and why NixOS users should use `nixos-rebuild switch` instead.

**Tags**

`#home-manager` `#flakes` `#troubleshooting`

---

#### nix-community/home-manager — Issue #5682 (Standalone Setup w/ Flakes instructions do not work)

**Website**

https://github.com/nix-community/home-manager/issues/5682

**Description**

Jul 2024 bug report on the standalone flakes install path — captures the common pitfalls (version mismatch, missing `nixpkgs` input). Useful as a known-issues reference when documenting an onboarding flow.

**Tags**

`#home-manager` `#standalone` `#known-issues`

---

#### nix-community/home-manager — Discussion #7454 (Home-manager and Flake usage)

**Website**

https://github.com/nix-community/home-manager/discussions/7454

**Description**

Nov 2021 (still-active) discussion clarifying the relationship between `home-manager switch` and `nixos-rebuild switch` under flakes. The single clearest explanation of "when you're on NixOS, just use `nixos-rebuild switch`."

**Tags**

`#home-manager` `#flakes` `#clarification`

---

#### NixOS/ofborg — Issue #68 (Provide a binary cache for builds)

**Website**

https://github.com/NixOS/ofborg/issues/68

**Description**

Feb 2018 historical issue on providing a binary cache for ofborg-built packages. Essential context for understanding how nixpkgs CI caching evolved into today's `cache.nixos.org` and why community caches (Cachix, numtide) emerged.

**Tags**

`#ofborg` `#binary-cache` `#history`

---

#### hercules-ci/hercules-ci-enterprise

**Website**

https://github.com/hercules-ci/hercules-ci-enterprise

**Description**

Repo for Hercules CI Enterprise — the README walks through integrating the agent into a NixOS deployment via the generated `hercules-config` directory. Useful reference for "how does a CI vendor ship a NixOS module?"

**Tags**

`#hercules-ci` `#enterprise` `#module`

---

#### NixOS/nixpkgs — Issue: nixpkgs #92900 / "Module type merging" reference discussions

**Website**

https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+module+system+types

**Description**

The nixpkgs issue tracker filtered for module-system type discussions — the source of truth for "why does my `mkForce` not work the way I expect?" and other module-system edge cases. Reference when a module override silently fails.

**Tags**

`#nixpkgs` `#module-system` `#types`

---

#### NixOS/nix — Issue: Flakes stabilization tracking

**Website**

https://github.com/NixOS/nix/issues?q=flakes+stabilization

**Description**

The Nix (C++) issue tracker filtered for flakes stabilization issues — the source of truth for "are flakes stable yet?" and the long tail of `nix flake` subcommand breakage. Pair with the Discourse "incremental strategy" thread above.

**Tags**

`#nix` `#flakes` `#stabilization`

---

#### DeterminateSystems/flake-schemas

**Website**

https://github.com/DeterminateSystems/flake-schemas

**Description**

Repo for the `flake-schemas` extension that allows custom flake output types — announced Mar 2026. Directly relevant to anyone who has hit the "flakes only know about a fixed set of outputs" limitation. Includes worked examples in the README.

**Tags**

`#flake-schemas` `#flakes` `#determinate-systems`

---

#### nix-community/archived-nixpkgs-wayland (and the modern flake-based successors)

**Website**

https://github.com/nix-community

**Description**

The `nix-community` org hosts dozens of canonical NixOS-adjacent projects (`home-manager`, `sops-nix`, `srvos`, `disko`, `nixos-anywhere`, `nix-index-database`, `nixvim`, `emacs-overlay`, etc.). Browse the org list when you need a tool — almost everything NixOS-related that isn't in nixpkgs lives here.

**Tags**

`#nix-community` `#ecosystem` `#discovery`


---

## Part XIII — Talks, Video, Audio & Miscellaneous

### 45. Conference Talks

NixCon is the annual NixOS community conference (run by the NixOS Foundation
since 2015). Most talks end up on YouTube on the `NixOS` channel (formerly the
"NixOS Foundation" channel, ID `UC3vIimi9q4AT8EgxYp_dWIw`). FOSDEM in Brussels
also hosts a recurring Nix devroom, and the Summer of Nix program streams its
"Developer Dialogues" and "Full Exposure" mob-programming sessions. The talks
below are the most-cited entry points for someone learning NixOS at depth.

#### NixOS YouTube Channel (NixOS Foundation)

**Website**

https://www.youtube.com/@NixOS-Foundation

**Description**

The official NixOS Foundation YouTube channel. Hosts every NixCon since 2015,
the Summer of Nix lecture series, and the "Nix Developer Dialogues" interviews
with maintainers. Subscribe here for the canonical recordings — third-party
uploads tend to drift out of date. The channel ID is
`UC3vIimi9q4AT8EgxYp_dWIw`.

**Tags**

`#nixcon` `#youtube-channel` `#official`

---

#### NixCon YouTube Channel

**Website**

https://www.youtube.com/c/NixCon

**Description**

A secondary community-managed NixCon channel that aggregates speaker uploads
and cross-posted recordings. Useful as a fallback when a particular talk is
missing from the official NixOS Foundation channel, but the Foundation channel
should be your primary source.

**Tags**

`#nixcon` `#youtube-channel` `#community`

---

#### NixCon 2024 — Day 1 Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RdGTyMCEgESdrs2LP01FbZn

**Description**

Day-1 playlist for NixCon 2024 (Berlin). Includes the "State of the Union
2024" talk and the "NixOS Facter — Declarative Hardware Configuration" talk
that introduces `nixos-facter` as the replacement for hand-written
`hardware-configuration.nix`. Start here for the latest architectural
direction.

**Tags**

`#nixcon2024` `#playlist` `#state-of-the-union`

---

#### NixCon 2024 — Day 2 Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rc9qCrtgXQ8cGyQYgK6tj5o

**Description**

Day-2 talks from NixCon 2024 in Berlin. Includes deeper-dives into
`nixpkgs-cache`, flakehub, and the Nixpkgs Architecture team's plans.

**Tags**

`#nixcon2024` `#playlist` `#architecture`

---

#### NixCon 2023 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rc0K-uSeSTCtgIIqSRcY4O6

**Description**

Recordings of NixCon 2023 (Darmstadt). Includes the famous "Nix State of the
Union 2023" by Jon Ringer and the rowdy closing panel on Nix governance. The
governance talks from this conference directly seeded the formation of the
NixOS Architecture team.

**Tags**

`#nixcon2023` `#playlist` `#governance`

---

#### NixCon 2022 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rf3Lor1Nic3G_NfQUj6Nso7

**Description**

NixCon 2022 (online + Prague). Notable for the first public "Nixpkgs
Architecture" presentation and the early flake adoption talks. Many flake
patterns used in modern dotfiles repos were popularised here.

**Tags**

`#nixcon2022` `#playlist` `#flakes`

---

#### NixCon 2019 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rf3Lor1Nic3G_NfQUj6Nso1

**Description**

NixCon 2019 (Brno). Eelco Dolstra's keynote on the Nix 3.0 roadmap and the
introduction of flakes are the standout talks. Many of these talks are still
cited as the canonical explanation of why flakes were needed.

**Tags**

`#nixcon2019` `#playlist` `#eelco-dolstra`

---

#### NixCon 2018 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RcEL2f7wYXr9B6l1i5Vz0M_

**Description**

NixCon 2018 (Munich). Heavy focus on early deployment tooling (NixOps,
disnix) and reproducible builds for HPC. Useful historical context for
understanding why the modern deploy ecosystem looks the way it does.

**Tags**

`#nixcon2018` `#playlist` `#history`

---

#### NixCon 2017 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RcyBSg91FQrpdfYg2p6HYjR

**Description**

NixCon 2017 (Munich). Graham Christensen's "NixOps for fun and profit" and
Eelco's talk on the binary cache architecture are still referenced today.

**Tags**

`#nixcon2017` `#playlist` `#history`

---

#### NixCon 2015 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RczJCi4tFK4FYFqKZ4azZDl

**Description**

The first NixCon (Berlin, 2015). Eelco Dolstra's original keynote on the
state of Nix is a must-watch for understanding the project's original vision.

**Tags**

`#nixcon2015` `#playlist` `#origin`

---

#### media.nixos.org — NixOS Foundation Media Archive

**Website**

https://media.nixos.org/

**Description**

The NixOS Foundation's self-hosted media archive with downloadable talk
videos (WebM/MP4) for offline viewing, no YouTube required. Particularly
useful for archive-of-record purposes; mirrors most NixCon talks.

**Tags**

`#media-archive` `#downloads` `#self-hosted`

---

#### FOSDEM 2024 — Nix and NixOS Devroom

**Website**

https://archive.fosdem.org/2024/schedule/track/nix-devroom/

**Description**

The FOSDEM 2024 Nix devroom schedule (Sunday 4 February 2024, Brussels).
Includes "Units of composition" by Tom Bereknyei, "Fortifying the
Foundations: Elevating Security in Nix", and "Preparing a 30-year-long
project with Nix and NixOS". Each event page has the video download and
slides.

**Tags**

`#fosdem` `#fosdem2024` `#devroom`

---

#### FOSDEM 2025 — Nix and NixOS Devroom

**Website**

https://archive.fosdem.org/2025/schedule/track/nix-devroom/

**Description**

FOSDEM 2025 Nix devroom. Recordings on each event page; covers the
`nixos-facter` rollout, the Nixpkgs lib cleanup, and reproducible
homelab/infra talks.

**Tags**

`#fosdem` `#fosdem2025` `#devroom`

---

#### Summer of Nix 2024 — Full Exposure

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rf3Lor1Nic3G_NfQUj6NsQ8

**Description**

The Summer of Nix 2024 "Full Exposure" playlist — live mob-programming
sessions in which Nix developers packaged and reviewed upstream open-source
projects together. Invaluable for watching real, unedited Nixpkgs
contribution workflow.

**Tags**

`#summer-of-nix` `#playlist` `#contributing`

---

#### Summer of Nix 2023 — Nix Developer Dialogues

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89Rc5q-ezdf9GqY4OQYqNYNQg

**Description**

Long-form interviews (1h+) with Nix maintainers from SoN 2023, including Rok
Garbas ("The NixOS hype and where to go from here"), Sylvain Henry, and
Andreas Rammhold. Great context on the human side of the project.

**Tags**

`#summer-of-nix` `#interviews` `#maintainers`

---

#### Summer of Nix 2022 — Public Lecture Series

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89ReU2LqgH4jKsDuHojvMz5nX

**Description**

The original 2022 public lecture series — 15+ lectures introducing Nix,
flakes, Nixpkgs internals, and NixOS module system, taught by SoN mentors.
Still one of the best free curricula for going from "I installed NixOS" to
"I can read nixpkgs source".

**Tags**

`#summer-of-nix` `#lectures` `#curriculum`

---

#### Nix 20th — NixOS Foundation Community Board Panel

**Website**

https://www.youtube.com/watch?v=yXPQdZh8o7c

**Description**

Recorded panel from the Nix 20th-anniversary celebration (2023) with the
NixOS Foundation board. Discusses governance reform, sponsorship, and the
post-modularisation roadmap. Watch to understand the current political
shape of the project.

**Tags**

`#nix20` `#governance` `#foundation`

---

#### Eelco Dolstra — NixOS Foundations (NixCon 2015 Keynote)

**Website**

https://www.youtube.com/watch?v=4aqvZUyokPg

**Description**

Eelco Dolstra's original NixCon keynote laying out the NixOS mission and
long-term plans. The "why" behind the pure-functional package manager
design, in his own words.

**Tags**

`#eelco-dolstra` `#keynote` `#history`

---

#### Graham Christensen — grahamc's Nix Talks

**Website**

https://www.youtube.com/watch?v=jQj8AoF4BN0

**Description**

Graham Christensen ("grahamc") is one of the most-cited NixOps and
infrastructure speakers. This is his canonical NixCon talk on NixOps and
deployment; also see his "Building a Nix Store" series on his personal
channel. Worth watching for anyone running more than one NixOS host.

**Tags**

`#grahamc` `#nixops` `#deployment`

---

#### Mic92 — Nixpkgs Internals Talk

**Website**

https://www.youtube.com/watch?v=fvT7o3aGFBw

**Description**

Jörg Thalheim (Mic92) walks through Nixpkgs internals, overlays, and
contributing workflow. Mic92 maintains a large fraction of the
`nix-community` tooling (`nix-diff-rs`, `nix-fast-build`, `nixos-anywhere`),
so his talks map directly to those tools.

**Tags**

`#mic92` `#nixpkgs` `#contributing`

---

#### etu — NixOS Modules Talk

**Website**

https://www.youtube.com/watch?v=mCTqXqgP3EY

**Description**

Elis Hirwing ("etu") on the NixOS module system, options, and how to write
your own modules without melting your brain. etu wrote much of the
infrastructure for the `nixpkgs` module system documentation.

**Tags**

`#etu` `#modules` `#options`

---

#### infinisil — Module System Improvements (NixCon 2019)

**Website**

https://www.youtube.com/watch?v=Rn2Ija5MxH0

**Description**

Silvan Mosberger ("infinisil") on the NixOS module system improvements —
the `mkRenamedOptionModule`, `mkRemovedOptionModule`, and submodule
machinery that every NixOS contributor eventually has to learn. infinisil
is the long-time maintainer of the module system docs.

**Tags**

`#infinisil` `#modules` `#nixcon2019`

---

#### adisbladis — Python & Poetry2nix in Nixpkgs

**Website**

https://www.youtube.com/watch?v=8XFTgzjop1I

**Description**

Adam Höse ("adisbladis") on packaging Python with Nix and the
`poetry2nix`/`dream2nix` workflows. adisbladis drives much of the
language-ecosystem packaging effort in nixpkgs; this talk is the canonical
introduction to reproducible Python dev shells.

**Tags**

`#adisbladis` `#python` `#poetry2nix`

---

#### NixCon NA 2024 — Playlist

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RdUYxmn7Y4Uv74sE3lVRhRS

**Description**

NixCon North America 2024 recordings — the second iteration of the North
American NixCon. Hosts talks by Determinate Systems staff on flakehub, the
nix installer, and enterprise Nix.

**Tags**

`#nixcon-na` `#playlist` `#determinate`

---

### 46. YouTube Channels

These channels produce NixOS-first or NixOS-heavy content on a regular
cadence. None are official Foundation channels, but several (Vim Joyer, Jon
Xue) are now the de facto entry point for new users.

#### Jon Xue — NixOS Tutorials

**Website**

https://www.youtube.com/@jonxue

**Description**

Jon Xue produces detailed walkthroughs of NixOS installation, declarative
partitioning with disko, and home-manager setups aimed at people who want
their homelab fully reproducible. Production quality is high and configs are
linked in each video description.

**Tags**

`#youtube-channel` `#tutorials` `#disko`

---

#### Vera / menno — dotfiles & NixOS

**Website**

https://www.youtube.com/@mennovandijk

**Description**

Menno van Dijk ("Vera"/"menno") publishes NixOS dotfile tours and
configuration walkthroughs oriented toward the home-lab and Linux-rice
communities. Often pairs configs with his GitHub dotfiles repo so viewers
can copy.

**Tags**

`#youtube-channel` `#dotfiles` `#homelab`

---

#### LibreLaptop

**Website**

https://www.youtube.com/@LibreLaptop

**Description**

LibreLaptop covers NixOS laptop setup, power management, GPU switching, and
desktop-environment configuration (Hyprland, Sway, KDE). Particularly
useful for the laptop half of a homelab-plus-laptop workflow.

**Tags**

`#youtube-channel` `#laptop` `#desktop`

---

#### Sysall

**Website**

https://www.youtube.com/@Sysall

**Description**

Sysall produces French-language NixOS and DevOps content — one of the most
active non-English NixOS channels. Useful if you prefer French or want to
recommend content to French-speaking colleagues.

**Tags**

`#youtube-channel` `#french` `#devops`

---

#### Chris Titus Tech — NixOS Episodes

**Website**

https://www.youtube.com/@christitustech

**Description**

Chris Titus Tech produces opinionated infrastructure videos; search the
channel for "NixOS" to surface his install walkthroughs, his NixOS-vs-TrueNAS-Scale
comparison, and his "NixOS first impressions" episodes. Useful for
perspective from a non-NixOS-native sysadmin.

**Tags**

`#youtube-channel` `#sysadmin` `#comparison`

---

#### NetworkChuck — Nix episodes

**Website**

https://www.youtube.com/@NetworkChuck

**Description**

NetworkChuck has featured NixOS in his "Linux for hackers" series. Short,
high-production-value introductions that are good for getting junior
colleagues curious about declarative systems.

**Tags**

`#youtube-channel` `#intro` `#beginner`

---

#### Brodie Robertson — NixOS Coverage

**Website**

https://www.youtube.com/@BrodieRobertson

**Description**

Brodie Robertson regularly covers NixOS news, releases, and his own
config in his "Tech Over Tea" podcast and main channel. Good for
steady-state awareness of what's happening in the NixOS world.

**Tags**

`#youtube-channel` `#news` `#opinion`

---

#### The Linux Experiment

**Website**

https://www.youtube.com/@TheLinuxExperiment

**Description**

Nick from The Linux Experiment has done several "I tried NixOS for a month"
videos that are useful to share with Windows/macOS users considering a
switch. Lighter on technical depth, heavier on UX impressions.

**Tags**

`#youtube-channel` `#review` `#opinion`

---

#### Configuring

**Website**

https://www.youtube.com/@configuring

**Description**

Smaller NixOS-focused channel with longer-form (1h+) configuration
walkthroughs covering real-world services (Nextcloud, Jellyfin, Traefik)
on NixOS. Good companion to the more beginner-oriented Vim Joyer content.

**Tags**

`#youtube-channel` `#walkthroughs` `#services`

---

#### Misterio

**Website**

https://www.youtube.com/@Misterio77

**Description**

Gabriel Fontes ("Misterio77") maintains a widely-forked NixOS dotfiles
repo and the `stylix` NixOS module; his channel has occasional deep-dive
videos on his configuration choices. Pair with his GitHub repo
`misterio77/nix-config`.

**Tags**

`#youtube-channel` `#dotfiles` `#stylix`

---

### 47. YouTube Playlists & Specific Videos

Specific playlists and single-video tutorials worth bookmarking. These are
the most-referenced "I'm trying to do X, send me a link" videos in the
NixOS community.

#### NixOS Beginner Tutorials Miniseries — Vim Joyer

**Website**

https://www.youtube.com/playlist?list=PLko9chwSoP-3MLKgbuwh3n_x3HVzoZujp

**Description**

Vim Joyer's four-video miniseries: NixOS Explained, NixOS Installation,
NixOS Configuration, and NixOS Updating (Flakes & Channels). The single
best starting point for someone who just installed NixOS and wants to
understand what they're doing.

**Tags**

`#playlist` `#beginner` `#vimjoyer`

---

#### Vim Joyer — NixOS Configuration Series

**Website**

https://www.youtube.com/playlist?list=PLa01scHy0YEmg8trm421aYq4OtPD8u1SN

**Description**

The longer-form NixOS configuration playlist (31 videos) that predates the
miniseries above. Covers home-manager, sops-nix, secrets, custom packages,
and dev-shells in depth.

**Tags**

`#playlist` `#vimjoyer` `#home-manager`

---

#### Nix Flakes — Introduction (Eelco Dolstra)

**Website**

https://www.youtube.com/watch?v=UeBX7Ide5a0

**Description**

Eelco Dolstra's canonical introduction to flakes from NixCon 2019 — the
"why flakes exist" talk. Still the recommended first video to watch before
diving into the flakes manual.

**Tags**

`#flakes` `#eelco-dolstra` `#intro`

---

#### Home Manager — A Tutorial (Vim Joyer)

**Website**

https://www.youtube.com/watch?v=Fc462kOyZfI

**Description**

Vim Joyer's standalone home-manager tutorial. Walks through installation,
the `home.nix` file, modules, and integrating home-manager into a NixOS
flake. Pair with the home-manager manual.

**Tags**

`#home-manager` `#tutorial` `#vimjoyer`

---

#### nixos-anywhere — Demo (Mic92 / Numtide)

**Website**

https://www.youtube.com/watch?v=qOrQOrUATwM

**Description**

Walkthrough of `nixos-anywhere` for provisioning bare-metal hosts over SSH
from a NixOS configuration flake. Demonstrates the disko + nixos-anywhere
combo that's now the de facto standard for non-cloud provisioning.

**Tags**

`#nixos-anywhere` `#provisioning` `#disko`

---

#### disko — Declarative Disk Partitioning

**Website**

https://www.youtube.com/watch?v=NqIn5byJ0oI

**Description**

Introduction to `disko` — the declarative partitioning tool used with
`nixos-anywhere`. Shows how to define `disko.devices` in your NixOS config
and reproduce identical disk layouts across hosts.

**Tags**

`#disko` `#partitioning` `#tutorial`

---

#### snowfall-lib — Walkthrough

**Website**

https://www.youtube.com/watch?v=eiHMyNUjjbc

**Description**

Demonstration of `snowfall-lib` for organising a multi-host NixOS flake
with an opinionated directory structure. Useful to watch before committing
to snowfall vs. a hand-rolled flake.

**Tags**

`#snowfall-lib` `#flakes` `#tutorial`

---

#### Zero to Nix — Determinate Systems

**Website**

https://www.youtube.com/playlist?list=PLyzwHTVJlrcOjtFntGbAh1G9G4O3fGO5N

**Description**

Playlist companion to the `zero-to-nix.com` learning site by Determinate
Systems — the modern, opinionated starter curriculum for Nix and NixOS,
using the Determinate Nix Installer.

**Tags**

`#zero-to-nix` `#determinate` `#curriculum`

---

#### NixOS-Anywhere + disko — Install from Scratch (Jon Xue)

**Website**

https://www.youtube.com/watch?v=jUXX0Y8Pe9E

**Description**

Jon Xue's end-to-end walkthrough: write a flake, define disko disks, boot
a live ISO, then run `nixos-anywhere` to install on a real machine. The
fastest reproducible install path for a homelab.

**Tags**

`#nixos-anywhere` `#disko` `#install`

---

#### Impermanence / Ephemeral Root on NixOS (Vim Joyer)

**Website**

https://www.youtube.com/watch?v=3Kj5UWaeNYo

**Description**

Vim Joyer's walkthrough of `impermanence` — making NixOS root filesystems
ephemeral with only `/persist` surviving reboots. Pairs well with btrfs/ZFS
snapshots for a truly reproducible homelab.

**Tags**

`#impermanence` `#ephemeral` `#vimjoyer`

---

#### Sops-nix — Secrets Management on NixOS

**Website**

https://www.youtube.com/watch?v=G5f6GC-fXf4

**Description**

Tutorial on `sops-nix` for managing secrets in a NixOS flake using
SOPS + age/PGP. The most-recommended approach for keeping secrets out of
the world-readable Nix store.

**Tags**

`#sops-nix` `#secrets` `#tutorial`

---

#### Nixpkgs Architecture Team — Office Hours

**Website**

https://www.youtube.com/playlist?list=PLgknCdxP89RckO5k1bI7tYzD9Kga-aE6R

**Description**

Public office-hours streams run by the Nixpkgs Architecture team. Watch
these to understand the current RFC pipeline, lib refactors, and module
system direction — direct insight into what's coming in the next release.

**Tags**

`#architecture-team` `#office-hours` `#live`

---

#### Pragmatic Nix —天天 Playlist

**Website**

https://www.youtube.com/playlist?list=PLaz9K-h4TgP6lMjBlpTtgib4Xtw5qK-OK

**Description**

A community-curated "Pragmatic Nix" playlist of single-topic talks and
tutorials that bridge the gap between NixOS module documentation and
real-world deployment. Good for picking up patterns rather than syntax.

**Tags**

`#playlist` `#patterns` `#pragmatic`

---

### 48. Podcasts

Podcasts that regularly cover NixOS — useful for keeping up with the
ecosystem during commutes or while doing chores.

#### Self-Hosted (Jupiter Broadcasting) — NixOS episodes

**Website**

https://selfhosted.show/tags/nixos

**Description**

Chris Fisher and Alex Kretzschmar's self-hosting podcast on Jupiter
Broadcasting. Tag page filters every NixOS-mentioning episode. Episode 102
("NixOS is a bit Flakey") is the canonical listen for first impressions
from experienced self-hosters.

**Tags**

`#podcast` `#self-hosting` `#jupiter-broadcasting`

---

#### Self-Hosted 102 — NixOS is a bit Flakey

**Website**

https://www.jupiterbroadcasting.com/show/self-hosted/102

**Description**

The specific NixOS-flakes episode of Self-Hosted, July 2023. Chris &
Alex's first real flake deep-dive — what worked, what didn't, and the
Jellyfin config that broke. Useful as a reference point for "what was the
state of NixOS in mid-2023".

**Tags**

`#podcast-episode` `#flakes` `#jupiter-broadcasting`

---

#### Linux Unplugged — NixOS episodes

**Website**

https://linuxunplugged.com/tags/nixos%20configs

**Description**

Jupiter Broadcasting's weekly Linux talk show; the "nixos configs" tag
surface every episode where NixOS configs are discussed. Frequently
features NixOS community members as guests.

**Tags**

`#podcast` `#linux-unplugged` `#jupiter-broadcasting`

---

#### Choose Linux — Nix episodes

**Website**

https://chooselinux.com/

**Description**

Choose Linux (Joe Ressington, formerly of Linux Lurkers / Late Night
Linux crew) has covered NixOS multiple times. Shorter, opinionated
format; good for a quick "should I bother?" gut check.

**Tags**

`#podcast` `#opinion` `#short-form`

---

#### Linux Matters — Nix episodes

**Website**

https://linuxmatters.sh/

**Description**

Linux Matters (UK-based Linux podcast from the Late Night Linux family)
has run several NixOS segments. Search the show notes for "nix" — they
tend to cover NixOS at release time and discuss practical adoption.

**Tags**

`#podcast` `#late-night-linux` `#uk`

---

#### Ubuntu Podcast — Nix episodes

**Website**

https://ubuntupodcast.org/

**Description**

The long-running Ubuntu Podcast (UK) frequently mentions NixOS in its
"updates" segments. Useful if you want a non-NixOS-native Linux podcast's
perspective on NixOS releases.

**Tags**

`#podcast` `#ubuntu` `#uk`

---

#### Hacker Public Radio — NixOS episodes

**Website**

https://hackerpublicradio.org/search.php?query=nixos

**Description**

Hacker Public Radio is a community podcast where anyone can upload an
episode. Search the archive for "nixos" to surface community-contributed
shows — ranging from 5-minute tips to 30-minute install walk-throughs.

**Tags**

`#podcast` `#community` `#open`

---

#### The IT Guy Show — NixOS episode

**Website**

https://podcast.itguyeric.com/11

**Description**

Episode 11 of "The IT Guy Show" with Eric and Aaron Honeycutt
demystifying NixOS for sysadmins. Approachable framing for someone coming
from a Windows/Ubuntu sysadmin background.

**Tags**

`#podcast-episode` `#sysadmin` `#intro`

---

#### Late Night Linux — NixOS episodes

**Website**

https://latenightlinux.com/

**Description**

Late Night Linux and its family of shows (LNL, Inginuit, Linux Downtime)
have periodically covered NixOS releases and Nix flakes. Show notes are
searchable; catch up by filtering for "nix" across the family feed.

**Tags**

`#podcast` `#late-night-linux` `#news`

---

#### Tech Over Tea — NixOS Introduction (Brodie Robertson)

**Website**

https://www.youtube.com/watch?v=_7FhMlmwwAs

**Description**

Brodie Robertson's "Tech Over Tea" podcast episode #268 covering NixOS
introduction; referenced from the official NixOS Discourse. Useful as a
podcast-form intro from a non-NixOS-native Linux YouTuber.

**Tags**

`#podcast-episode` `#intro` `#brodie-robertson`

---

### 49. Miscellaneous Resources

The catch-all for newsletters, community trackers, Nix CLI utilities,
funding, and meta-tooling that doesn't fit elsewhere. Several of these
tools (`nvd`, `nix-tree`, `nom`, `comma`, `manix`) are the first things an
experienced NixOS user installs on a fresh box.

#### Nixpkgs News (Weekly Recap)

**Website**

https://nixpkgs.news/

**Description**

A community-run weekly recap (started March 2024) summarising new
packages, security fixes, and Nixpkgs changes by GitHub user. Complementary
to the official NixOS Weekly — this one is more data-dense and less
narrative.

**Tags**

`#newsletter` `#community` `#weekly`

---

#### NixOS Status Page

**Website**

https://status.nixos.org/

**Description**

Real-time status for NixOS infrastructure: `cache.nixos.org`,
`search.nixos.org`, `cache.nixos.org` S3 availability, hydra builds, and
the GitHub Actions CI runners. Bookmark this whenever a `nixos-rebuild`
suddenly hangs on substitution.

**Tags**

`#status` `#infrastructure` `#monitoring`

---

#### tracker.nixos.org

**Website**

https://tracker.nixos.org/

**Description**

The Nixpkgs issue/PR tracker — a faster, cleaner view of the open GitHub
issues and PRs across `NixOS/nixpkgs` and related repos. Useful for
finding "is anyone else hitting this bug?" before filing a duplicate.

**Tags**

`#tracker` `#issues` `#prs`

---

#### Repology — NixOS package list

**Website**

https://repology.org/repository/nix_unstable

**Description**

Repology's view of the `nix_unstable` channel — compares package versions
in Nixpkgs against every other Linux distribution. Use it to check whether
a Nixpkgs package is ahead of, behind, or in sync with Arch/Debian/Fedora
before deciding whether to upgrade via overlay.

**Tags**

`#repology` `#packages` `#comparison`

---

#### r13y — Reproducibility Tracker

**Website**

https://r13y.com/

**Description**

Tracks which NixOS configurations are bit-for-bit reproducible across
machines and which are not. Maintained by the Reproducible Builds effort;
important context if you care about supply-chain integrity for your
homelab.

**Tags**

`#reproducible-builds` `#supply-chain` `#tracker`

---

#### nvd — Nix/NixOS version diff tool

**Website**

https://git.sr.ht/~khumba/nvd

**Description**

`nvd` diffs the package closures of two NixOS generations (or any two
store paths) and prints what changed, with highlighting for packages in
`environment.systemPackages`. The fastest way to answer "what did that
`nixos-rebuild switch` actually change?".

**Tags**

`#nvd` `#diff` `#generations`

---

#### nix-diff

**Website**

https://github.com/Gabriella439/nix-diff

**Description**

Gabriella Gonzalez's `nix-diff` explains why two Nix *derivations* differ —
deeper than `nvd`, which compares *closures*. Useful when debugging why a
rebuild of an identical-looking config produces a different store path.

**Tags**

`#nix-diff` `#derivations` `#debugging`

---

#### nix-diff-rs (Rust port)

**Website**

https://github.com/Mic92/nix-diff-rs

**Description**

Mic92's Rust port of `nix-diff` — significantly faster on large
derivations. Drop-in replacement for the Haskell original; use this on
big Nixpkgs evaluations where the Haskell version OOMs.

**Tags**

`#nix-diff-rs` `#rust` `#mic92`

---

#### nix-tree

**Website**

https://github.com/utdemir/nix-tree

**Description**

`nix-tree` is an interactive TUI for exploring the dependency tree of a
Nix derivation — why does this package pull in 4 GB of stuff? Use
`nix-tree $(which firefox)` to find out. One of the most beloved quality-of-
life tools in the ecosystem.

**Tags**

`#nix-tree` `#tui` `#dependencies`

---

#### nix-melt

**Website**

https://github.com/nix-community/nix-melt

**Description**

`nix-melt` is an interactive TUI for inspecting and exploring the Nix flake
lockfile (`flake.lock`) — visualise which inputs depend on which, what's
out of date, and what an `nix flake update` would change. A must-have for
flake-heavy homelabs.

**Tags**

`#nix-melt` `#tui` `#flake-lock`

---

#### manix

**Website**

https://github.com/mlopsencountered/manix

**Description**

`manix` is a CLI for searching NixOS and Home-Manager option documentation
offline. `manix services.nginx` returns every option matching that string
from your locally-evaluated Nixpkgs tree — far faster than
search.nixos.org in a flake-pinned setup.

**Tags**

`#manix` `#options` `#offline-search`

---

#### fh — FlakeHub CLI

**Website**

https://flakehub.com/flake/DeterminateSystems/fh

**Description**

`fh` is the official CLI for FlakeHub (Determinate Systems' flake
registry). Use `fh init`, `fh add`, `fh search`, and `fh resolve` to
manage flake inputs without hand-editing `flake.nix`. Docs at
`docs.determinate.systems/flakehub/cli`.

**Tags**

`#fh` `#flakehub` `#determinate`

---

#### snowfall-lib

**Website**

https://github.com/snowfallorg/lib

**Description**

`snowfall-lib` is an opinionated flake wrapper that auto-generates your
flake outputs (systems, packages, modules, shells, templates) from a
convention-over-configuration directory structure. Documentation at
`snowfall.org/guides/lib/quickstart`. A solid choice if your dotfiles repo
is getting unwieldy.

**Tags**

`#snowfall-lib` `#flakes` `#framework`

---

#### Summer of Nix

**Website**

https://github.com/ngi-nix/summer-of-nix

**Description**

Summer of Nix is a paid, NLnet-funded, NixOS Foundation–organised summer
program (since 2021) in which students and early-career professionals package
NGI-funded open-source projects for NixOS. Watch the playlist above; apply
via this repo when applications open (typically Q1 each year).

**Tags**

`#summer-of-nix` `#funding` `#outreach`

---

#### NixOS Foundation

**Website**

https://nixos.org/community/teams/governance/foundation.html

**Description**

The NixOS Foundation is the non-profit legal entity (Stichting NixOS
Foundation, registered in the Netherlands) that owns the project's
infrastructure, trademarks, and funds. Read this page to understand the
governance reform (2023–2024) that produced the elected Architecture team
and the moderation team.

**Tags**

`#foundation` `#governance` `#non-profit`

---

#### NixOS OpenCollective

**Website**

https://opencollective.com/nixos

**Description**

The NixOS Foundation's OpenCollective — the primary transparent donation
point for individuals and small companies. Funds infrastructure (hydra,
cache.nixos.org bandwidth) and outreach (Summer of Nix).

**Tags**

`#opencollective` `#donation` `#funding`

---

#### GitHub Sponsors — NixOS Foundation

**Website**

https://github.com/sponsors/NixOS

**Description**

The NixOS Foundation's GitHub Sponsors page — an alternative to
OpenCollective if you or your employer prefer GitHub-native billing. Both
flow into the same Foundation bank account.

**Tags**

`#github-sponsors` `#donation` `#funding`

---

#### NixOS Matrix / Discord / IRC — Community

**Website**

https://nixos.org/community/#chat

**Description**

The NixOS community chat directory: `#nix:nixos.org` (Matrix, bridged to
Libera.Chat `#nixos` and `#nixos-aarch64` IRC), the official Discord
server, and language-specific channels (French, German, Chinese,
Russian). The Matrix room is the most active; IRC is read-mostly.

**Tags**

`#matrix` `#discord` `#irc` `#community`

---

#### awesome-nix

**Website**

https://github.com/nix-community/awesome-nix

**Description**

The community-curated "awesome list" for the Nix ecosystem — every tool
mentioned in this batch (and hundreds more) is indexed here. Bookmark it
as a discovery tool when you need a Nix solution to a niche problem.

**Tags**

`#awesome-nix` `#curated-list` `#discovery`

---

#### Nixpkgs Architecture Team RFCs

**Website**

https://github.com/nixpkgs-architecture/rfccs

**Description**

The Nixpkgs Architecture team's RFC repository — every proposal that
shapes the future of Nixpkgs lands here. Watch this repo to comment on
RFCs during their open period before they're ratified.

**Tags**

`#rfc` `#architecture-team` `#governance`


---

## Part XIV — Books, Academic Papers & Awesome Lists

### 50. Books

Longer-form, narrative introductions to NixOS and Flakes. These complement
the official manuals by walking a single path from zero to working
configuration, which is often easier to follow than reference docs.

#### NixOS & Flakes Book — Source Repository

**Website**

https://github.com/ryan4yin/nixos-and-flakes-book

**Description**

The GitHub source for the NixOS & Flakes Book, built with VitePress. Also
links to the author's broader `nix-config` for desktops and home-lab
setups — a useful reference implementation for real-world NixOS
configurations.

**Tags**

`#community` `#github` `#book` `#source` `#flakes`

---

#### NixOS Book (Official, In Progress)

**Website**

https://github.com/NixOS/nix-book

**Description**

The official NixOS foundation's in-progress book project, intended to fit
between the marketing-style pages on nixos.org and the dense reference
manuals. Still early-stage as of 2024; worth tracking for when it becomes
the canonical long-form introduction.

**Tags**

`#official` `#book` `#in-progress` `#nixos` `#github`

---

#### Wombat's Book of Nix

**Website**

https://mhwombat.codeberg.page/nix-book

**Description**

A community book by "mhwombat" aimed at beginners, particularly those coming
from Haskell, using Nix to specify builds, system configuration, and
project-level tooling. A gentler alternative to the Nix Pills for readers who
prefer a narrative, example-driven style.

**Tags**

`#community` `#book` `#beginner` `#haskell` `#learning`

---

#### Practical NixOS: the Book (Drake Rossman)

**Website**

https://drakerossman.com/blog/practical-nixos-the-book

**Description**

An in-progress, free online book by Drake Rossman introducing NixOS and
guiding readers toward a reproducible workstation and development workflow.
Practical and opinionated; useful as a second opinion alongside the NixOS &
Flakes Book.

**Tags**

`#community` `#book` `#nixos` `#workstation` `#in-progress`

---

### 51. Academic Papers

Peer-reviewed and thesis-length treatments of the ideas underlying Nix and
NixOS. Reading at least Dolstra's PhD thesis and the JFP NixOS paper gives
the conceptual model that makes everything else click.

#### The Purely Functional Software Deployment Model (Dolstra PhD Thesis, PDF)

**Website**

https://edolstra.github.io/pubs/phd-thesis.pdf

**Description**

Eelco Dolstra's 2006 PhD thesis at Utrecht University — the foundational
document for Nix. It motivates and specifies the purely functional deployment
model, store hashes, atomic upgrades, rollbacks, and multi-version
coexistence. Cited by the Nix project's own `CITATION.cff`; essential reading
for understanding *why* Nix works the way it does.

**Tags**

`#academic` `#thesis` `#dolstra` `#foundational` `#pdf`

---

#### NixOS: A Purely Functional Linux Distribution (JFP, Preprint PDF)

**Website**

https://edolstra.github.io/pubs/nixos-jfp-final.pdf

**Description**

Dolstra, Löh, and Pierron's 2010 Journal of Functional Programming paper
describing NixOS itself: the module system, system configuration as a Nix
derivation, and the user-level implications (atomic upgrades, multi-user
package management). The canonical academic citation for NixOS.

**Tags**

`#academic` `#paper` `#jfp` `#dolstra` `#nixos`

---

#### NixOS: A Purely Functional Linux Distribution (Cambridge Core)

**Website**

https://www.cambridge.org/core/journals/journal-of-functional-programming/article/nixos-a-purely-functional-linux-distribution/C1ACBA2A51D2E5466820F5B5086EA2CE

**Description**

The publisher (Cambridge University Press) version of record for the JFP
NixOS paper. Use this URL when citing the paper academically; the preprint
PDF above is more convenient for casual reading.

**Tags**

`#academic` `#paper` `#jfp` `#cambridge` `#citation`

---

#### NixOS: A Purely Functional Linux Distribution (Andres Löh's Copy)

**Website**

https://www.andres-loeh.de/NixOS.pdf

**Description**

A long preprint version of the NixOS paper hosted by co-author Andres Löh,
which includes more detailed exposition of Nix language features and NixOS
internals than the JFP version of record. Useful when the journal version is
too terse.

**Tags**

`#academic` `#paper` `#preprint` `#nixos` `#loeh`

---

#### NixOS: A Purely Functional Linux Distribution (ACM Digital Library)

**Website**

https://dl.acm.org/doi/10.1145/1411204.1411255

**Description**

The ACM Digital Library entry for the original ICFP 2008 NixOS paper. An
alternative citation path for institutions with ACM access but not Cambridge
Core access.

**Tags**

`#academic` `#paper` `#acm` `#icfp` `#citation`

---

#### Does Functional Package Management Enable Reproducible Builds at Scale? Yes (MSR '25, Discourse Summary)

**Website**

https://discourse.nixos.org/t/research-article-does-functional-package-management-enable-reproducible-builds-at-scale-yes/59449

**Description**

A 2025 MSR conference paper (with Stefano Zacchiroli and Théo Zimmermann)
quantifying Nixpkgs reproducibility at ~91% as of 2023, up from 69% in 2017.
The Discourse thread is the accessible summary; useful evidence for homelab
users evaluating how much to trust Nix for reproducible deployments.

**Tags**

`#academic` `#paper` `#reproducibility` `#msr` `#empirical`

---

#### The Nix Thesis — Commentary by Jonathan Lorimer

**Website**

https://jonathanlorimer.dev/posts/nix-thesis.html

**Description**

A long-form, accessible commentary and chapter-by-chapter summary of Dolstra's
PhD thesis. A great companion read alongside the thesis PDF when the academic
prose gets heavy; helps extract the practical implications for modern Nix
users.

**Tags**

`#community` `#commentary` `#thesis` `#dolstra` `#summary`

---

### 52. Awesome Lists

Community-curated "awesome" lists that aggregate NixOS-related projects,
tools, modules, and learning resources. Useful for discovery once you know
what you are looking for but not which package implements it.

#### awesome-nixos (periklis)

**Website**

https://github.com/periklis/awesome-nixos

**Description**

An older, complementary awesome list focused specifically on NixOS, NixOps,
and Nixpkgs — collecting manuals, articles, slides, tutorials, and videos.
Predates and partially overlaps with `awesome-nix`; still useful for finding
legacy NixOps and deployment material not in the newer list.

**Tags**

`#community` `#awesome-list` `#nixos` `#nixops` `#curated`

---

#### awesome-flake-parts (wearetechnative)

**Website**

https://github.com/wearetechnative/awesome-flake-parts

**Description**

A curated list of resources, modules, and examples for `flake-parts` — the
hercules-ci framework for writing Nix flakes modularly. Indispensable if your
homelab flake has grown beyond a single `flake.nix` and you want to structure
it cleanly.

**Tags**

`#community` `#awesome-list` `#flake-parts` `#flakes` `#modules`

---

#### best-of-nix (tolkonepiu)

**Website**

https://github.com/tolkonepiu/best-of-nix

**Description**

A ranked, automatically-updated list of the best Nix-related open-source
projects with scores based on GitHub activity. A useful complement to
`awesome-nix` when you want a quick "what is most popular/active right now"
view across the ecosystem.

**Tags**

`#community` `#awesome-list` `#ranked` `#discovery` `#nix`

---


---

## About this document

This `References.md` was assembled by aggregating research across the official
NixOS documentation, the NixOS Discourse, GitHub repositories and discussions,
Reddit communities (`r/NixOS`, `r/Nix`, `r/selfhosted`, `r/homelab`), YouTube,
conference recordings (NixCon, FOSDEM), and personal blogs. Links were verified
via web search at compile time; the Nix ecosystem moves fast, so if you find a
link that has since rotted or a project that has been archived, please open a
PR.

**Tags index (most common):** `#nixos` `#flakes` `#homelab` `#deployment`
`#secrets` `#networking` `#containers` `#monitoring` `#home-manager`
`#self-hosted` `#development` `#ci-cd` `#learning` `#security`
`#community` `#examples`
