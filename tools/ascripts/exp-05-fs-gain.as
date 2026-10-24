# Hypothesis: FS1815 gain, rather than codec routing, hides a present analog tone.
# Hear: a quiet tone from either speaker with modest gain increase.
# Decide: as tone rd i2c34/35 0x18 and 0x03; status change without sound means amp-side issue.
# Run with the normal base; EXTRA_ARGS: none. Stop if either amp reports a fault.
@codec
tone 1000 4 3277 LR
@tone
i2c 34 0x18 0x000f
i2c 35 0x18 0x000f
rd i2c34 0x18
rd i2c35 0x18
every 250ms rd i2c34 0x03 2
every 250ms rd i2c35 0x03 2
@stop
log FS gain complete
