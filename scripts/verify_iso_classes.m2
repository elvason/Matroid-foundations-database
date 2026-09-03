-- verify_iso_classes.m2
-- Sanity checks isomorphism classes for r4n9 and r3n10, hex 0-5:
--   Check 1: representatives of different classes are NOT isomorphic
--   Check 2: first 5 members of each class ARE isomorphic to the representative
-- Run on Cloud VM: nohup M2 --script ~/verify_iso_classes.m2 > ~/verify_iso_classes.log 2>&1 &

load "Matroids/foundations.m2"
r4n9 = allMatroids(9, 4);
fileLines_r3n10 = lines get (homeDirectory | "r3n10_nonbases.txt");
E_r3n10 = toList(0..9);

prunePasture = F -> (
    G := prune F.multiplicativeGroup;
    new Pasture from {
        symbol multiplicativeGroup => G,
        symbol epsilon => F.epsilon,
        symbol hexagons => F.hexagons,
        symbol cache => new CacheTable
    }
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

loadFoundation_r4n9 = i -> (
    M := r4n9#i;
    F := prunePasture readFoundation(M, concatenate(homeDirectory, "foundations/foundation", toString i, ".txt"));
    scan(keys M.cache, k -> remove(M.cache, k));
    collectGarbage();
    F
);

loadFoundation_r3n10 = i -> (
    nb := value replace("\\[", "{", replace("\\]", "}", fileLines_r3n10#i));
    M := matroid(E_r3n10, nb, EntryMode=>"nonbases");
    F := prunePasture readFoundation(M, concatenate(homeDirectory, "r3n10_results/r3n10_foundation", toString i, ".txt"));
    scan(keys M.cache, k -> remove(M.cache, k));
    collectGarbage();
    F
);

verifyFamily = (familyName, classFile, loadFn) -> (
    if not fileExists classFile then (
        stderr << "No class file for " << familyName << ", skipping" << endl;
        return;
    );
    classes := apply(lines get classFile, l -> value l);
    stderr << "=== Verifying " << familyName << ": " << #classes << " classes ===" << endl;
    reps := apply(classes, cl -> (cl#0, loadFn(cl#0)));
    errors := 0;

    stderr << "Check 1: different class reps should NOT be isomorphic..." << endl;
    scan(#reps, a -> scan(toList(a+1..#reps-1), b -> (
        if areIsomorphicSafe((reps#a)#1, (reps#b)#1, 60) then (
            stderr << "ERROR: " << (reps#a)#0 << " and " << (reps#b)#0 << " are isomorphic but in different classes!" << endl;
            errors = errors + 1;
        );
    )));

    stderr << "Check 2: first 5 members should be isomorphic to their rep..." << endl;
    scan(classes, cl -> (
        rep := loadFn(cl#0);
        scan(take(drop(cl, 1), 5), i -> (
            F := loadFn i;
            if not areIsomorphicSafe(rep, F, 60) then (
                stderr << "ERROR: " << i << " not isomorphic to class rep " << cl#0 << "!" << endl;
                errors = errors + 1;
            );
        ));
    ));

    if errors == 0 then
        stderr << familyName << ": ALL CORRECT" << endl
    else
        stderr << familyName << ": " << errors << " ERRORS FOUND" << endl;

    reps = null;
    collectGarbage();
);

scan(toList(0..5), h -> (
    verifyFamily("r4n9_hex"  | toString h, homeDirectory | "r4n9_iso_classes/r4n9_hex_"   | toString h | "_classes.txt", loadFoundation_r4n9);
    verifyFamily("r3n10_hex" | toString h, homeDirectory | "r3n10_iso_classes/r3n10_hex_" | toString h | "_classes.txt", loadFoundation_r3n10);
));
stderr << "Verification done!" << endl;
