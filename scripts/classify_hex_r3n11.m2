-- classify_hex_r3n11.m2
-- Classifies r3n11 foundations by hexagon count
-- Run on Habrok via SLURM (see instructions file)
-- Input:  ~/r3n11_nonbases/r3n11_nonbases{i}.txt, /scratch/s5464102/r3n11_results/r3n11_foundation{i}.txt
-- Output: ~/r3n11_hexcounts_all.txt, ~/r3n11_hex_{n}.txt

load "Matroids/foundations.m2"
out = openOut "/home5/s5464102/r3n11_hexcounts_all.txt";

scan(toList(1..298491), i -> (
    fname := concatenate("/scratch/s5464102/r3n11_results/r3n11_foundation", toString i, ".txt");
    if fileExists fname then (
        try (
            nb := value get concatenate(homeDirectory, "r3n11_nonbases/r3n11_nonbases", toString i, ".txt");
            M := matroid(toList(0..10), nb, EntryMode=>"nonbases");
            F := readFoundation(M, fname);
            h := #F.hexagons;
            out << i << " " << h << endl;
            flush out;
        ) else stderr << "Error at index " << i << endl;
    );
    if i % 1000 == 0 then stderr << "Processed " << i << " / 298491" << endl;
));
close out;
stderr << "Done! Now run: awk '{print $1 > \"/home5/s5464102/r3n11_hex_\" $2 \".txt\"}' ~/r3n11_hexcounts_all.txt" << endl;
