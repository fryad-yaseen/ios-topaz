# Hypothesis: PCM reaches AUX but the combined route masks the result.
# Hear: a quiet tone from the AUX-fed bottom speaker only.
# Decide: as tone rd i2c35 0x03 2 and i2c34 distinguish active amp.
# Run with the normal base; EXTRA_ARGS: none.
@codec
tone 1000 4 3277 R
@tone
rx 0x414 0xac
every 250ms rd i2c34 0x03 2
every 250ms rd i2c35 0x03 2
@stop
log AUX isolation complete
