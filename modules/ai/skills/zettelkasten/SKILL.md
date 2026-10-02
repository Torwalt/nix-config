---
name: zettelkasten
description: Write and maintain the user's Zettelkasten (second brain) in ~/repos/notes/zettelkasten. Daily notes (YYYY-MM-DD.md) from the day's uncommitted note changes, weekly notes (YYYY-Www.md) from that week's notes, project and topic notes (root + sub-notes, decisions, TODOs, handovers). Use when asked for a daily note, journal entry or end-of-day summary, a weekly note or weekly review, or to create, update, split, archive or link a note, zettel or project note.
---

# Zettelkasten

Notes live in `~/repos/notes/zettelkasten/`, one flat directory of Markdown
files. The git repo is `~/repos/notes`. `[[name]]` links to `name.md`. The
editor plugin (telekasten) finds daily and weekly notes by file name, so those
names are exact.

| Kind | File | Holds |
|---|---|---|
| Daily | `YYYY-MM-DD.md` | what happened that day, links to project notes |
| Weekly | `YYYY-Www.md`, ISO week (`2026-W07`) | the week condensed |
| Topic / project | `<kebab-case-name>.md` | the content: design, decisions, how-tos, research |

Dailies and weeklies are journal and index. Content lives in topic and project
notes. A daily points at it and does not copy it.

A project-specific skill or instruction may set its own names and templates for
that project's notes. Follow it there. This skill gives the defaults.

## Communication

Applies to every note and to replies. Use terse technical communication.

- Prioritize information density over prose.
- State facts, decisions, problems, and actions directly.
- Use short declarative sentences.
- Prefer structured fragments when full sentences add no clarity.
- Eliminate conversational filler, transitions, preambles, and repetition.
- Do not restate the question or task.
- Do not narrate your reasoning or actions unless required.
- Do not explain obvious code or established context.
- Use precise technical terminology. Do not replace precise terms with simpler but less accurate language.
- One statement should convey one idea.
- Prefer `Problem:`, `Cause:`, `Decision:`, `Risk:`, `Action:` when structure helps.
- Expand only when ambiguity, risk, or a non-obvious tradeoff requires explanation.

Bad:
"The main thing we need to consider here is that there are a few different
ways we could approach this, but I think the simplest option would probably
be to move this logic into the service layer."

Good:
"Move this logic to the service layer. It owns the required state and avoids
duplicating the invariant."

Bad:
"I've made the requested changes. The main changes I made were updating the
handler and then also adding a test to make sure the new behavior works as
expected."

Good:
"Updated the handler. Added regression coverage."

Bad daily bullet:
"- Spent most of the day on the backup rewrite. It went well and the restore
path should finally be in a good state now."

Good:
"- backup rewrite: restore path done, tested [[homelab-backup-main]]"

## Daily and weekly notes

Short bullet logs, read later to recall what happened. Not a diary.

- Bullets only. No paragraphs.
- One bullet, one line. Detail goes to a sub-bullet or into the project note.
- Outcome over activity: `restore path tested`, not `worked on backups`. Every bullet carries a state: started, done, tested, in review, merged, paused, handed over, blocked on what.
- A decision made that day gets a fragment: `decided: drop the cache`.
- Caps: daily 10 lines, weekly 15. Over the cap: merge threads, drop minor ones.
- Voice: the user's. Fragments, no "I". Opinions, mood and reflection only when the user or the dailies give them, in their wording, kept short.

### Linking

- Every thread bullet ends with the link to its note: the project root, or the sub-note that was the main artifact (plan, handover, review round).
- Ticket without a note: its URL.
- Several links: space-separated at the end of the bullet.
- Link only notes that exist. Do not open a note just to have a link target.
- A weekly links a daily (`[[2026-02-11]]`) only when it holds a section worth reading.
- Project notes do not link back to dailies.

## Daily note

### Evidence

The day's work is what changed in the notes since the last commit. The user
commits once per day, so the uncommitted state is usually exactly today.

```bash
cd ~/repos/notes
git log -1 --format='%h %cd' --date=iso                 # window start
git status --short zettelkasten                         # touched since then
find zettelkasten -name '*.md' -newermt "$(date +%F)"   # touched today
git diff zettelkasten/<note>.md                         # change to an existing note
```

- New note: read title, first paragraph, Status, TODO. A new note means a topic started.
- Changed note: read the diff. Status lines, ticked TODOs, new decisions, a new handover or review sub-note carry the progress.
- Last commit older than yesterday: the uncommitted set spans several days. Keep only what `find -newermt` dates to the target day.
- Past day: that day's commit (`git log --since --until --name-only`) is the record. mtimes only show the last touch.
- The current conversation, when the work happened in it.
- What the user says in the request: meetings, people, side projects, mood. None of it is in the notes. Do not invent it.
- Optional: a note that names a repo and branch can be checked with `git log --since=midnight` there for what landed.

No evidence and nothing from the user: say so and ask for the day's points.
Do not write an empty or invented note.

### Shape

```markdown
# <main topics of the day, comma-separated>

- <thread>: <state, what moved> [[<project-root>]]
  - <detail or next step>
- <thread>
```

Fictional example:

```markdown
# backup rewrite, router vlans

- backup rewrite: restore path done and tested [[homelab-backup-main]]
  - decided: keep 30 dailies, prune weekly [[homelab-backup-discussion]]
  - next: offsite target
- router vlans: lost in firmware update, restored [[router-vlans]]
```

- Title: lowercase, a few words per topic, main topics only.
- One bullet per thread, not per note touched. Several notes of one project collapse into one bullet.
- Next step as a sub-bullet when the notes have one.
- Sub-bullets one level deep, rarely two.
- Work and personal threads share the note, as they happened.
- `## <topic>` section only for a longer piece that belongs to the day and to no project: a message draft, a loose thought. Project content goes into the project's notes, linked from the daily.

