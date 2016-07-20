# recent-finder

Open recent file with fuzzyfinder **across** project.

![gif](https://raw.githubusercontent.com/t9md/t9md/27c7505aab5668880e8d1c11ec3a1864cc0555ba/img/atom-recent-finder.gif)

# Why?

Atom don't provide native file-finder for recently opend file.  
While I'm working on multiple project, sometime I want to open single file from another project as reference, especially while I'm doing some sort of try&err.  
This package provide `recent-file-finder` **across** project.

Here is the list of finder-command and its target.

| Command     | Target |
| :------------- | :------------- |
| `recent-finder:toggle` | recent file **across** project
| `fuzzy-finder:toggle-buffer-finder` | open buffer |
| `fuzzy-finder:toggle-file-finder` | file within project |

# Configuration

No default keymap.  
Configure whatever keymap you like in you `keymap.cson`.  

e.g.
```coffeescript
# Since both `cmd-p` and `cmd-t` are mapped to
# `fuzzyfinder:toggle-file-finder` by default.
# I use `cmd-p` for this.
'atom-workspace:not([mini])':
  'cmd-p': 'recent-finder:toggle'
```



# Settings

* `recent-finder:syncImmediately`: Default:`true`. Save recent entries to localStorage on every file open and always read etnries from localStorage. If you want to sync entries across multiple atom windows immediately, this option is for you.

# Commands

* `recent-finder:toggle`: toggle recent-finder
* `recent-finder:clear`: clear all entry, use this if you are in trouble.
