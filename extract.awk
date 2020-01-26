BEGIN {
  amazon_re = "amazon\.com/gp/product/[0-9A-Za-z]+/"
  fs_re = "fs.blog/20../../[a-zA-Z0-9-]+/" # matches fs blog post links.
  article = 0; # Did we hit the article tag yet?
  print "digraph {"
}

# Only care about content inside the actual article, this skips irrelevant 
# content like the "relevant articles" part of the page for example.
article == 0 && /<article id="post-[0-9]+"/ { article = 1; }
article == 1 && /<\/article/ { 
  article = 0;
  nextfile; # being with the next file.
}

# Extracts links to amazon products.
article == 1 && /amazon.com/ {
  if(match($0, amazon_re)) {
    printe(substr($0, RSTART, RLENGTH));
  };
}

# Extracts links to fs blog posts.
article == 1 && /fs.blog/ {
  if(match($0, fs_re)) {
    printe(substr($0, RSTART, RLENGTH));
  };
}

# Prints the link as an edge (in a graph) with the source of the current file.
function printe(link) {
  # This might fail if the url structure changes, make sure this is in sync with
  # the article pattern and the directory structure mirrors it properly.
  if(!match(FILENAME, fs_re)) {
    print "\t// -------------------------------------------------";
    print "\t//";
    print "\t// Failed to match article from file", FILENAME, 
          "check printe() comments.";
    print "\t// SKIPPING", FILENAME, "--", link;
    print "\t//";
    print "\t// -------------------------------------------------";
    return;
  }

  # Skip edges to the articles itself from the article (think weird full-link 
  # html anchors and the likes).
  if (substr(FILENAME, RSTART, RLENGTH) == link) {
    return;
  }

  # This is in Graphviz format (dotfiles).
  printf("\t\"%s\" -> \"%s\"\n", substr(FILENAME, RSTART, RLENGTH), link);
}

END {
  print "}"
}