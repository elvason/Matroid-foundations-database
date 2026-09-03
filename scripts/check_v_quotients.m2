-- check_v_quotients.m2
-- Checks hex 0-5 iso class representatives against 24 known reference pastures
-- (symmetry quotients of V, named pastures, finite fields, supervisor pastures)
-- Run on Cloud VM: nohup M2 --script ~/check_v_quotients.m2 > ~/check_v_quotients.log 2>&1 &
-- Output: ~/v_quotient_matches.txt

load "Matroids/foundations.m2"

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
    result := try areIsomorphic(F1, F2) else (alarm 0; false);
    alarm 0;
    result
);

-- symQuotients #1-24 (symmetry quotients of V)
symQuotients = hashTable{
    1  => pasture([x1,x2,x3,x4,x5],"x1+x2*x5, x2+x1*x3, x3+x2*x4, x4+x3*x5, x5+x4*x1"),
    2  => pasture([x1,x2,x4], "x1+x2, x2*x4+1, x4+1, x1*x4+1, -1"),
    3  => pasture([x1,x2,x4], "x2-x1*x2, x2*x4-x2, x1*x4+x2^(-2)"),
    4  => pasture([x1,x2], "x1^2+x2, -x1^2-x1, x1^3"),
    5  => pasture([x1,x3], "x3-x1*x3, x1-x1^2*x3, x1*x3^(-1)+x1*x3^(-1), -x1^2*x3^2"),
    6  => specificPasture "G",
    7  => pasture([x1,x2], "x2+x1*x2, x1^2+x2^(-2),-1"),
    8  => pasture([x1], "x1^3+x1^2, x1+x1, x1^2+x1^2, -1"),
    9  => pasture([x1,x4], "x1+1, x4+1,x1*x4+1, -1"),
    10 => specificPasture "D" ** specificPasture "K",
    13 => pasture([x1,x2], "x1^2+x2, -x1^2-x1, x1^3"),
    14 => pasture(GF 4),
    15 => specificPasture "K",
    16 => specificPasture "G",
    17 => pasture(GF 5),
    19 => specificPasture "K",
    20 => foundation uniformMatroid(2, 4),
    21 => specificPasture "H",
    22 => specificPasture "D",
    23 => specificPasture "F2",
    24 => specificPasture "F3"
};

-- supervisor pastures (F_A.3.x with 3 hexagons)
supervisorPastures = {
    ("FA316", pasture([x,y], "x+1, y+1, x*y+1")),
    ("FA318", pasture([x,y], "x-1, y-x, x^2-y")),
    ("FA319", pasture([x,y,z], "y-x, z-y, y^2+x*z")),
    ("GF13",  pasture GF 13),
    ("GF17",  pasture GF 17)
};

-- combine all references
referencePastures = apply(keys symQuotients, k -> (toString k, prunePasture symQuotients#k)) |
                   apply(supervisorPastures, (name, P) -> (name, prunePasture P));

r4n9 = allMatroids(9, 4);
fileLines_r3n10 = lines get (homeDirectory | "r3n10_nonbases.txt");
E_r3n10 = toList(0..9);
E_r3n11 = toList(0..10);

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

outFile = openOut (homeDirectory | "v_quotient_matches.txt");

checkFamily = (familyName, classFile, loadFn) -> (
    if not fileExists classFile then return;
    classes := apply(lines get classFile, l -> value l);
    stderr << "=== Checking " << familyName << ": " << #classes << " classes ===" << endl;
    scan(classes, cl -> (
        i := cl#0;
        F := loadFn i;
        scan(referencePastures, (name, P) -> (
            if areIsomorphicSafe(F, P, 60) then (
                outFile << familyName << " rep " << i << " ~ " << name << endl;
                flush outFile;
                stderr << familyName << " rep " << i << " ~ " << name << endl;
            );
        ));
        collectGarbage();
    ));
);

scan(toList(0..5), h -> (
    checkFamily("r4n9_hex"  | toString h, homeDirectory | "r4n9_iso_classes/r4n9_hex_"   | toString h | "_classes.txt", loadFoundation_r4n9);
    checkFamily("r3n10_hex" | toString h, homeDirectory | "r3n10_iso_classes/r3n10_hex_" | toString h | "_classes.txt", loadFoundation_r3n10);
    checkFamily("r3n11_hex" | toString h, homeDirectory | "r3n11_iso_classes/r3n11_hex_" | toString h | "_classes.txt", loadFoundation_r3n11);
));

close outFile;
stderr << "Done!" << endl;
