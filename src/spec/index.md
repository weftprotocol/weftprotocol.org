---
title: Specifications
description: Web-External Federated Threads. Markdown conversations on any URL, published as RSS 2.0 and connected with Webmention.
---

# Specifications

Weft is defined by two documents. The namespace says what goes in a feed; hosting says where feeds live. Neither adds new XML beyond the namespace's elements.

## Current

| Document                                           | Version | Status | Last changed |
|----------------------------------------------------|---------|--------|--------------|
| [Weft Namespace](namespace/0.1/index.md) | 0.1     | Draft  | Nov 9, 2026  |
| [Weft Hosting](hosting/0.1/index.md)     | 0.1     | Draft  | Nov 9, 2026  |

## Versioning

- Each version lives at its own URL forever, such as `/spec/namespace/0.1/`. Published versions are never rewritten; corrections go in a new version.
- While a version is a **draft**, it may change. Once **final**, its text is frozen.
- The namespace URI carries the version (`https://weftprotocol.org/ns/weft/0.1`). A breaking change gets a new URI; compatible additions keep it.

## History

- **Nov 9, 2026:** First working drafts of the Namespace and Hosting specifications, with the namespace URI `https://weftprotocol.org/ns/weft/0.1`.