### Procedure

1. Date: today (`date +%F`) unless the user names one.
2. File exists: extend it, keep what the user wrote.
3. Collect the evidence, write the note.
4. Reply with the path, plus one line that off-notes items (meetings, side projects) can be added. No further questions.

## Weekly note

### Evidence

```bash
d=$(date +%F)                                          # or a day in the target week
week=$(date -d "$d" +%G-W%V)                           # file name
mon=$(date -d "$d -$(( $(date -d "$d" +%u) - 1 )) days" +%F)
sun=$(date -d "$mon +6 days" +%F)
cd ~/repos/notes/zettelkasten
for i in 0 1 2 3 4 5 6; do
  f=$(date -d "$mon +$i days" +%F).md
  [ -f "$f" ] && { echo "== $f"; cat "$f"; }
done
git -C .. log --since="$mon 00:00" --until="$sun 23:59" \
  --name-only --format='%h %ad' --date=short -- zettelkasten
```

- The week's dailies: the main source.
- Project roots they link: Status and TODO show where each thread ended up.
- Notes touched that week per the git log, plus uncommitted ones when it is the current week.
- The previous weekly: what was open, so this one can say what closed.
- What the user says in the request.

### Shape

```markdown
# <themes of the week, comma-separated>

- <thread>: <where it stood Monday, where it ended> [[<project-root>]]
  - <notable turn: a decision, a blocker, a review outcome>
- <thread>
- <reflection from the dailies: focus, workflow, side projects>
```

- Synthesize across days: one bullet per thread for the whole week, never day by day.
- Order: finished, in review or test, started, paused.
- Partial week (holiday, days off): say so in the title or first bullet, only when a note or the user says it. A missing daily is not a day off.

## Project and topic notes

### Before writing

Search first: `ls ~/repos/notes/zettelkasten | grep -i <word>` and
`grep -ril <word> ~/repos/notes/zettelkasten`. Update an existing note rather
than open a parallel one.

### Single note or project

- One topic, one sitting (a fix, a how-to, a piece of research): a single note, e.g. `docker-disk-cleanup.md`, `laptop-fan-control.md`. Prefix the area when it groups well: `nix-`, `rust-`.
- Work across sessions, with decisions and open TODOs: a project, with a root note and sub-notes.

### Naming

- Kebab-case. Never rename a note, links break.
- Project root: `<project>-main.md`. Ticket-driven: `<org>-<ticket>-main.md`, e.g. `acme-123-main.md`.
- Sub-note: `<project>-<topic>.md`. Topics: `discussion`, `plan`, `test-plan`, `performance`, `review-round-1`, `handover`, `migration`.
- Older roots without `-main` keep their names.

### Single note template

```markdown
# <title>

#<area>
#<area>

Opened <YYYY-MM-DD>. <Goal or trigger, one or two sentences.>

## 1. <section>
```

### Root template

```markdown
# <project or ticket title>

#<project>
#<area>

Opened <YYYY-MM-DD>. <Where it lives: repo, branch, base commit.>
Status (<YYYY-MM-DD>): <one line: phase and what is next>.

## Goal

<What to build or solve, what done means. For a ticket: its text, verbatim or close.>

## TODO

- [ ] <next action>

## Decisions

- D1 (<date>): <decision in one line>. Why: [[<project>-discussion]] §<k>.

## Rejected

- <approach> (<date>): <reason in one line>. [[<note>]]

## Index

- [[<project>-discussion]]: <what it holds>.

### Archived

- [[<note>]] (archived <date>): <what it was, why it stopped>.
```

- Ticket text: from the issue tracker when a connector is available, else ask the user to paste it. Do not invent it.
- Leave sections empty rather than guess.

### Root rules

- Pointers and one-liners. Reasoning, tables, logs, code and case lists go to sub-notes.
- About 100 lines. Past that, move the largest section to a sub-note and leave a pointer.
- Update Status and TODO, dated, at the end of every working session. The next session resumes there, and the daily note reads it.
- Decisions are numbered and never renumbered. A reversed one stays, marked `superseded by D<k>`.
- Rejected approaches stay recorded so they are not proposed again.

### Sub-notes

Open one for:

- a self-contained activity: plan, test plan, performance run, review round, migration, handover, brief for someone else;
- a discussion of more than one exchange: `discussion` first, split by topic past ~300 lines;
- reference material: case tables, inventories, query snippets;
- a root section past ~20 lines.

Not for a single fact. That is a Decision or TODO line in the root.

```markdown
# <project short title>: <topic>

#<project>
#<kind: design, testing, performance, review, handover>

Sub-note of [[<project>-main]], opened <YYYY-MM-DD>. <Purpose and scope, one sentence.>

## 1. <section>
```

- Numbered sections, cited as `[[note]] §2`.
- Review round: one item per comment with what was said, what the code does, verdict, action.
- Test or performance run: commit, data state, exact commands, so it can be repeated.
- Archive, never delete: append ` (archived <date>)` to the title, put reason and successor link at the top, move the index line under `### Archived`.

### Linking

- A sub-note links its root in the first paragraph. The root index links every sub-note. Add both in the same edit.
- Across projects: link the other root or a specific `§`. Do not chain through sub-notes.
- Code by commit and repo path, not by line number.

### Style

- Absolute dates.
- Name who made each call.
- Notes are a design log. Where they disagree with the code or git history, the code is right: fix the note.
- The notes are the record of project state, decisions and plans. Do not mirror them into agent memory.

## Committing

- Do not commit unless asked.
- When asked: one commit for the day, the daily note plus the notes it covers. Match the message style of `git log`.
