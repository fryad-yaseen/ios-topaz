# Diagnostic: WCD937x HPHL and EAR share RX1/DP1 input.
# Listen with wired 3.5 mm headphones inserted before boot.
# Existing speaker graph/route stays on RX_1/AIF2; this probes WCD RX1
# and HPHL analog output, not Android's normal RX_0/AIF1 headphone route.
# Linux wcd937x.c: HPHL DAC PRE_PMU clears 30d9 bit7; no compander sets
# 30d3 bit5. HPHL PA PRE_PMU sets 3009 bit5; POST_PMU sets 313a bit1.
# Baselines from sapphire Android idle WCD dump: 30d9=99, 30d3=80,
# 313a=fe, 3009=0c. Speaker test has 3009=0c and 3465=13.
# HPHL volume field 20 (0x14) is the low-gain end of the inverted control.
@codec
tone 1000 5 1638 L
@tone
rd wcd 0x3009
rd wcd 0x30d3
rd wcd 0x30d9
rd wcd 0x313a
wcd 0x30d9 0x19
wcd 0x30d3 0xb4
wcd 0x313a 0xfc
wcd 0x3009 0x2c
delay 25
wcd 0x313a 0xfe
rd wcd 0x3009
rd wcd 0x30d3
rd wcd 0x30d9
rd wcd 0x313a
every 500ms rd wcd 0x3009
@stop
wcd 0x3009 0x0c
wcd 0x30d3 0x80
wcd 0x30d9 0x99
wcd 0x313a 0xfe
log HPHL RX1 probe complete
