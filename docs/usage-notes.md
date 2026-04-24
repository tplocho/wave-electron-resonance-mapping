# Usage Notes

## Main script
The core script is:

- `matlab/matlab_code.m`

## User choices
When the script runs, it prompts for:

1. **r-mode selection**
   - full radial scan
   - fixed radius
   - predefined q-surface cases
   - custom q-target

2. **density profile selection**
   - parabolic
   - exponential
   - pedestal

3. **CSV output filename**

## Key scan dimensions
The script scans across combinations of:
- radial position `r`
- poloidal angle `theta`
- toroidal magnetic field `B0`
- launch angle `phi`
- frequency band

## Output behavior
The script writes resonance roots to CSV and can print live rows to the MATLAB console.

## Practical note
Because the script performs nested parameter scans, runtime and output size depend strongly on the selected ranges and settings in the script header.
