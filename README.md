# Wave-Electron Resonance Mapping for Tokamak Plasmas

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17664754.svg)](https://doi.org/10.5281/zenodo.17664754)

MATLAB code for parametric mapping of the electron-cyclotron resonance condition in tokamak plasmas, developed in the context of an Integrated Master's diploma thesis at the National Technical University of Athens (NTUA).

## Overview
The repository contains a MATLAB implementation for scanning the electron-cyclotron resonance condition across prescribed tokamak geometry, plasma-profile, magnetic-field, launch-angle, and frequency settings, with resonance-root results written to CSV for downstream analysis.

## Main capabilities
- radial scan or fixed-radius / q-surface evaluation
- selectable density-profile models
- parameter scans over `theta`, `B0`, `phi`, and frequency
- resonance-root solving inside a prescribed EC frequency band
- CSV export of resonance results

## Repository contents
```text
wave-electron-resonance-mapping/
├─ README.md
├─ LICENSE
├─ CITATION.cff
├─ matlab/
│  └─ matlab_code.m
├─ docs/
│  ├─ thesis-abstract.md
│  ├─ thesis-context.md
│  ├─ usage-notes.md
│  └─ usage-notes-original.txt
├─ examples/
│  └─ sample-output-schema.md
└─ .gitignore
```

## Running the code
1. Open MATLAB.
2. Navigate to the repository root.
3. Run `matlab/matlab_code.m`.
4. Follow the interactive prompts for radial mode, density profile, and output filename.
5. Inspect the generated CSV output.

## Inputs and outputs
Supporting notes are available in:
- `docs/thesis-abstract.md`
- `docs/thesis-context.md`
- `docs/usage-notes.md`
- `examples/sample-output-schema.md`

## Thesis context
The repository is associated with the thesis:

**Parametrization of the Wave-Electron Interaction with Applications to the Suppression of Instabilities in Thermonuclear Plasma**  
Theotokis Plochoros  
National Technical University of Athens, 2025

The full thesis text is not bundled in the repository.

## Citation
If you use or reference the code, please cite the archived software release:

**Plochoros, Theotokis (2025). _Wave-Electron Resonance Mapping Code for Tokamak Plasmas_. Zenodo.**  
DOI: `10.5281/zenodo.17664754`  
URL: https://zenodo.org/records/17664754

See `CITATION.cff` for machine-readable metadata.

## Project continuity
This repository continues the earlier thesis-code release associated with:
- `theoplo/SAMPS_Plochoros_Thesis_Code`
- Zenodo DOI `10.5281/zenodo.17664754`

## License
MIT License.
