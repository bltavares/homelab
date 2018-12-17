TARGETDIR := build

all: | p2

controller: | $(TARGETDIR)/controller/user-data

$(TARGETDIR)/controller/user-data: files/controller/* $(TARGETDIR)/controller
	m4 -P -Dclusterhat=$(base64 files/controller/) source/controller/user-data.yml > $(TARGETDIR)/controller/user-data

$(TARGETDIR)/p%/cmdline.txt: source/cluster-nodes/cmdline.txt
	m4 -D NODE=$@ $<

p1 p2 p3 p4: $(TARGETDIR)/p%/cmdline.txt

$(TARGETDIR)/controller: $(TARGETDIR)
	mkdir -p $(TARGETDIR)/controller

$(TARGETDIR):
	mkdir -p $(TARGETDIR)

.PHONY: all controller