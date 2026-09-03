#!/bin/bash
# submit_iso_r3n11.sh
# Submits one SLURM job per hex file for r3n11 isomorphism classification on Habrok
# Run on Habrok: chmod +x ~/submit_iso_r3n11.sh && ./submit_iso_r3n11.sh
# Input:  ~/r3n11_hex_{n}.txt, ~/r3n11_nonbases/r3n11_nonbases{i}.txt
#         /scratch/s5464102/r3n11_results/r3n11_foundation{i}.txt
# Output: ~/r3n11_iso_classes/r3n11_hex_{n}_classes.txt

mkdir -p ~/r3n11_iso_classes

for hexfile in $(ls ~/r3n11_hex_*.txt | sed 's/.*r3n11_hex_//' | sed 's/\.txt//' | sort -n | awk '{print "/home5/s5464102/r3n11_hex_" $1 ".txt"}'); do
    h=$(basename $hexfile .txt | sed 's/r3n11_hex_//')

    if [ -f ~/r3n11_iso_classes/r3n11_hex_${h}_classes.txt ]; then
        continue
    fi

    cat > ~/r3n11_iso_${h}.m2 << ENDM2
load "Matroids/foundations.m2"
E = toList(0..10);

prunePasture = F -> (
    G := prune F.multiplicativeGroup;
    new Pasture from {
        symbol multiplicativeGroup => G,
        symbol epsilon => F.epsilon,
        symbol hexagons => F.hexagons,
        symbol cache => new CacheTable
    }
);

foundationHash = F -> (
    G := prune F.multiplicativeGroup;
    eps := flatten entries F.epsilon;
    numZeroVecs := #select(flatten flatten F.hexagons, v -> flatten entries v == toList(#(flatten entries v):0));
    (G, eps, numZeroVecs)
);

areIsomorphicSafe = (F1, F2, timeout) -> (
    alarm timeout;
    result := try areIsomorphic(F1, F2) else (
        alarm 0;
        stderr << "areIsomorphic timed out" << endl;
        false
    );
    alarm 0;
    result
);

indices := apply(lines get "/home5/s5464102/r3n11_hex_${h}.txt", l -> value l);
stderr << "Processing hex ${h}: " << #indices << " foundations" << endl;

foundations := apply(indices, i -> (
    nb := value get concatenate(homeDirectory, "r3n11_nonbases/r3n11_nonbases", toString i, ".txt");
    M := matroid(E, nb, EntryMode=>"nonbases");
    F := prunePasture readFoundation(M, concatenate("/scratch/s5464102/r3n11_results/r3n11_foundation", toString i, ".txt"));
    scan(keys M.cache, k -> remove(M.cache, k));
    scan(keys F.cache, k -> remove(F.cache, k));
    collectGarbage();
    F
));
stderr << "Foundations loaded. Computing hashes..." << endl;

hashes := apply(#indices, i -> foundationHash foundations#i);
hashGroups := new MutableHashTable;
scan(#indices, i -> (
    hk := hashes#i;
    if not hashGroups#?hk then hashGroups#hk = {};
    hashGroups#hk = append(hashGroups#hk, i);
));
stderr << #keys hashGroups << " distinct hashes found." << endl;

classes := {};
scan(keys hashGroups, hk -> (
    group := hashGroups#hk;
    if #group == 1 then (
        classes = append(classes, {indices#(group#0)});
    ) else (
        remaining := group;
        while #remaining > 0 do (
            current := first remaining;
            currentClass := {indices#current};
            remaining = drop(remaining, 1);
            newRemaining := {};
            scan(remaining, j -> (
                if areIsomorphicSafe(foundations#current, foundations#j, 1800) then
                    currentClass = append(currentClass, indices#j)
                else
                    newRemaining = append(newRemaining, j);
            ));
            remaining = newRemaining;
            classes = append(classes, currentClass);
            stderr << "#classes: " << #classes << ", remaining: " << #remaining << endl;
        );
    );
));

stderr << "Done! " << #classes << " iso classes for hex ${h}" << endl;
outFile := openOut "/home5/s5464102/r3n11_iso_classes/r3n11_hex_${h}_classes.txt";
scan(classes, c -> outFile << toExternalString c << endl);
close outFile;

foundations = null;
hashes = null;
hashGroups = null;
classes = null;
collectGarbage();
collectGarbage();
ENDM2

    sbatch << ENDJOB
#!/bin/bash
#SBATCH --job-name=iso_hex_${h}
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=72:00:00
#SBATCH --output=/home5/s5464102/r3n11_iso_${h}.log
#SBATCH --error=/home5/s5464102/r3n11_iso_${h}.err
#SBATCH --partition=regular

module load Macaulay2/1.26.05-GCC-13.2.0
M2 --script /home5/s5464102/r3n11_iso_${h}.m2
ENDJOB

    echo "Submitted hex_${h}"

    # wait for job to finish before submitting next
    while [ $(squeue -u $USER | grep iso_hex | wc -l) -gt 0 ]; do
        sleep 60
    done
    echo "hex_${h} done, submitting next..."

done
echo "All iso jobs done!"
