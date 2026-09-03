-- compute_foundations_r4n9.m2
-- Computes and saves foundations for all r4n9 matroids (rank 4, 9 elements)
-- Run on Cloud VM: nohup M2 --script ~/compute_foundations_r4n9.m2 > ~/compute_foundations_r4n9.log 2>&1 &
-- Output: ~/foundations/foundation{i}.txt for each matroid index i

load "Matroids/foundations.m2"
r4n9 = allMatroids(9, 4);
stderr << "Loaded " << #r4n9 << " matroids" << endl;
makeDirectory (homeDirectory | "foundations");

scan(#r4n9, i -> (
    fname := concatenate(homeDirectory, "foundations/foundation", toString i, ".txt");
    if fileExists fname then return;
    M := r4n9#i;
    try (
        saveFoundation(M, fname);
        stderr << "Saved " << i << endl;
    ) else stderr << "Failed at index " << i << endl;
    scan(keys M.cache, k -> remove(M.cache, k));
    collectGarbage();
    if i % 100 == 0 then stderr << "Processed " << i << " / " << #r4n9 << endl;
));
stderr << "Done!" << endl;
