-- compute_foundations_r3n10.m2
-- Computes and saves foundations for all r3n10 matroids (rank 3, 10 elements)
-- Run on Cloud VM: nohup M2 --script ~/compute_foundations_r3n10.m2 > ~/compute_foundations_r3n10.log 2>&1 &
-- Input:  ~/r3n10_nonbases.txt
-- Output: ~/r3n10_results/r3n10_foundation{i}.txt

load "Matroids/foundations.m2"
fileLines = lines get (homeDirectory | "r3n10_nonbases.txt");
E = toList(0..9);
stderr << "Loaded " << #fileLines << " nonbases" << endl;
makeDirectory (homeDirectory | "r3n10_results");

scan(toList(0..<#fileLines), i -> (
    fname := concatenate(homeDirectory, "r3n10_results/r3n10_foundation", toString i, ".txt");
    if fileExists fname then return;
    try (
        nb := value replace("\\[", "{", replace("\\]", "}", fileLines#i));
        M := matroid(E, nb, EntryMode=>"nonbases");
        saveFoundation(M, fname);
        scan(keys M.cache, k -> remove(M.cache, k));
    ) else stderr << "Error at index " << i << endl;
    collectGarbage();
    if i % 100 == 0 then stderr << "Processed " << i << " / " << #fileLines << endl;
));
stderr << "Done!" << endl;
