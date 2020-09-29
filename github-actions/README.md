# GitHub Actions Doc Generator

Generates Markdown docs for GitHub Actions.

## Inputs

| Name | Description | Required | Default |
| --- | --- | --- | --- |
| exclude | A list of paths (one per line) to exclude from the generation. Glob patterns are accepted. For reference, Ruby's Dir.glob is used: https://ruby-doc.org/core-2.6.3/Dir.html#method-c-glob. | false | `third-party/**/*` |
| branch | The branch name used by the bot to be pushed at the origin. |  | `generated-doc-github-actions` |
| commit_title | The title of the commit with the generated doc. The PR will also use this title. |  | `doc: auto-generated GitHub Actions README.md` |
| github_token | The GitHub repository token. | true |  |

## Outputs

This action has no outputs.
