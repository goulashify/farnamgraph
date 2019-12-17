#!/usr/local/bin/fish

# Mirroring.
function fetch_fs_articles
    echo "Fetching Farnam Street articles to mirror/..."
    wget -r -m -D fs.blog --accept-regex 'fs.blog/20../../.*/\$$' --reject-regex '/amp/\|/smart-decisions/' --directory-prefix  mirror/ https://fs.blog/blog/
    set count (all_articles | wc -l | sed 's/ //g')
    echo "Done, storing $count articles locally."
end

function all_articles
    find mirror -name index.html
end

# Data extraction
function amazon_links
    cat $argv[1] | egrep -o 'amazon.com/gp/product/[0-9A-Za-z]+/'
end

function farnam_links
    cat $argv[1] | egrep -o 'https://www.amazon.com/gp/product/[0-9A-Za-z]+/'
end

# Graph output.
function write_graph
    set dist 'dist'

    echo "Cleaning $dist..."
    rm -rf $dist
    echo "Done."

    echo "Writing references between articles and amazon links to $dist/fs.dot..."
    mkdir $dist
    print_graph >> $dist/fs.dot
    set stat (cat $dist/fs.dot | grep "\-\-" | wc -l | sed 's/ //g')
    echo "Done, $stat edges."

    # This dot thing is a piece of shit, it doesn't terminate. :(
    echo "Converting the $dist/fs.dot to $dist/fs.json..."
    dot -Tjson0 -o$dist/fs.json $dist/fs.dot 
    echo "Done."
end

function print_graph
    # Dot graph opening.
    echo "graph {" 

    for article in (all_articles)
        set pretty_article (echo $article | sed 's/mirror\///' | sed 's/index.html//')

        # Links to amazon pages.
        for link in (cat $article | egrep -o 'amazon.com/gp/product/[0-9A-Za-z]+/')
            echo "\"$pretty_article\" -- \"$link\""
        end

        # Links to other posts.
        for link in (cat $article | egrep -o 'fs.blog/20../../[a-zA-Z-]+/')
            echo "\"$pretty_article\" -- \"$link\""
        end
    end

    # Dot graph ending.
    echo "}"
end

function cli
    switch $argv[1]
        case 'fetch'
            fetch_fs_articles
        case 'gengraph'
            write_graph
        case 'help'
            echo 'Usage: ./make.fish {command}'
            echo 'Commands:'
            echo '  fetch:      mirrors farnam street articles'
            echo '  gengraph:   generates a graph with [article, article] and [article, amazon link] edges'
            exit 1
    end
end

# Sets the default argument.
if test -n $argv[1]
    set -a argv 'help'
end 

cli $argv