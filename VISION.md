# Buzzy's Bar: vision

*Agreed 2026-10-30. This replaces the original curator/member spec in `README.md`.*

## In one line

A logbook of every version of every tiki drink we've tried, at bars, from books, or made at home, and who we tried it with. Over time it becomes the way we decide what to make or order next.

## Who it's for

Me, my family, and the friends we drink with. The group changes all the time: sometimes it's everyone, sometimes a few of us, sometimes just one person, and new people join. The app is built for our own use first. It also has to work as a portfolio piece, which shapes how privacy works (see [Private, but showable](#private-but-showable)).

## The core idea: the occasion

What we actually do is go to a tiki bar (or make drinks at home), order or make several drinks, share them, take photos, and compare them with every other version of that drink we've had. So the center of the app is the **occasion**, not the recipe.

```
Person ──< Attendance >── Occasion ── at a Place (a bar, or home)
                             │
                             ├── photos (decor, group shots)
                             └──< Tasting ── of a Drink
                                     │         (optionally using a Recipe,
                                     │          which may be a riff on another)
                                     ├── photo of the drink
                                     └──< Rating ── by a Person who was there
```

- **Person:** anyone who drinks with us. It's separate from a login: a friend can appear in the log without ever signing up. A Person can be linked to a `User` account later if they want to add their own entries.
- **Occasion:** a date, a place, and who came. Don't call this model `Session`, because the authentication generator already uses that name.
- **Place:** a bar, or home.
- **Drink:** just a name and identity: Mai Tai, Saturn, or a bar's house original. It's cheap to create.
- **Recipe:** optional. It has a source (a book and page, a bartender, or "our riff") and can point to the recipe it's based on. Riffs are a link between recipes, not a level in a tree.
- **Tasting:** one drink at one occasion. At home it can point to the recipe used. At a bar, it usually has no recipe.
- **Rating:** one person's score and notes for a tasting. A tasting can have zero or more ratings, and any signed-in user can enter ratings for anyone who was there.

**The 15-second test:** someone at a bar who knows only a drink's name must be able to log it in about 15 seconds. Ratings, photos and notes are always optional and can be added later.

**The question it must answer well:** "Show me every Saturn we've had, at bars and at home, ranked, and who liked which one best."

## Photos

- **Occasion photos:** decor, the room, group shots.
- **Drink photos:** attached to a tasting, so they show up next to every other version of that drink.
- **Practical notes:**
  - iPhones save photos as HEIC by default, so accept HEIC and convert it (or make sure uploads arrive as JPEG). The current image check only allows GIF, JPEG and PNG.
  - Phone photos are large, so use Active Storage variants for display sizes from the start.

## Private, but showable

The app is **private by default**, and it can still be shown off in three ways:

1. **Chosen items made public.** Mark individual things public, like a bar review, a drink ranking, or a photo of a drink or the decor. buzzysbar.com shows them as public pages. Photos of people and recipes copied from books never go public; this handles both privacy and copyright. Building this means visibility scopes, authorization checks, and making sure private data can't leak into public pages.
2. **A demo account.** A "Try the demo" button logs visitors into a sandbox with made-up data: fictional people, occasions, ratings and photos. A scheduled Solid Queue job resets it every night. Demo recipes are written in our own words or use well-known classics.
3. **The code and the write-up.** A clear README, good tests and CI, plus a write-up on alejandrocortes.dev about the design decisions: the occasion-centered model, a changing group of people, and private-with-public-sharing.

## The home bar (later)

- **Bottles we own, grouped by category.** A recipe calls for "aged Jamaican rum," and any bottle in that category counts.
- **Homemade syrups with freshness.** Orgeat, falernum, cinnamon syrup and the like, with the date each was made, so we know when one needs replacing.
- **"What can we make tonight?"** It suggests recipes we have everything for, and "which bottle should we buy next to unlock the most new drinks?"

## Roadmap

This is an ongoing hobby. Each phase should be usable on its own.

1. **Logbook.** People, Places, Occasions, Drinks, Tastings, Ratings and photos. This is enough to log real outings.
2. **Demo account** with seed data and the nightly reset. From here on the site can be shown at every stage.
3. **Public sharing.** Visibility settings plus public pages for chosen bar reviews, rankings and photos.
4. **Recipe library.** Recipes with sources (book and page, bartender), and riffs linked to the recipe they're based on.
5. **Home bar.** Bottles, rum categories, syrups with freshness dates, and "what can we make."
6. **Extras.** Rankings and comparisons, stats, a map and "passport" of bars, a wishlist of bars and drinks, and "drinks from this book we haven't tried yet."

## What happens to the current code

- **Kept:** the Rails 8 stack, authentication, the Kamal deployment, CI, and the buzzysbar.com domain.
- **Repurposed:**
  - `Beverage` is really a recipe ("Hurricane" and "Smuggler's Cove Hurricane" are two recipes for one drink), so it becomes `Recipe` in phase 4, keeping its styled pages and seed recipes. `Drink` is a separate, lightweight model added in phase 1.
  - `Review` becomes `Tasting`/`Rating`.
  - `User` stays as the login account, linked to a `Person`.
- **Dropped:** the curator/member roles, public sign-up, collections, and comments and moderation. Accounts are invite-only.

## Open questions

- Which things are public by default, if any, versus always opt-in?
- Is "home" one Place per household, or can there be several, such as different family members' homes?
- Does someone without an account ever need to see the private side, for example through a share link to one occasion?
- Should ratings be on a 1–5 scale, allow half points, or use something else?
- What's the final name for the occasion model: `Occasion`, `Outing` or `Visit`?
