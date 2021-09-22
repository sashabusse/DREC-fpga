TARGET = dff_tb
TOP_MODULE = $(TARGET)

SOURCES = \
dff_tb.v \
sr_latch.v \
d_latch.v \
dff.v \

all: $(TARGET)

$(TARGET): $(SOURCES)
	iverilog -s$(TOP_MODULE) -o $@ $(SOURCES)
	vvp $(TARGET)


.PHONY: gtk

gtk:
	gtkwave dump.vcd