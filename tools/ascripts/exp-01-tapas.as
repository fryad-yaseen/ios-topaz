# Hypothesis: the upstream tapas AUX path can make sound on sapphire.
# Hear: a quiet 1 kHz tone from the AUX-fed speaker if the common path works.
# Decide: tone heard, and as tone rd i2c35 0x03 2 changes from 0000,0180.
# Run with the minimal base described in the research note; EXTRA_ARGS: none.
@codec
tone 1000 4 3277 LR
@tone
every 250ms rd i2c35 0x03 2
every 250ms rd rx 0x500 8
@stop
log tapas path complete
