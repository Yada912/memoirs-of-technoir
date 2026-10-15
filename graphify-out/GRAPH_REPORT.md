# Graph Report - memoirs-of-technoir  (2026-10-15)

## Corpus Check
- 1 files · ~439,841 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 56 file(s) not represented in the graph (top: .uid 21, .gd 20, .tscn 6)

## Summary
- 23 nodes · 25 edges · 8 communities (0 shown, 8 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8cba71b2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- README.md

## God Nodes (most connected - your core abstractions)
1. `memoirs-of-technoir` - 1 edges

## Surprising Connections (you probably didn't know these)
- `Main` --instantiates--> `WorkstationScene`  [EXTRACTED]
   →   _Bridges community 1 → community 0_
- `PartNode` --triggers_sfx--> `AudioManager`  [EXTRACTED]
   →   _Bridges community 4 → community 0_
- `StoryReader2D` --reads_webtoon_panels--> `ChapterData`  [EXTRACTED]
   →   _Bridges community 3 → community 1_

## Communities (8 total, 8 thin omitted)

## Knowledge Gaps
- **1 isolated node(s):** `memoirs-of-technoir`
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 8 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `memoirs-of-technoir` to the rest of the system?**
  _1 weakly-connected nodes found - possible documentation gaps or missing edges._