# Hypothesis: PCM reaches EAR but the combined route masks the result.
# Hear: a quiet tone from the EAR-fed top speaker only.
# Decide: as tone rd i2c34 0x03 2 and i2c35 distinguish active amp.
# Run with the normal base; EXTRA_ARGS: none.
@codec
tone 1000 4 3277 L
@tone
rx 0x514 0xac
every 250ms rd i2c34 0x03 2
every 250ms rd i2c35 0x03 2
@stop
log EAR isolation complete
