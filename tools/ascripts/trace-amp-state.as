# Compare amp preset readback with Android playing dumps while a valid tone runs.
# Android: 34/35 reg 19=000b/000e, 21=0100, 28=0000,
# 59=0821, bc=142b, status 03/04=000d/7580.
@codec
tone 1000 5 3277 LR
@tone
rd i2c34 0x19
rd i2c35 0x19
rd i2c34 0x21
rd i2c35 0x21
rd i2c34 0x28
rd i2c35 0x28
rd i2c34 0x59
rd i2c35 0x59
rd i2c34 0xbc
rd i2c35 0xbc
rd wcd 0x30ef 2
rd wcd 0x31c3
every 500ms rd i2c34 0x03 2
every 500ms rd i2c35 0x03 2
@stop
log amp state trace complete
