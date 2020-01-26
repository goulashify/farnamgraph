### NAME
Farnamgraph - Scripts to make a graph out of Farnam Street articles and books.

### SYNOPSIS
**make** [ target ] ...

### DESCRIPTION
A small set of tools that mirror the Farnam Street [blog](https://fs.blog), extract references and build a website with an interactive graph of books and articles.

### TARGETS
| Name       | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| **clean**  | Removes the *target/* directory.                             |
| **mirror** | Updates the mirror of the FS blog into the *mirror/* directory. |
| **site**   | Creates a static site with the graph into the *dist/* directory. |

### REQUIREMENTS
Apart from standard POSIX tooling the scripts depend on *wget*, *jq*, and *graphviz*.

**Important note**: the sources (*static/index.html*) contain tracking scripts for my own use, remove these if you're deploying to your own environment.
