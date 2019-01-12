# Commits

This file describe rules that must be applied to commit code to
**PrettyTables**.

Notice that this document is **under construction**.

## Best practices

The following list of best practices should be considered when creating commits
for this project:

1. The commits should be incremental. Try to avoid very big changes within just
   one commit.
2. The overall state of the software must be as functional as possible between
   two commits. Try to avoid commits that break the entire software if another
   commit is not applied.

## Commit message

The commit message must have the following structure:

```
<EMOJI> Short summary of changes
                         -- BLANK LINE -- 
More detailed explanatory text, if necessary.  Wrap it to 67
characters.  In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body.  The
blank line separating the summary from the body is critical (unless
you omit the body entirely); tools like rebase can get confused if
you run the two together.

Further paragraphs come after blank lines.

  - Bullet points are okay, too.

  - Typically a hyphen or asterisk is used for the bullet, preceded
    by a single space, with blank lines in between, but conventions
    vary here.
```

**Source**: Adapted from http://git-scm.com/book/ch5-2.html

Notice that:

1. The short summary **must** be less than **50 characters**. The emojis, if
   present, count as 1 character each.
2. **Don't** end the summary with a period.
3. If the summary indicates an action, then if **must** be written in imperative
   form. Hence, write "Fix ...", "Change ...", and "Add ...", instead of "Fixed
   ...", "Changed ...", or "Added ...".
3. It is preferred that only one emoji is used per commit.
4. All the phrases in the explanatory text **must** be punctuated.
5. If there is an explanatory text, a blank line **must** exist between the
   short summary of changes and the explanatory text.
6. The is no limit for the detailed explanatory text, but it must be wrap to 72
   characters.

## Commit emojis

Emojis can be used to improve the understanding about the commit. It can be used
at the beginning of the commit message to indicate what kind of modification the
commit does. The following table describe some situations:

| Commit Type            | Emoji                                                          |
|------------------------|----------------------------------------------------------------|
| Initial Commit         | :tada: `:tada:`                                                |
| Version Tag            | :bookmark: `:bookmark:`                                        |
| New Feature            | :sparkles: `:sparkles:`                                        |
| Bugfix                 | :bug: `:bug:`                                                  |
| Refactoring            | :package: `:package:`                                          |
| Documentation          | :books: `:books:`                                              |
| Internationalization   | :globe_with_meridians: `:globe_with_meridians:`                |
| Performance            | :racehorse: `:racehorse:`                                      |
| Cosmetic               | :lipstick: `:lipstick:`                                        |
| General improvements   | :wrench: `:wrench:`                                            |
| Tests                  | :rotating_light: `:rotating_light:`                            |
| Deprecation            | :poop: `:poop:`                                                |
| Work In Progress (WIP) | :construction: `:construction:`                                |
| Warning                | :warning: `:warning:`                                          |
| Other                  | [See here](https://www.webpagefx.com/tools/emoji-cheat-sheet/) |

**Note**: If the commit contains an important warning, such as a breaking change, then the emoji :warning: `:warning:` must be added to the commit title. In this case, two emojis can be used.
