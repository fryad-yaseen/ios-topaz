# Hypothesis: WCD EAR/AUX PA or RDAC latches are off despite powered amps.
# Hear: a quiet tone from either speaker after the output writes.
# Decide: as tone rd wcd and i2c status; any 03/04 transition isolates output stage.
# Run with the normal base; EXTRA_ARGS: none.
@codec
tone 1000 4 3277 LR
@tone
wcd 0x344e 0x04
wcd 0x344f 0x01
wcd 0x300a 0xc0
wcd 0x3128 0x80
rx 0x414 0x00
rx 0x514 0xfc
every 250ms rd wcd 0x3008 4
every 250ms rd wcd 0x3128 1
every 250ms rd i2c34 0x03 2
every 250ms rd i2c35 0x03 2
@stop
log WCD latch complete
