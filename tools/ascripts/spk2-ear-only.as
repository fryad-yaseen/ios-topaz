# Partial handset-style EAR test, NOT a Receiver scene implementation.
# Receiver scene mapping is unresolved. FS34 retains Music; FS35 is off.
# Keep stereo graph/ring because build18 tone generator interleaves stereo.
@codec
tone 1000 5 16000 LR
@graph
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
rx 0x180 0x05
rx 0x190 0x06
# Disable AUX PA and amp, leave shared supplies and EAR alone.
wcd 0x3128 0x00
delay 7
wcd 0x3467 0x00
i2c 35 0x10 0x0001
i2c 35 0x11 0x0000
delay 10
# Handset XML RX volume84 is -18dB; EAR gain already 0dB.
rx 0x414 0xee
wcd 0x3450 0x00
every 500ms rd rx 0x180 5
every 500ms rd rx 0x400 6
every 500ms rd rx 0x500 6
every 500ms rd swr 0x104c 1
every 500ms rd swr 0x1424 3
every 500ms rd swr 0x1464 3
every 500ms rd swrs 0x420 8
every 500ms rd swrs 0x430 8
every 500ms rd wcd 0x3008 4
every 500ms rd wcd 0x30ef 2
every 500ms rd wcd 0x3128 1
every 500ms rd wcd 0x3408 8
every 500ms rd wcd 0x344e 3
every 500ms rd wcd 0x3465 3
every 500ms rd i2c34 0x00 5
every 500ms rd i2c35 0x00 5
@stop
log spk2 EAR-only done; Music scene retained, not exact handset
