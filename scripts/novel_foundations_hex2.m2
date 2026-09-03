-- novel_foundations_hex2.m2
-- Defines the 10 novel foundation types identified at hexagon count 2
-- not isomorphic to any known reference pasture.
-- Each can be verified against the corresponding matroid representative.

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

-- Class A: G = ZZ/10, eps = t^5
-- Relations: t + t^2 = 1, t^7 + t^7 = 1
PA = prunePasture pasture([t], "t+t^2, t^7+t^7, -t^5");

-- Class B: G = ZZ/10, eps = t^5
-- Relations: t + t = 1, t^7 + t^8 = 1
PB = prunePasture pasture([t], "t+t, t^7+t^8, -t^5");

-- Class C: G = ZZ/2 + ZZ^2, eps = eps
-- Relations: -1 + x1 = 1, x2^(-1) + x2^(-1) = 1
PC = prunePasture pasture([x1,x2], "-1+x1, x2^(-1)+x2^(-1)");

-- Class D: G = (ZZ/2)^2, eps = a (low-level construction)
-- Relations: ab + b = 1, 1 + 1 = 1
PD = prunePasture pasture(matrix{{2,0},{0,2}}, (ZZ^2)_{0}, {
    {(ZZ^2)_{0} + (ZZ^2)_{1}, (ZZ^2)_{1}},
    {map(ZZ^2,ZZ^1,0), map(ZZ^2,ZZ^1,0)}
});

-- Class G: G = trivial, eps = 1
-- Relations: 1 + t^2 = 1, t + 1 = 1
PG = prunePasture pasture([t], "1+t^2, t+1, -1");

-- Class J: G = ZZ/2 + ZZ/4, eps = b^2
-- Relations: b + b^2 = 1, -b + (-b) = 1
PJ = prunePasture pasture([b], "b+b^2, -b+-b, b^4");

-- Class K: G = ZZ/2, eps = eps
-- Relations: -1 + 1 = 1, -1 + (-1) = 1
PK = prunePasture pasture([], "-1+1, -1+-1");

-- Class M: G = ZZ/2, eps = 1
-- Relations: 1 + t = 1, 1 + 1 = 1
PM = prunePasture pasture([t], "1+t, 1+1, t^2, -1");

-- Class N: G = ZZ/3 + ZZ, eps = 1
-- Relations: s + s^2 = 1, s + s*t = 1
PN = prunePasture pasture([s,t], "s+s^2, s^3, s+s*t, -1");

-- Class O: G = ZZ/2 + ZZ^4, eps = eps (r3n11 only)
-- Relations: -x3 + x2*x3*x4^(-1) = 1, -x1^(-1)*x2 + x1^(-1)*x2*x3*x4^(-1) = 1
PO = prunePasture pasture([x1,x2,x3,x4], "-x3+x2*x3*x4^(-1), -x1^(-1)*x2+x1^(-1)*x2*x3*x4^(-1)");

-- print hexagon counts to verify
stderr << "=== Novel hex 2 foundation hexagon counts ===" << endl;
scan({("A",PA),("B",PB),("C",PC),("D",PD),("G",PG),("J",PJ),("K",PK),("M",PM),("N",PN),("O",PO)},
    (name, P) -> stderr << name << ": " << #P.hexagons << " hexagons" << endl
);
