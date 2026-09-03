-- classify_hex_r4n9.m2
-- Classifies r4n9 foundations by hexagon count, producing one file per hexagon count
-- Run on Cloud VM: nohup M2 --script ~/classify_hex_r4n9.m2 > ~/classify_hex_r4n9.log 2>&1 &
-- Input:  ~/foundations/foundation{i}.txt
-- Output: ~/r4n9_hexcounts_all.txt  (lines: "index hexcount")
--         ~/r4n9_hex_{n}.txt         (one per hexcount, lines: matroid indices)

load "Matroids/foundations.m2"
r4n9 = allMatroids(9, 4);
out = openOut (homeDirectory | "r4n9_hexcounts_all.txt");

scan(#r4n9, i -> (
    fname := concatenate(homeDirectory, "foundations/foundation", toString i, ".txt");
    if fileExists fname then (
        try (
            M := r4n9#i;
            F := readFoundation(M, fname);
            h := #F.hexagons;
            out << i << " " << h << endl;
            flush out;
            scan(keys M.cache, k -> remove(M.cache, k));
            scan(keys F.cache, k -> remove(F.cache, k));
        ) else stderr << "Error at index " << i << endl;
    );
    collectGarbage();
    if i % 100 == 0 then stderr << "Processed " << i << " / " << #r4n9 << endl;
));
close out;

