SHELL := /bin/sh

MIRROR=mirror
SITE=static
DIST=dist
DIST_DATA=$(DIST)/assets/data

.PHONY: mirror site clean

# Updates the mirror/ directory.
mirror:
	@echo "Fetching Farnam Street articles to $(MIRROR)/...";
	-@wget\
		--mirror \
		--recursive \
		--domains "fs.blog" \
		--accept-regex "fs.blog/20../../.*/\$$" \
		--reject-regex "/amp/|/smart\-decisions/" \
		--compression "auto" \
		--content-on-error \
		--directory-prefix "$(MIRROR)/" \
		--no-verbose \
		--timestamping \
		"https://fs.blog/blog/";

# Extracts all links to amazon products and fs.blog articles from the text of
# the articles mirrored and builds a graph from it.
$(DIST_DATA)/fs.dot:
	@echo "Extracting graph from articles..."
	@mkdir -p $(DIST_DATA)
	@awk -f extract.awk $(MIRROR)/fs.blog/*/*/*/index.html >> $(DIST_DATA)/fs.dot

# Converts the graphviz-style graph to a JSONGraph, so it's usable in JS-land.
$(DIST_DATA)/fs.json: $(DIST_DATA)/fs.dot
	@echo "Converting Graphviz to JSONGraph..."
	@dot -Ksfdp -Tjson0 $(DIST_DATA)/fs.dot > $(DIST_DATA)/fs.dot.json
	@jq "{ \
		graph: { nodes: [.objects[] | { id: ._gvid, label: .name }], \
		edges: [.edges[] | { source: .tail, target: .head }] } \
	}" $(DIST_DATA)/fs.dot.json > $(DIST_DATA)/fs.json

# Assembles a static website out of the sources and the data.
site: $(DIST_DATA)/fs.json
	@echo "Copying the site, setting last-updated..."
	@cp -r $(SITE)/* $(DIST)/
	@sed -i "" "s/%%LAST_UPDATED%%/$$(date)/g" "$(DIST)/index.html"

clean:
	@rm -rf $(DIST)
