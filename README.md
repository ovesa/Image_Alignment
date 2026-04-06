# Image Alignment

A multi-step image registration workflow for aligning solar image sequences across multiple instruments and wavelengths at the Dunn Solar Telescope. Combines automated cross-correlation, calibration routines, and manual quality control to produce co-aligned, science-ready FITS image cubes used in published research.

Developed during my Ph.D. for multi-instrument, multi-wavelength data analysis. A full description of the procedure, including code modules, is documented in `Alignment Steps.txt`.

---

## Workflow Overview

```
Raw FITS Image Sequences (ROSA, Zyla, IBIS)
        │
        ▼
 Camera Orientation Correction    ← Air Force Target images, IDL ROTATE
        │
        ▼
 Plate Scale Calibration          ← dot grid fitting, find_dot_grid_spacing.pro
        │       ▲
        │       └── manual QC: interactive dot selection, repeated 3x per channel
        ▼
 Image Jitter Removal             ← sequential cross-correlation, xyoff.pro, shift_frac.pro
        │       ▲
        │       └── manual QC: flagging and re-adjusting bad frames
        ▼
 Inter-instrument Alignment       ← auto_align_images.pro, rotation + shift computation
        │       ▲
        │       └── manual QC: interactive feature matching between instruments
        ▼
 Transformation Application       ← plate scale, rotation, shifts applied to full sequences
        │
        ▼
 Co-aligned FITS Output           ← verified with blink_map
```

The workflow involves both automated and interactive steps. Plate scale calibration requires manually clicking on dot grid features; jitter removal requires visual inspection to flag bad frames; and inter-instrument alignment requires interactively selecting matched features between images. These manual steps reflect the realities of working with complex, heterogeneous instrument data.


## Overview

Aligning solar image sequences across different instruments and wavelengths requires correcting for differences in camera orientation, plate scale, image jitter from the adaptive optics system, and inter-instrument rotation. This repository contains the code and helper utilities used to perform that alignment in four steps.

---

## Technical Skills

- **Image registration:** cross-correlation, affine transformations (rotation, scaling, translation), sub-pixel shift estimation
- **Calibration:** plate scale fitting from dot grid patterns, orientation correction from calibration targets
- **Signal quality assessment:** manual frame flagging, adaptive cross-correlation box sizing, visual verification of co-alignment
- **Data I/O:** FITS file handling across large image sequences, SAV file I/O, binary camera file parsing (Python)
- **Languages:** IDL, Python (`numpy`, `matplotlib`, `astropy`)

---

## Instruments

| Instrument | Wavelengths | Plate Scale |
|---|---|---|
| ROSA | G-Band, Ca K, 4170 Å, 3500 Å | 0.06 arcsec/pixel |
| Zyla | Hα | 0.083 arcsec/pixel |
| IBIS | Ca 8542 Å, Hα 6563 Å | 0.097 arcsec/pixel |

---

## Alignment Procedure

### Step 1: Camera Orientation Correction
Each camera is mounted at a different physical orientation. Averaged Air Force Target images are used to determine the initial rotation needed to orient each channel to a common direction. ROSA channels (G-Band, 4170, 3500) share the same rotation, while Zyla and ROSA Ca K each require different corrections. Rotations are applied using IDL's `ROTATE` function (or `scipy.ndimage.rotate` in Python).

### Step 2: Plate Scale Calibration
Minor deviations from nominal plate scales introduce distortions that compound across instruments. Dot grid calibration images are used to compute accurate x- and y-plate scales for each channel using `find_dot_grid_spacing.pro`, which interactively fits a regular dot pattern and returns the pixel spacing and residual rotation. Measurements are repeated three times per channel and averaged.

### Step 3: Image Jitter Removal
The adaptive optics system can lose its reference lock, especially in quiet Sun observations, causing frame-to-frame jitter across thousands of images. A sequential cross-correlation scheme (`xyoff.pro`, `shift_frac.pro`) aligns each frame to the previous one. Frames with poor speckle reconstruction are identified by inspecting the computed shifts and manually re-adjusted using a different reference frame or a smaller cross-correlation box.

### Step 4: Inter-instrument Alignment
With jitter removed and plate scales corrected, ROSA and IBIS images are co-aligned using SolarSoft's `auto_align_images.pro`. This interactive code computes the rotation angle, residual plate scale, and spatial shifts by matching user selected features between instruments. The computed transformations are applied to the full image sequences and saved as FITS files. Alignment is verified visually by blinking co-temporal maps using SolarSoft's `blink_map`.

---
