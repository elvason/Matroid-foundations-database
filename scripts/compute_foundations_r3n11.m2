-- compute_foundations_r3n11.m2
-- Computes and saves foundations for all r3n11 matroids (rank 3, 11 elements)
-- Run on Habrok via SLURM (see instructions file)
-- Input:  ~/r3n11_nonbases/r3n11_nonbases{i}.txt  (one file per matroid)
-- Output: /scratch/s5464102/r3n11_results/r3n11_foundation{i}.txt

load "Matroids/foundations.m2"
E = toList(0..10);
makeDirectory "/scratch/s5464102/r3n11_results";

scan(toList(1..298491), i -> (
    fname := concatenate("/scratch/s5464102/r3n11_results/r3n11_foundation", toString i, ".txt");
    if fileExists fname then return;
    try (
        nb := value get concatenate(homeDirectory, "r3n11_nonbases/r3n11_nonbases", toString i, ".txt");
        M := matroid(E, nb, EntryMode=>"nonbases");
        saveFoundation(M, fname);
        scan(keys M.cache, k -> remove(M.cache, k));
    ) else stderr << "Error at index " << i << endl;
    collectGarbage();
    if i % 1000 == 0 then stderr << "Processed " << i << " / 298491" << endl;
));
stderr << "Done!" << endl;
