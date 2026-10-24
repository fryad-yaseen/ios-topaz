# Read-only route sample during the kernel tone.
@codec
tone 1000 5 3277 LR
@tone
every 50ms rd rx 0x180 8
every 50ms rd rx 0x400 8
every 50ms rd rx 0x500 8
every 50ms rd swr 0x105c 4
every 50ms rd wcd 0x3008 4
every 50ms rd i2c34 0x03 2
every 50ms rd i2c35 0x03 2
@stop
log readback complete
