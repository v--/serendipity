real generateCauchyDistRandom(real median, real variance)
{
    import std.math : tan, PI;
    import std.random : uniform;
    return median + variance * tan(PI * (uniform(0, 1) - 0.5));
}

real[] generatePinkNoise(uint n)
{
    import std.algorithm : fold, map;
    import std.math : sqrt;
    import std.numeric : inverseFft, fft;
    import std.range : iota, generate;

    auto m = n % 2 ? n + 1 : n;
    auto whiteNoise = generate!(generateCauchyDistRandom)(0, 1).take(m).fft();
    auto numberOfUniquePoints = m / 2 + 1;
    auto inverseVector = iota(1, numberOfUniquePoints + 1).map!((a) => sqrt(cast(real)a));

    for (auto i = 1; i <= numberOfUniquePoints; i++)
        whiteNoise[i] /= inverseVector[i];

    for (auto i = numberOfUniquePoints + 1, j = m / 2; i <= m && j >= 2; i++, j--)
    {
        whiteNoise[i].re = whiteNoise[j].re;
        whiteNoise[i].im = -whiteNoise[j].im;
    }

    auto pinkNoise = whiteNoise.inverseFft().map!((a) => a.re);
    auto mean = pinkNoise.fold!((a, b) => a + b);
    pinkNoise = pinkNoise.map!((a) => a - mean);
    auto pinkNoiseRms = pinkNoise.fold!((a, b) => a + b ^^ 2).sqrt();
    pinkNoise = pinkNoise.map!((a) => a / pinkNoiseRms);
    return pinkNoise.array();
}

unittest
{
    writeln(generatePinkNoise(10));
}
