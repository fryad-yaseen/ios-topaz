# Test the one sampled FS1815 control delta: Android playing BC=142b,
# iOS tone BC=1423. Write Android's observed value only during this boot.
@codec
tone 1000 5 3277 LR
@tone
i2c 34 0xbc 0x142b
i2c 35 0xbc 0x142b
rd i2c34 0xbc
rd i2c35 0xbc
rd i2c34 0x00
rd i2c35 0x00
every 500ms rd i2c34 0x03 2
every 500ms rd i2c35 0x03 2
@stop
log FS BC test complete
