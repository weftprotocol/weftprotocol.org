---
title: Weft Hosting 0.1
description: Web-External Federated Threads. Markdown conversations on any URL, published as RSS 2.0 and connected with Webmention.
---

# Weft Hosting Spec 0.1 (Draft)

**Weft: Web-External Federated Threads**

Oct 20, 2026 · revised Nov 9, 2026 · companion to [Weft Namespace 0.1](../../namespace/0.1/index.md)

## Status and purpose

The Weft Namespace defines what goes *in* a feed: posts, replies, likes, replies feeds, permalink pages and processing rules. This spec defines where those feeds *live*: how a person gets an address, how a host serves it, how a custom domain is set up and verified, and how a person moves from one host to another without breaking a single reply.

It adds no XML. Every format detail is the namespace's, referred to here as **\[NS\]**.

The reference host is **weftseed.com**: the first, but not the last. Anyone can run a host from the open-source code.

## Terms

| Term               | Meaning                                                                                                                    |
|--------------------|----------------------------------------------------------------------------------------------------------------------------|
| **Host**           | A server running Weft. Serves one or more people.                                                                          |
| **Handle**         | A person's hostname, e.g. `alice.weftseed.com` or `weft.alice.com`. Opening it in a browser shows their profile and posts. |
| **Default handle** | The handle a host issues on sign-up: `<name>.<host-domain>`.                                                               |
| **Custom handle**  | A handle on a domain the person controls.                                                                                  |

## 1. Handles

### 1.1 Why handles matter

In \[NS\], a post's address is its permalink, and replies, likes and Webmentions all point at permalinks. A permalink is `https://<handle>/posts/<slug>`. So **whoever controls the handle controls whether a person's posts keep their addresses.** A custom handle on the person's own domain is what makes their posts truly theirs.

### 1.2 Default handles

Every person gets `<name>.<host-domain>`, e.g. `alice.weftseed.com`. The host serves these with one wildcard DNS record and a TLS certificate for each name (a wildcard certificate, or one obtained on demand). Who may have an account, and how many, is the host's own policy and not part of the protocol: open sign-up, a waiting list, an invitation, a cap.

Default handles work immediately but belong to the host. Moving away from one changes the person's permalinks (see §5.3).

### 1.3 Custom handles

The recommended convention is **`weft.<their-domain>`**, e.g. `weft.alice.com`. It tells readers what lives there and lets apps discover it (§4). A host MAY accept any subdomain the person verifies (the reference server accepts any domain that is not its own), or fewer. The weftseed.com sign-up takes only `weft.` followed by the person's registered domain, such as `weft.example.com` or `weft.example.co.uk` and never `weft.blog.example.com`, with one account for each registered domain. Setup screens, docs and examples default to `weft.`.

Root domains (`alice.com`) are not supported as handles. DNS does not allow a CNAME on a root domain, and most root domains already host a website.

## 2. URL layout

Every host MUST serve a handle with this layout, so that an export from one host imports into another at identical URLs:

| Path                        | Serves                                                             | \[NS\] reference              |
|-----------------------------|--------------------------------------------------------------------|-------------------------------|
| `/`                         | HTML profile page                                                  | channel `<link>`              |
| `/feed.xml`                 | Main feed, paged                                                   | Channel elements, Paged feeds |
| `/likes.xml`                | Likes feed                                                         | `weft:likesFeed`              |
| `/following.opml`           | Follow list                                                        | `weft:following`              |
| `/webmention`               | Webmention endpoint                                                | `weft:webmention`             |
| `/posts/<slug>`             | Post permalink (HTML, RSS, Markdown by content negotiation)        | Post representations          |
| `/posts/<slug>/replies.xml` | The post's replies feed                                            | Replies feed                  |
| `/posts/<slug>/likes.xml`   | Liked-by feed for the post (a cache)                               | `weft:likes`                  |
| `/likes/<id>`               | Like permalink, where `<id>` is the host's own number for the like | Likes feed                    |
| `/.well-known/weft-domain`  | Proof that a custom handle reaches this host (§3.2)                | none                          |

The profile page MUST carry `<link rel="alternate" type="application/rss+xml" href="/feed.xml">` and `<link rel="webmention" href="/webmention">`.

Because the Webmention endpoint lives on the handle, not on the host's own domain, it moves with the person.

## 3. Custom handle setup

### 3.1 DNS records

