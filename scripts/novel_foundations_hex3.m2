-- novel_foundations_hex3.m2
-- Defines the 19 novel foundation types identified at hexagon count 3
-- not isomorphic to any known reference pasture or finite field.

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

-- hex3-2: G = ZZ/2 + ZZ/6, eps = (1,0)
Phex3_2 = prunePasture pasture(matrix{{2,0},{0,6}}, (ZZ^2)_{0}, {
    {(ZZ^2)_{0} + 2*(ZZ^2)_{1}, (ZZ^2)_{0} + (ZZ^2)_{1}},
    {(ZZ^2)_{0} + 3*(ZZ^2)_{1}, 2*(ZZ^2)_{1}},
    {(ZZ^2)_{0},                 2*(ZZ^2)_{1}}
});

-- hex3-4: G = ZZ/2 + ZZ^2, eps = (1,0,0)
Phex3_4 = prunePasture pasture([x1,x2], "-1+-1, 1-x2, -x1+1");

-- hex3-5: G = ZZ/2 + ZZ^2, eps = (1,0,0)
Phex3_5 = prunePasture pasture([x1,x2], "x2-1, -x1+1, 1-x1*x2");

-- hex3-6: G = ZZ/6 + ZZ^2, eps = (3,0,0)
Phex3_6 = prunePasture pasture([s,x1,x2], "s^(-1)+s, s^4+s^4*x2, s^4+s*x1, s^6, -s^3");

-- hex3-8: G = ZZ/2 + ZZ^2, eps = (1,0,0)
Phex3_8 = prunePasture pasture([x1,x2], "1+1, 1-x1, 1+x2");

-- hex3-9: G = ZZ/2 + ZZ, eps = (1,0)
Phex3_9 = prunePasture pasture([x], "1+x^(-1), -1+-1, -x^(-2)+1");

-- hex3-10: G = trivial (unpruned: ZZ), eps = 0
Phex3_10 = prunePasture pasture(map(ZZ^1,ZZ^0,0), map(ZZ^1,ZZ^1,0), {
    {map(ZZ^1,ZZ^1,0), -2*(ZZ^1)_{0}},
    {map(ZZ^1,ZZ^1,0),   -(ZZ^1)_{0}},
    {3*(ZZ^1)_{0},       3*(ZZ^1)_{0}}
});

-- hex3-11: G = ZZ/12, eps = t^6
Phex3_11 = prunePasture pasture([t], "t^4+t^9, t^10+t^2, t^5-1, t^12, -t^6");

-- hex3-13: G = trivial (unpruned: ZZ^2), eps = (0,0)
Phex3_13 = prunePasture pasture(map(ZZ^2,ZZ^0,0), map(ZZ^2,ZZ^1,0), {
    {map(ZZ^2,ZZ^1,0), map(ZZ^2,ZZ^1,0)},
    {-(ZZ^2)_{0},      -(ZZ^2)_{0}},
    {-(ZZ^2)_{1},      -(ZZ^2)_{1}}
});

-- hex3-14: G = ZZ/2 + ZZ, eps = (1,0)
Phex3_14 = prunePasture pasture([x], "x^2+1, -x+1, x^3+1");

-- hex3-15: G = ZZ/2 + ZZ, eps = (1,0)
Phex3_15 = prunePasture pasture([x], "1-1, 1+x, -1+x");

-- hex3-16: G = trivial (unpruned: ZZ), eps = 0
Phex3_16 = prunePasture pasture(map(ZZ^1,ZZ^0,0), map(ZZ^1,ZZ^1,0), {
    {map(ZZ^1,ZZ^1,0), map(ZZ^1,ZZ^1,0)},
    {-(ZZ^1)_{0},      map(ZZ^1,ZZ^1,0)},
    {map(ZZ^1,ZZ^1,0), -2*(ZZ^1)_{0}}
});

-- hex3-17: G = ZZ/4 + ZZ, eps = (2,0)
Phex3_17 = prunePasture pasture([s,x], "s+s^2, -s*x^(-1)+s^2*x^(-1), s^2+x, s^4, -s^2");

-- hex3-18: G = ZZ/10 + ZZ, eps = (5,0)
Phex3_18 = prunePasture pasture([t,u], "t^7*u^(-1)+t*u^(-1), t^8*u^(-1)+t^3, t^6*u+t^9*u^(-1), t^10, -t^5");

-- hex3-19: G = ZZ/4 + ZZ, eps = (2,0)
Phex3_19 = prunePasture pasture([s,x], "s^3+s^2, s*x+1, x+1, s^4, -s^2");

-- hex3-20: G = ZZ/16, eps = t^8 (r3n11 only)
Phex3_20 = prunePasture pasture([t], "t^5+t, t^9+t^14, t^6+t^6, t^16, -t^8");

-- hex3-21: G = ZZ/16, eps = t^8 (r3n11 only)
Phex3_21 = prunePasture pasture([t], "t^14+t, t^13+t^9, t^10+t^8, t^16, -t^8");

-- hex3-23: G = (ZZ/2)^2, eps = (1,0) (r3n11 only)
Phex3_23 = prunePasture pasture(matrix{{2,0},{0,2}}, (ZZ^2)_{0}, {
    {(ZZ^2)_{0},       (ZZ^2)_{0} + (ZZ^2)_{1}},
    {map(ZZ^2,ZZ^1,0), (ZZ^2)_{0} + (ZZ^2)_{1}},
    {map(ZZ^2,ZZ^1,0), (ZZ^2)_{0}}
});

-- hex3-24: G = ZZ/2 + ZZ, eps = (1,0) (r3n11 only)
Phex3_24 = prunePasture pasture([x], "-x-1, -x+x^2, x^(-1)-1");

-- print hexagon counts to verify
stderr << "=== Novel hex 3 foundation hexagon counts ===" << endl;
scan({
    ("hex3-2",  Phex3_2),  ("hex3-4",  Phex3_4),  ("hex3-5",  Phex3_5),
    ("hex3-6",  Phex3_6),  ("hex3-8",  Phex3_8),  ("hex3-9",  Phex3_9),
    ("hex3-10", Phex3_10), ("hex3-11", Phex3_11), ("hex3-13", Phex3_13),
    ("hex3-14", Phex3_14), ("hex3-15", Phex3_15), ("hex3-16", Phex3_16),
    ("hex3-17", Phex3_17), ("hex3-18", Phex3_18), ("hex3-19", Phex3_19),
    ("hex3-20", Phex3_20), ("hex3-21", Phex3_21), ("hex3-23", Phex3_23),
    ("hex3-24", Phex3_24)
}, (name, P) -> stderr << name << ": " << #P.hexagons << " hexagons" << endl);
