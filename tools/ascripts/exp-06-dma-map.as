# Hypothesis: codec DMA channel mask 3 feeds no active RX channel on sapphire.
# Hear: a quiet tone if channel mask 2 selects the wired channel.
# Decide: graph open/prepare, as graph graph.dma_index, and FS 03/04 status.
# Run with the normal base; EXTRA_ARGS: none.
@codec
tone 1000 4 3277 LR
@graph
graph.dma_index 2
@tone
every 250ms rd rx 0x400 8
every 250ms rd rx 0x500 8
every 250ms rd i2c34 0x03 2
every 250ms rd i2c35 0x03 2
@stop
log DMA channel mask complete