The host shows the person two records to add:

    weft.alice.com.          CNAME  custom.weftseed.com.
    _weft.weft.alice.com.    TXT    "weft-verify=9f2c1e7a4b"

- The **CNAME** sends traffic for the handle to the host. Its target is one name the host publishes for all its custom handles (here `custom.weftseed.com`), the same for every person. A handle behind a proxy such as Cloudflare hides its CNAME, which is fine: what counts is that requests arrive (§3.2).
- The **TXT** record carries a token the host issued to that person's account. Because every person's CNAME names the same target, it is the TXT record that proves which account the domain owner chose.

### 3.2 Verification

A custom handle is verified in two steps, and only the second changes the person's address:

1.  **Verified.** The TXT record carries the token the host issued to the account claiming the handle. From then on a request that arrives on the handle is served as that person, and the host may obtain a certificate for it.
2.  **Active.** The handle reaches the host: the host requests `https://<handle>/.well-known/weft-domain` and expects the answer `weft-domain=<token>`. Only then is the handle the person's address: every other address of theirs, the feed included, answers with a permanent redirect to it (`301` for GET and HEAD, `308` for other methods).

Until the handle is active the person stays at the default handle and nothing redirects, so a domain whose DNS is not ready cannot lock anyone out. The sign-in, profile and domain pages stay on the default handle, so a handle that stops working can always be removed.

The token prevents takeover. If Alice leaves a host but forgets to update her CNAME, nobody else on that host can claim `weft.alice.com`, because they can't produce her token. Several people may claim the same handle; the first to show the token keeps it.

Hosts SHOULD re-check handles periodically, and decide what a failure means. A single failed lookup is a poor reason to drop anyone. The reference server checks once a day the accounts that exist only because of their domain (an account made through the weftseed.com sign-up): after three failed days in a row the owner is warned, and after a further 90 days without a pass the account is removed to the trash (§6). Accounts that are not tied to their domain keep their default handle, and the owner can fall back to it at any time. The reference server also checks, once a day, that an active custom handle of such an account still reaches the host. After three failed days in a row the handle stops being the person's address and the account is served at its default handle again; nothing is removed, the handle stays verified, and the owner can make it the address again from the profile page.

### 3.3 TLS

