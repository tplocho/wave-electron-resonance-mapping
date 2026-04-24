# Wave-Electron Resonance Mapping for Tokamak Plasmas

MATLAB code for parametric mapping of the electron-cyclotron resonance condition in tokamak plasmas, developed from an Integrated Master's diploma thesis at the National Technical University of Athens (NTUA).

## What this repository is
This repository contains a polished public presentation of the thesis-stage code used to study wave-electron resonance structure for control-oriented ECRH/ECCD scenarios in tokamak plasmas.

The code performs systematic scans over tokamak geometry, plasma-profile assumptions, magnetic field, launch angle, and frequency, then exports resonance-root results to CSV for downstream analysis.

## Scientific context
Electron-cyclotron heating and current drive depend strongly on where resonant interaction is supported inside the plasma and how that support shifts with actuator and equilibrium parameters. This code provides a lightweight resonance-mapping layer for structured parametric exploration relevant to ECRH/ECCD and NTM-control studies.

## Core capabilities
- radial scan or fixed-radius / q-surface evaluation
- selectable density-profile models
- parameter scans over `theta`, `B0`, `phi`, and frequency
- resonance-root solving inside a prescribed EC frequency band
- CSV export of resonance results

## Repository structure
```text
wave-electron-resonance-mapping/
├─ README.md
├─ LICENSE
├─ CITATION.cff
├─ matlab/
│  └─ matlab_code.m
├─ docs/
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
4. Follow the interactive prompts for:
   - radial-selection mode
   - density-profile selection
   - output CSV filename
5. Inspect the generated CSV output.

## Inputs and outputs
A concise overview of the script inputs, scan dimensions, and output schema is available in:
- `docs/usage-notes.md`
- `examples/sample-output-schema.md`

## Thesis relation
This repository is based on thesis work titled:

**Parametrization of the Wave-Electron Interaction with Applications to the Suppression of Instabilities in Thermonuclear Plasma**  
Theotokis Plochoros  
National Technical University of Athens, 2025

The thesis PDF is not bundled in this repository. The code is presented here as the public software artifact.

## Citation
If you use or reference this repository, please prefer the archived software citation:

**Plochoros, Theotokis (2025). _Wave-Electron Resonance Mapping Code for Tokamak Plasmas_. Zenodo.**  
DOI: `10.5281/zenodo.17664754`  
URL: https://zenodo.org/records/17664754

See `CITATION.cff` for machine-readable metadata.

## Continuity note
This repository is the cleaned public continuation of the earlier thesis-code release associated with:
- legacy GitHub repository: `theoplo/SAMPS_Plochoros_Thesis_Code`
- archived Zenodo software release: `10.5281/zenodo.17664754`

## Scope and limitations
This is a focused thesis-code release, not a full production simulation framework. It should be interpreted within the modeling assumptions and scope of the underlying thesis work.

## License
MIT License.
