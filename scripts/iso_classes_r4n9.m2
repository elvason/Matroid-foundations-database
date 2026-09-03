-- iso_classes_r4n9.m2
-- Classifies r4n9 foundations into isomorphism classes, one hex count at a time
-- Run on Cloud VM: nohup M2 --script ~/iso_classes_r4n9.m2 > ~/iso_classes_r4n9.log 2>&1 &
-- Input:  ~/r4n9_hex_{n}.txt, ~/foundations/foundation{i}.txt
-- Output: ~/r4n9_iso_classes/r4n9_hex_{n}_classes.txt
--         Each line: {i1, i2, ...} = list of matroid indices in one isomorphism class

load "Matroids/foundations.m2"
stderr << "Loading allMatroids(9,4)..." << endl;
r4n9 = allMatroids(9, 4);
stderr << "Loaded " << #r4n9 << " matroids." << endl;

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

makeDirectory (homeDirectory | "r4n9_iso_classes");

hexFiles := sort apply(select(readDirectory homeDirectory, f -> match("^r4n9_hex_.*\\.txt$", f)), f -> (
    h := value replace("r4n9_hex_|\\.txt", "", f);
    (h, f)
));

scan(hexFiles, (h, fname) -> (
    outFile := homeDirectory | "r4n9_iso_classes/r4n9_hex_" | toString h | "_classes.txt";
    if fileExists outFile then (
        stderr << "Skipping hex " << h << " (already done)" << endl;
        return;
    );
    hexPath := homeDirectory | fname;
    indices := apply(lines get hexPath, l -> value l);
    stderr << "Processing hex " << h << ": " << #indices << " foundations" << endl;

    foundations := apply(indices, i -> (
        M := r4n9#i;
        F := prunePasture readFoundation(M, concatenate(homeDirectory, "foundations/foundation", toString i, ".txt"));
        scan(keys M.cache, k -> remove(M.cache, k));
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

    stderr << "Done! " << #classes << " iso classes for hex " << h << endl;
    f := openOut outFile;
    scan(classes, c -> f << toExternalString c << endl);
    close f;

    foundations = null;
    hashes = null;
    hashGroups = null;
    classes = null;
    collectGarbage();
    collectGarbage();
));
stderr << "All hex files processed!" << endl;
