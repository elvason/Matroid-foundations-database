-- classify_hex_r3n10.m2
-- Classifies r3n10 foundations by hexagon count
-- Run on Cloud VM: nohup M2 --script ~/classify_hex_r3n10.m2 > ~/classify_hex_r3n10.log 2>&1 &
-- Input:  ~/r3n10_nonbases.txt, ~/r3n10_results/r3n10_foundation{i}.txt
-- Output: ~/r3n10_hexcounts_all.txt, ~/r3n10_hex_{n}.txt

load "Matroids/foundations.m2"
fileLines = lines get (homeDirectory | "r3n10_nonbases.txt");
E = toList(0..9);
out = openOut (homeDirectory | "r3n10_hexcounts_all.txt");

scan(toList(0..<#fileLines), i -> (
    fname := concatenate(homeDirectory, "r3n10_results/r3n10_foundation", toString i, ".txt");
    if fileExists fname then (
        try (
            nb := value replace("\\[", "{", replace("\\]", "}", fileLines#i));
            M := matroid(E, nb, EntryMode=>"nonbases");
            F := readFoundation(M, fname);
            h := #F.hexagons;
            out << i << " " << h << endl;
            flush out;
            scan(keys M.cache, k -> remove(M.cache, k));
            scan(keys F.cache, k -> remove(F.cache, k));
        ) else stderr << "Error at index " << i << endl;
    );
    collectGarbage();
    if i % 100 == 0 then stderr << "Processed " << i << " / " << #fileLines << endl;
));
close out;
