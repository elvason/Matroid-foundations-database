-- cross_match_hex05.m2
-- Matches isomorphism class representatives across r4n9, r3n10, r3n11 for hex 0-5
-- Run on Cloud VM: nohup M2 --script ~/cross_match_hex05.m2 > ~/cross_match_hex05.log 2>&1 &
-- Output: ~/cross_family_matches_hex05.txt

load "Matroids/foundations.m2"
r4n9 = allMatroids(9, 4);
fileLines_r3n10 = lines get (homeDirectory | "r3n10_nonbases.txt");
E_r3n10 = toList(0..9);
E_r3n11 = toList(0..10);

prunePasture = F -> (
    G := prune F.multiplicativeGroup;
    new Pasture from {
        symbol multiplicativeGroup => G,
        symbol epsilon => F.epsilon,
        symbol hexagons => F.hexagons,
        symbol cache => new CacheTable
    }
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

loadFoundation_r3n11 = i -> (
    nb := value get concatenate(homeDirectory, "r3n11_nonbases/r3n11_nonbases", toString i, ".txt");
    M := matroid(E_r3n11, nb, EntryMode=>"nonbases");
    F := prunePasture readFoundation(M, concatenate(homeDirectory, "scratch/s5464102/r3n11_results/r3n11_foundation", toString i, ".txt"));
    scan(keys M.cache, k -> remove(M.cache, k));
    collectGarbage();
    F
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

outFile = openOut (homeDirectory | "cross_family_matches_hex05.txt");

scan(toList(0..5), h -> (
    stderr << "=== Checking hex " << h << " ===" << endl;

    r4n9File  := homeDirectory | "r4n9_iso_classes/r4n9_hex_"   | toString h | "_classes.txt";
    r3n10File := homeDirectory | "r3n10_iso_classes/r3n10_hex_" | toString h | "_classes.txt";
    r3n11File := homeDirectory | "r3n11_iso_classes/r3n11_hex_" | toString h | "_classes.txt";

    has4n9  := fileExists r4n9File;
    has3n10 := fileExists r3n10File;
    has3n11 := fileExists r3n11File;

    if not (has4n9 or has3n10 or has3n11) then return;

    r4n9Reps  := if has4n9  then apply(lines get r4n9File,  l -> (value l)#0) else {};
    r3n10Reps := if has3n10 then apply(lines get r3n10File, l -> (value l)#0) else {};
    r3n11Reps := if has3n11 then apply(lines get r3n11File, l -> (value l)#0) else {};

    stderr << "r4n9: " << #r4n9Reps << " classes, r3n10: " << #r3n10Reps << " classes, r3n11: " << #r3n11Reps << " classes" << endl;

    r4n9Fs  := apply(r4n9Reps,  i -> loadFoundation_r4n9(i));
    r3n10Fs := apply(r3n10Reps, i -> loadFoundation_r3n10(i));
    r3n11Fs := apply(r3n11Reps, i -> loadFoundation_r3n11(i));

    if has4n9 and has3n10 then
        scan(#r4n9Reps, a -> scan(#r3n10Reps, b -> (
            if areIsomorphicSafe(r4n9Fs#a, r3n10Fs#b, 60) then (
                outFile << "hex" << h << ": r4n9[" << r4n9Reps#a << "] ~ r3n10[" << r3n10Reps#b << "]" << endl;
                flush outFile;
                stderr << "Match: r4n9[" << r4n9Reps#a << "] ~ r3n10[" << r3n10Reps#b << "]" << endl;
            );
        )));

    if has4n9 and has3n11 then
        scan(#r4n9Reps, a -> scan(#r3n11Reps, b -> (
            if areIsomorphicSafe(r4n9Fs#a, r3n11Fs#b, 60) then (
                outFile << "hex" << h << ": r4n9[" << r4n9Reps#a << "] ~ r3n11[" << r3n11Reps#b << "]" << endl;
                flush outFile;
                stderr << "Match: r4n9[" << r4n9Reps#a << "] ~ r3n11[" << r3n11Reps#b << "]" << endl;
            );
        )));

    if has3n10 and has3n11 then
        scan(#r3n10Reps, a -> scan(#r3n11Reps, b -> (
            if areIsomorphicSafe(r3n10Fs#a, r3n11Fs#b, 60) then (
                outFile << "hex" << h << ": r3n10[" << r3n10Reps#a << "] ~ r3n11[" << r3n11Reps#b << "]" << endl;
                flush outFile;
                stderr << "Match: r3n10[" << r3n10Reps#a << "] ~ r3n11[" << r3n11Reps#b << "]" << endl;
            );
        )));

    r4n9Fs  = null;
    r3n10Fs = null;
    r3n11Fs = null;
    collectGarbage();
));

close outFile;
stderr << "Cross-family matching done!" << endl;
