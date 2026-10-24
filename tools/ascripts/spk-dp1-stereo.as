# Build18 speaker base. One hypothesis: DP1 mono channel packing differs.
# Match HPH DP1 channel mask3 at master AND slave, both banks.
# Retain speaker EAR/AUX routing and DP4. mmio is required for 32-bit words.
@codec
tone 1000 5 3277 LR
@graph
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
rx 0x180 0x50
rx 0x190 0x06
swrs 0x120 0x03
swrs 0x130 0x03
mmio 0x0a611124 0x03000003
mmio 0x0a611164 0x03000003
# Explicit bank0 then bank1 broadcast, so banked changes take effect.
mmio 0x0a610300 0x08ff0060
delay 10
rd swr 0x104c 1
mmio 0x0a610300 0x0fff0070
delay 10
rd swr 0x104c 1
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
swrs 0x120 0x01
swrs 0x130 0x01
mmio 0x0a611124 0x01000003
mmio 0x0a611164 0x01000003
mmio 0x0a610300 0x08ff0060
delay 10
mmio 0x0a610300 0x0fff0070
delay 10
log spk-dp1-stereo.as complete; kernel already disabled PAs and amps
