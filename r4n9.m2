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
