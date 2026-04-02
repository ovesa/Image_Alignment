# Image Alignment

A collection of IDL and Python codes for aligning solar image sequences acquired with the ROSA and IBIS instruments at the Dunn Solar Telescope. Developed during my Ph.D. for multi-instrument, multi-wavelength data analysis.

A full description of the alignment procedure is documented in `Alignment Steps.txt`.

---

## Overview

Aligning solar image sequences across different instruments and wavelengths requires correcting for differences in camera orientation, plate scale, image jitter from the adaptive optics system, and inter-instrument rotation. This repository contains the codes and helper utilities used to perform that alignment in four steps.

---

## Instruments

| Instrument | Wavelengths | Plate Scale |
|---|---|---|
| ROSA | G-Band, Ca K, 4170 Å, 3500 Å | 0.06 arcsec/pixel |
| Zyla | Hα | 0.083 arcsec/pixel |
| IBIS | Ca 8542 Å, Hα 6563 Å | 0.097 arcsec/pixel |

---

## Alignment Procedure

### Step 1 — Determine Rotation Angle
Each camera is mounted at a different orientation. Averaged Air Force Target images are used to determine the initial rotation needed to orient each channel to a common direction before any further alignment. ROSA channels (G-Band, 4170, 3500) share the same rotation, while Zyla and Ca K require different rotations.

### Step 2 — Determine Plate Scale
Minor variations from nominal plate scales can distort the alignment. Dot grid calibration images are used to compute accurate plate scales in x and y for each channel using Kevin Reardon's `find_dot_grid_spacing.pro`, which interactively fits a grid of dots and returns the pixel spacing and any residual rotation.

### Step 3 — Remove Image Jitter
The adaptive optics system can lose its reference lock, particularly in quiet Sun observations, causing frame-to-frame image jitter. A sequential cross-correlation scheme aligns each frame to the previous one. Frames with poor speckle reconstruction are manually re-adjusted using a different reference frame or a smaller cross-correlation box.

### Step 4 — Align ROSA to IBIS
With jitter removed and plate scales corrected, ROSA and IBIS images can be co-aligned using SolarSoft's `auto_align_images.pro`. This interactive code computes the rotation angle, residual plate scale, and spatial shifts needed to match ROSA to the IBIS field of view. Final transformations are applied to the full image sequences and saved as FITS files. Alignment is verified by blinking co-temporal maps using SolarSoft's `blink_map`.

---
