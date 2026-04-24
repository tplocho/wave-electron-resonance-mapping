# Sample Output Schema

The thesis script writes CSV rows with the following columns:

1. `r (m)`
2. `theta (deg)`
3. `B0 (T)`
4. `phi (deg)`
5. `w/2pi (GHz)`
6. `w/wc`
7. `R (m)`
8. `D_root`

## Interpretation
- `r`, `theta`, `B0`, and `phi` describe the parameter-space location
- `w/2pi (GHz)` is the solved frequency in GHz
- `w/wc` is the normalized resonance frequency ratio
- `R (m)` is the corresponding geometric major-radius value
- `D_root` is the resonance-root residual quantity written by the script

## Example row shape
```text
0.500000,45.000000,5.000000,-10.000000,140.000000,0.987654,6.350000,1.23e-10
```
