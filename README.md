# Matroid Foundations Computation

Computational pipeline for computing and classifying foundations of matroids from three families, developed as part of a Master's thesis at the University of Groningen.

## Matroid Families

| Family | Rank | Elements | Total matroids | 
|---|---|---|---|
| r4n9 | 4 | 9 | 190,214 | 
| r3n10 | 3 | 10 | 10,037 | 
| r3n11 | 3 | 11 | 298,491 | 

## Requirements

- [Macaulay2](https://macaulay2.com/) v1.26.05 with Matroids package
- The foudations package: `load "Matroids/foundations.m2"`

## Pipeline

The computation proceeds in 5 steps:

### Step 1: Compute foundations
```
compute_foundations_r4n9.m2    -- Cloud VM
compute_foundations_r3n10.m2   -- Cloud VM
compute_foundations_r3n11.m2   -- Habrok HPC (SLURM)
```

### Step 2: Classify by hexagon count
```
classify_hex_r4n9.m2           -- Cloud VM
classify_hex_r3n10.m2          -- Cloud VM
classify_hex_r3n11.m2          -- Habrok HPC (SLURM)
```
After each script finishes, split into per-hex files:
```bash
awk '{print $1 > "r4n9_hex_" $2 ".txt"}' r4n9_hexcounts_all.txt
```

### Step 3: Isomorphism classification
```
iso_classes_r4n9.m2            -- Cloud VM (single session)
iso_classes_r3n10.m2           -- Cloud VM (single session)
submit_iso_r3n11.sh            -- Habrok HPC (one SLURM job per hex file)
```
Output: `r4n9_iso_classes/r4n9_hex_{n}_classes.txt` etc.
Each line is a Macaulay2 list `{i1, i2, ...}` of matroid indices in one isomorphism class.

### Step 4: Cross-family matching
```
cross_match_hex05.m2           -- Cloud VM
```
Matches isomorphism class representatives across the three families for hex counts 0–5.

### Step 5: Match against reference pastures
```
check_v_quotients.m2           -- Cloud VM
```
Checks hex 0–5 classes against 24 symmetry quotients of V, named pastures, finite fields, and supervisor-provided pastures.

## Key Functions

### prunePasture
Always call after `readFoundation` to remove redundant generators:
```macaulay2
prunePasture = F -> (
    G := prune F.multiplicativeGroup;
    new Pasture from {
        symbol multiplicativeGroup => G,
        symbol epsilon => F.epsilon,
        symbol hexagons => F.hexagons,
        symbol cache => new CacheTable
    }
);
```

### foundationHash
Pre-filter before `areIsomorphic` to avoid expensive calls:
```macaulay2
foundationHash = F -> (
    G := prune F.multiplicativeGroup;
    eps := flatten entries F.epsilon;
    numZeroVecs := #select(flatten flatten F.hexagons,
        v -> flatten entries v == toList(#(flatten entries v):0));
    (G, eps, numZeroVecs)
);
```

### areIsomorphicSafe
Timeout wrapper to prevent hanging:
```macaulay2
areIsomorphicSafe = (F1, F2, timeout) -> (
    alarm timeout;
    result := try areIsomorphic(F1, F2) else (alarm 0; false);
    alarm 0;
    result
);
```

## Infrastructure

- **Cloud VM**: `macaulay2-compute`, zone `europe-west3-c`, n2-custom-12, 32GB RAM
- **Habrok HPC**: `login1.hb.hpc.rug.nl`, SLURM scheduler
- **Storage**: Google Cloud Storage bucket `gs://macaulay2-results/`

## File Structure

```
scripts/
├── compute_foundations_r4n9.m2      Step 1: compute foundations
├── compute_foundations_r3n10.m2
├── compute_foundations_r3n11.m2
├── classify_hex_r4n9.m2             Step 2: classify by hex count
├── classify_hex_r3n10.m2
├── classify_hex_r3n11.m2
├── iso_classes_r4n9.m2              Step 3: isomorphism classification
├── iso_classes_r3n10.m2
├── submit_iso_r3n11.sh
├── cross_match_hex05.m2             Step 4: cross-family matching
├── check_v_quotients.m2             Step 5: reference matching
├── verify_iso_classes.m2            Sanity checks
├── novel_foundations_hex2.m2        Novel foundation definitions
└── novel_foundations_hex3.m2
```

## Reference

This work uses the [Matroids package for Macaulay2](https://github.com/dsambit/M2-Matroids) and the pasture/foundation framework of Baker and Lorscheid.
