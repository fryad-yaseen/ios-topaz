# Build18 speaker base. One hypothesis: AUX DAC/PA DAPM startup omitted.
# Upstream aux DAC sets AUXPA bit4, PA PRE_PMU sets WD low3=7.
# Android HP_MODE steady state is 3128=80 / WD=05; this is a deliberate
# upstream-vs-vendor experiment, not a claimed correction to that capture.
@codec
tone 1000 5 3277 LR
@graph
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
rx 0x180 0x50
rx 0x190 0x06
wcd 0x3128 0x00
delay 2
wcd 0x3467 0x00
wcd 0x3128 0x10
wcd 0x3467 0x07
wcd 0x3128 0x90
delay 2
wcd 0x3008 0xc3
every 500ms rd rx 0x180 5
every 500ms rd rx 0x400 6
every 500ms rd rx 0x500 6
every 500ms rd swr 0x104c 1
every 500ms rd swr 0x1124 3
every 500ms rd swr 0x1164 3
every 500ms rd swr 0x1424 2
every 500ms rd swr 0x1464 2
every 500ms rd swrs 0x120 3
every 500ms rd swrs 0x130 3
every 500ms rd swrs 0x420 3
every 500ms rd swrs 0x430 3
every 500ms rd wcd 0x3008 4
every 500ms rd wcd 0x30d9 1
every 500ms rd wcd 0x30ef 2
every 500ms rd wcd 0x3128 1
every 500ms rd wcd 0x31c3 1
every 500ms rd wcd 0x3408 8
every 500ms rd wcd 0x344e 3
every 500ms rd wcd 0x3465 3
every 500ms rd i2c34 0x03 2
every 500ms rd i2c35 0x03 2
@stop
log spk-aux-dapm.as complete; kernel already disabled PAs and amps
