# Probe a second codec DMA index and a swapped channel map.
@codec
tone 1000 5 3277 LR
@graph
graph.dma_index 2
graph.chmap 0x102
graph.port 2
@tone
every 50ms rd rx 0x400 8
every 50ms rd swr 0x1124 2
@stop
log DMA variant complete
