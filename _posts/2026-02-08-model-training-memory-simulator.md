---
layout: post
title: Model Training Memory Simulator
author: czheo
---

<style>
  /* Widen only this page so the simulator can stay in desktop layout. */
  .wrapper {
    max-width: 1280px;
  }
  .oom-sim-frame {
    width: 100%;
    height: min(88vh, 980px);
    min-height: 680px;
    border: 1px solid #ddd;
  }
  @media (max-width: 900px) {
    .oom-sim-frame {
      height: 78vh;
      min-height: 560px;
    }
  }
</style>

<iframe
  class="oom-sim-frame"
  src="/oom-sim.html"
  loading="lazy">
</iframe>

## What This Visualizes

This simulator models a simplified training input pipeline as three stages:

1. Data loading into a CPU-side prefetch queue (often pinned host memory).
2. Host-to-device transfer into a GPU-side VRAM backlog queue.
3. GPU compute consuming queued batches.

Each stage has a throughput and each queue has a capacity. The key idea is that memory pressure is created by **mismatch between rates**, not just by one parameter in isolation.

## Tradeoffs It Tries To Show

1. Larger prefetch can improve utilization, but it increases pinned RAM usage.
2. Faster loading helps only if transfer and compute can keep up.
3. Faster transfer helps only if data is available and compute can drain VRAM.
4. Larger VRAM backlog capacity can smooth bursts, but it can also increase VRAM residency.
5. Bigger batch size raises memory footprint everywhere at once (CPU queue, transfer payload, GPU queue).

## Practical Reading Guide

1. If prefetch queue fills and pinned memory saturates, reduce prefetch depth, loader rate, or batch size.
2. If the VRAM backlog queue fills and VRAM saturates, reduce backlog depth or batch size, or speed up compute.
3. If transfer is starved, the loader is too slow for the downstream pipeline.
4. Stable throughput comes from balancing all stages, not maximizing any single slider.

This is a first-order mental model for input-pipeline pressure during training. In real systems, total VRAM also includes relatively stable components (weights, gradients, optimizer state) plus activation/workspace effects.