Every handle MUST be served over HTTPS. For custom handles, the host obtains a certificate on demand (ACME / Let's Encrypt) the first time the handle is requested, and only for a handle it serves (§3.2, verified). The reference server lets its proxy ask, on a private address, whether a name is one it serves, so certificates are never requested for strangers' names.

### 3.4 Pointer record (proposal)

A CNAME ties the handle to one host's servers, and obliges the new host to issue TLS certificates for the person's domain. Bluesky takes a lighter approach: the domain only *names* where the account lives, and the host is looked up from that. Weft MAY offer the same as an alternative to §3.1. The reference server does not implement it yet:

    _weft.weft.alice.com.    TXT    "weft-host=weftseed.com; weft-verify=9f2c1e7a4b"

or, equivalently, a file at `https://weft.alice.com/.well-known/weft` containing the same `key=value` pairs. Moving hosts then means editing one line. Verification stays two-way as in §3.2: the record names the host, and the host confirms the token belongs to the account claiming the handle.

The handle must still resolve to *some* server that holds a certificate for it, so this does not remove the CNAME or A record; it makes the host choice explicit, and readable by apps, instead of implied by DNS. Whether it replaces the CNAME or only supplements it is an open question below.

## 4. Discovery

- **From a person's own site.** A reader on any page of `alice.com` MAY try `https://weft.alice.com/feed.xml`. If it answers, Alice has a Weft presence. This is the main payoff of the `weft.` convention.

- **Linking from the main site.** People SHOULD add the feed link to their main site's pages, so plain RSS readers find it too:

      <link rel="alternate" type="application/rss+xml" href="https://weft.alice.com/feed.xml">

- **From a post.** Everything else is found from permalinks, as \[NS\] Post representations describes.

## 5. Moving between hosts

A post's identity is its `guid` (a `urn:uuid:`), which never changes. Its address is its permalink, which changes only if the handle does. So what a move costs depends on the handle.

### 5.1 Export

Every host MUST offer a signed-in person a complete export of their account as one file. The reference server's export is a zip with two files:

    alice.weft.zip
    ├── manifest.json   # format version, Weft version, schema version, name, base domain, export time
    └── user.db         # one consistent copy of the person's database

The database holds everything the person has on the host: posts, replies, likes, follows, pictures and the login, without sessions or an API token. Another reference server imports it, keeping every `guid`, slug, `pubDate`, `weft:updated` and tombstone as exported. The file is an implementation format, not a protocol one: a host that stores data differently cannot read it. A portable archive is an open question below.

### 5.2 Moving with a custom handle

1.  **Export** from the old host.
2.  **Import** into the new host. The new host MUST keep every `guid`, slug, `pubDate`, `weft:updated` and tombstone exactly as exported.
3.  **Update DNS.** Point the CNAME at the new host and replace the TXT token with the one the new host issues. A custom handle does not travel with the account: it is claimed again on the new host.

Every permalink, feed URL and Webmention endpoint keeps its address, so every reply anywhere on the web still resolves. Subscribers notice nothing, and no redirect is needed.

### 5.3 Moving from a default handle

Leaving `alice.weftseed.com` changes every URL. HTTP carries the move, as \[NS\] Moving a feed describes: for at least 90 days, and SHOULD for 12 months, the old host MUST answer every old address, the feed and every permalink included, with a permanent redirect to the same path on the new handle. Use `301` for GET and HEAD and `308` for other methods, so Webmentions still arrive. The old name stays reserved. The reference server never ends the redirect.

The new host SHOULD then re-send Webmentions for every reply and like the person published, so receivers update their links. The reference server does this when the account arrives, from the new addresses. Hosts SHOULD encourage people to set up a custom handle before they need to move.

### 5.4 When the old host disappears

A custom-handle person loses nothing: they import their last export and update DNS. A default-handle person whose host vanishes without redirects keeps their posts (same `guid`s, re-published on a new handle) but replies elsewhere pointing at the old permalinks break. Readers fall back to `weft:context` and the orphan rules in \[NS\].

### 5.5 Automatic transfer (reference server)

Between two reference servers the export and import happen by themselves. This is a host feature, not a requirement:

1.  The person makes an empty account with the same name on the new host.
2.  On the old host they ask for a **move code**, shown once and good for an hour.
3.  On the new host they enter the old host and the code. The new host asks the old one for a copy, checks its size and checksum, the format and that the schema is not newer than it knows, and replaces the empty account with the copy. The account keeps the new host's own password, token and sign-in.
4.  The old host answers every address with the permanent redirects of §5.3, and keeps the file in a trash for 30 days in case the move is cancelled. Changes are refused on the old account only for the last moment of the move; Webmentions that arrive meanwhile are held and sent on to the new host.

## 6. Running a host

- **Open source.** The reference implementation is a Go server with SQLite, serving HTML pages and a REST API for client apps. The REST API is implementation-specific and not part of this spec; hosts interoperate only through feeds, permalinks and Webmention.
- **Storage.** A host MAY use one database per person or one per instance. Per-person databases make export and deletion simple.
- **Pings.** Hosts SHOULD publish rssCloud or WebSub for every feed they serve, per \[NS\].
- **Deleting an account.** Every permalink returns `410 Gone`, and the host re-sends Webmentions so receivers remove replies and likes. The reference server queues them when the account is removed, does not move the file to the trash until they have been sent (or have failed repeatedly), and a receiver that fetches a source gets the `410`. A custom handle stops being served once the person removes the CNAME. The reference server keeps a deleted account's file in a trash for 30 days, so it can be brought back or downloaded, and the name stays reserved. A host MAY also switch an account off, which answers `410` on every address until it is switched on again.
- **Limits and policy.** Quotas, who may join, a cap on accounts, a waiting list and an administrator's pages are the host's own business. Only the feeds, the permalinks and the redirects are protocol.

## Open questions

- \[ \] Should hosts publish a machine-readable list of their default-handle domains, so readers can tell a host-owned handle from a person-owned one?
- \[ \] Is 12 months the right redirect commitment for default handles, or should hosts be required to keep them longer?
- \[ \] Should there be a portable export in plain RSS, OPML and text, so hosts that store data differently can import each other's archives? For example: `feed.xml` with every post and `source:markdown`, `likes.xml`, `following.opml`, one replies feed per post, `tombstones.txt` for deleted slugs, and the pictures at their original paths.
- \[ \] Should the pointer record in §3.4 supplement the CNAME, replace it, or stay out of 0.1? Replacing it needs a way to route and certify the handle without a CNAME.
