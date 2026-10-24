# Patch 1034, AUDIO_BASE must include sapphire_hph=1 (replaces speaker base).
# 1 kHz, 5 seconds, peak 1638/32767; kernel RX -18 dB, analog gain code 12.
@codec
tone 1000 5 1638 LR
@graph
# Android CODEC_DMA LPAIF_RXTX RX_0, stereo channel mask 3.
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
log HPH stereo route readback
every 500ms rd wcd 0x3008 4
every 500ms rd wcd 0x30c9 2
every 500ms rd wcd 0x30d1 8
every 500ms rd wcd 0x30d9 4
every 500ms rd wcd 0x3098 2
every 500ms rd wcd 0x313a 1
every 500ms rd wcd 0x3408 8
every 500ms rd wcd 0x344e 1
every 500ms rd wcd 0x3465 2
every 500ms rd rx 0x180 8
every 500ms rd rx 0x400 6
every 500ms rd rx 0x480 6
every 500ms rd swr 0x104c 4
every 500ms rd swr 0x1124 3
every 500ms rd swr 0x1164 3
every 500ms rd swrs 0x120 8
every 500ms rd swrs 0x130 8
@stop
rd wcd 0x3008 4
rd wcd 0x3465 2
rd swr 0x104c 4
log HPH tone stopped and supplies down
