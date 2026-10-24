# Build18 speaker base. One hypothesis: supplies need real ordered edges,
# rather than final-state Android writes. Replay v3 CLS_AB EAR/HPH supplies
# with both speaker PAs off. Keep HPH PAs off; retain speaker DP1/DP4.
# Script delay granularity is ms, so 1ms exceeds upstream 100/500us waits.
@codec
tone 1000 5 3277 LR
@graph
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
rx 0x180 0x50
rx 0x190 0x06
wcd 0x300a 0x40
wcd 0x3128 0x00
delay 7
wcd 0x3465 0x00
wcd 0x3467 0x00
# RX bias remains; clear regulator bit1 and default bit2, buck/flyback off.
wcd 0x3008 0x01
delay 1
wcd 0x30a8 0x7b
wcd 0x30af 0xb0
delay 1
wcd 0x3099 0x02
wcd 0x3098 0x1c
wcd 0x30a5 0xeb
wcd 0x3008 0x41
delay 1
wcd 0x30af 0xf0
delay 1
wcd 0x30c7 0xaa
delay 1
wcd 0x3008 0xc1
delay 1
wcd 0x3098 0x3a
delay 1
wcd 0x3009 0x0c
# EAR-specific flyback, gain path and PA events, no HPH PGA enable.
wcd 0x30a4 0x4a
wcd 0x344e 0x04
wcd 0x344f 0x01
wcd 0x300b 0x92
wcd 0x3465 0x13
wcd 0x3467 0x05
wcd 0x300a 0xc0
delay 6
wcd 0x3128 0x80
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
log spk-supply-rearm.as complete; kernel already disabled PAs and amps
