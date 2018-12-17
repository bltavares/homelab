TARGETDIR := build

COMPILE_NODE = m4 -D NODE=$* $< > $@

all: | controller p1 p2 p3 p4

controller: $(TARGETDIR)/controller/user-data
p1 p2 p3 p4: p% : $(TARGETDIR)/p%/cmdline.txt $(TARGETDIR)/p%/user-data

$(TARGETDIR)/controller/user-data: source/controller/* | $(TARGETDIR)/controller/
	m4 -D CLUSTERHAT="$(shell base64 -w0 source/controller/clusterhat)" \
	   -D UDEV_RULES="$(shell base64 -w0 source/controller/90-clusterhat.rules)" \
	   -D INTERFACES="$(shell base64 -w0 source/controller/interfaces)" \
	   source/controller/user-data.yml \
	   > $@

$(TARGETDIR)/p%/cmdline.txt : source/cluster-nodes/cmdline.txt | $(TARGETDIR)/p%/
	$(COMPILE_NODE)

$(TARGETDIR)/p%/user-data : source/cluster-nodes/user-data.yml | $(TARGETDIR)/p%/
	$(COMPILE_NODE)

$(TARGETDIR)/%/:
	mkdir -p $(TARGETDIR)/$*

clean:
	rm -rd build

.PHONY: all controller p1 p2 p3 p4 clean