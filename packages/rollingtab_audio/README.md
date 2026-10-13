# RollingTAB audio

Internal continuous SoundFont scheduler with Web Audio and macOS PCM sinks. Adapted from the author's RollingPod SoundFont/output approach; see the root attribution. It imports no sibling project source or services. Queue targets are roughly 60 ms. Browser position follows AudioContext; native position is estimated from PCM buffer reports and monotonic time. Long UI stalls can exhaust the queue. Production builds disable opt-in diagnostic controls.
