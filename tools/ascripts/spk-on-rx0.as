# Build 18. Headphone test proved DMA RX_0 -> AIF1 (RX0/RX1) carries PCM.
# Speaker path normally uses DMA RX_1 -> AIF2 (RX2/RX3). Feed the speaker
# interpolators from the proven RX_0 stream instead: INT0 <- RX0, INT2 <- RX1.
# Run with the normal speaker base (no sapphire_hph). Hear: tone from speakers.
@codec
tone 1000 5 3277 LR
@graph
graph.intf 1
graph.port 1
graph.dma_index 3
@tone
rd rx 0x180 1
rd rx 0x190 1
rx 0x180 0x50
rx 0x190 0x06
rd rx 0x180 1
rd rx 0x190 1
every 500ms rd i2c34 0x03 2
every 500ms rd i2c35 0x03 2
every 500ms rd wcd 0x3008 4
@stop
log speaker on RX_0 complete
