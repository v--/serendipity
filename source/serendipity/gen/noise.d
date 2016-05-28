module serendipity.noise;

double generateCauchyDistRandom(double median, double variance)
{
    import std.math : tan, PI;
    import std.random : uniform;
    return median + variance * tan(PI * (uniform(0, 1) - 0.5));
}

double generateCauchyDistRandom()
{
    return generateCauchyDistRandom(0, 1);
}

double[] generatePinkNoise(uint n)
{
    import std.algorithm : fold, map;
    import std.array : array;
    import std.math : sqrt;
    import std.numeric : inverseFft, fft;
    import std.range : iota, generate, take;

    auto m = n % 2 ? n + 1 : n;
    auto whiteNoise = generate!(generateCauchyDistRandom).take(m).array().fft();
    auto numberOfUniquePoints = m / 2 + 1;
    auto inverseVector = iota(1, numberOfUniquePoints + 1).map!((a) => sqrt(cast(double)a));

    for (auto i = 1; i <= numberOfUniquePoints; i++)
        whiteNoise[i] /= inverseVector[i];

    for (auto i = numberOfUniquePoints + 1, j = m / 2; i <= m && j >= 2; i++, j--)
    {
        whiteNoise[i].re = whiteNoise[j].re;
        whiteNoise[i].im = -whiteNoise[j].im;
    }

    auto pinkNoise = whiteNoise.inverseFft().map!((a) => a.re);
    auto mean = pinkNoise.fold!((a, b) => a + b);
    auto pinkNoiseNormalized = pinkNoise.map!((a) => a - mean);
    auto pinkNoiseRms = pinkNoiseNormalized.fold!((a, b) => a + b ^^ 2).sqrt();
    return pinkNoiseNormalized.map!((a) => a / pinkNoiseRms).array();
}
