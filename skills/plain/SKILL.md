---
name: plain
description: Restate dense, jargon-heavy, or hard-to-follow content in plain language so the user actually understands it. Use whenever the user invokes /plain, says something like "explain that more simply", "I don't follow", "what does that actually mean", "in plain English", "break that down", "ELI5", or pastes/points at text they find dense. With no arguments, restate your own previous response. With arguments (pasted text, a file path, or "the part about X"), restate that instead. Trigger even on informal signals of confusion — "wait, what?", "huh?", "lost me" — not just explicit requests.
---

# Plain

Restate something in language a smart person outside the field would understand on first read. The user invokes this when a previous explanation was too dense to follow — and usually too long, which is part of what made it hard to follow. Your job is translation plus compression: keep the points the user actually needs, explain those plainly, and drop the rest. Cut breadth, not depth — a lesser point goes away entirely; a kept point still gets a real explanation.

## What to restate

- **No arguments**: restate your own previous response in this conversation. Cut it down, don't just reword it — its length was part of the problem.
- **Pasted text or a file path**: restate that content. Read the file first if given a path.
- **A pointer like "the part about caching"**: restate just that portion, with enough surrounding context to stand alone.

## The audience

Write for a sharp, capable adult who doesn't live in this domain. Not a child — don't be cutesy or condescending, and don't strip out real substance. The reader can handle complexity; what they can't handle is compressed insider shorthand. The test: could they re-explain it to someone else after one read?

## How to write it

**Plain prose, no scaffolding.** Write it the way a good colleague would explain it out loud — flowing sentences, no headers, no bullet hierarchy, no bold-label formatting. Structure was often part of the problem; a wall of labeled sections reads as organized but doesn't build understanding.

**Explain the mechanism, not the label.** Jargon usually names a mechanism. Instead of dropping the name, describe what actually happens. "Memoization" becomes "saving the answer the first time so you don't compute it again." If a term is genuinely worth the reader knowing — they'll hit it again elsewhere — introduce it *after* the plain description: "...this is what people mean by 'memoization'." Never the other way around.

**One idea per sentence.** Dense prose packs three moves into one sentence with subordinate clauses. Unpack them. Short sentences are not dumbed down; they're sequenced.

**Use a concrete example or analogy when the idea is abstract.** An analogy earns its place only if it maps accurately — a leaky analogy is worse than none. Prefer examples from the user's actual situation (their code, their project) over invented ones.

**Keep the caveats that matter.** Simplifying by omitting a load-bearing exception produces something clear and wrong. If the original hedged for a real reason, keep the hedge but say it plainly: "this works unless the data changes often, in which case..."

**Come in shorter.** A single dense sentence can take more words than it had — unpacking jargon isn't free — but the allowance stops there. A dense paragraph should come back shorter, and a full response should come back at half its length or less. Get there by cutting scope, not clarity: make each point once, use at most one example, and drop lesser points entirely instead of explaining everything a little. If the draft ended up longer than the original, cut before sending.

**Check understanding is even possible.** If the original was dense because it glossed over something you'd need to explain properly, say so: "the short version is X; the part I skipped over is Y — want me to unpack that too?"

## Kill the LLM-isms

These patterns (catalogued in Wikipedia's "Signs of AI writing") make prose feel machine-generated and get in the way of understanding. Cut all of them:

- **Throat-clearing and meta-commentary**: "It's important to note", "It's worth mentioning", "Let's break this down", "Great question". Start with the substance.
- **Formulaic transitions**: "Moreover", "Furthermore", "Additionally", "That said". Plain prose connects ideas by their content, not by connective tissue.
- **The rule of three**: triads of adjectives, examples, or clauses ("fast, reliable, and scalable"). Two items, or one good one.
- **Inflated verbs and puffery**: "delve", "leverage", "boasts", "stands as a testament", "plays a vital role", "underscores". Say what it does.
- **"Not X, but Y" contrasts**: state Y directly.
- **Hedging stacks**: "may potentially", "could arguably". Pick a position or name the actual uncertainty.
- **Summary tails**: "In conclusion", "Overall", a final paragraph that restates the paragraph above it. Stop when the explanation is done.
- **Em-dash chains and heavy formatting**: no cascade of dashes, bold terms, or nested bullets. This is spoken-register prose.

## Examples

**Dense original:**
> The middleware intercepts inbound requests and performs JWT validation against the issuer's JWKS endpoint, short-circuiting the request lifecycle with a 401 on signature verification failure, thereby ensuring downstream handlers operate exclusively on authenticated contexts.

**Plain restatement:**
> Before any request reaches your route code, a checkpoint checks the login token it carries against the login provider's published keys to make sure it's genuine. If the check fails, the request is rejected on the spot with a 401, so your route code only ever sees authenticated requests.

**Dense original:**
> Hydration mismatches arise when the server-rendered markup diverges from the client's initial render output, forcing React to discard the SSR payload and re-render, negating the performance benefits of server rendering.

**Plain restatement:**
> The server sends ready-made HTML so the page shows up fast; React then builds the same page again in the browser, and the two versions must match exactly. When they differ — a timestamp computed differently on each side, say — React throws out the server's HTML and rebuilds from scratch, so the server rendering bought you nothing.
