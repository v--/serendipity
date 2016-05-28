module serendipity.synth.noise;

double generateCauchyDistRandom(double median, double variance)
{
    import std.math : tan, PI;
    import std.random : uniform01;
    return median + variance * tan(PI * (uniform01() - 0.5));
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

    auto whiteNoise = generate!(generateCauchyDistRandom).take(n).array().fft();
    auto numberOfUniquePoints = n / 2;
    auto inverseVector = iota(1, numberOfUniquePoints + 1).array().map!((a) => sqrt(cast(double)a));

    for (auto i = 0; i < numberOfUniquePoints; i++)
        whiteNoise[i] /= inverseVector[i];

    for (auto i = numberOfUniquePoints; i < n; i++)
    {
        whiteNoise[i].re = whiteNoise[n - 1 - i].re;
        whiteNoise[i].im = -whiteNoise[n - 1 - i].im;
    }

    auto pinkNoise = whiteNoise.inverseFft().map!((a) => a.re);
    auto mean = pinkNoise.fold!((a, b) => a + b) / n;
    auto pinkNoiseNormalized = pinkNoise.map!((a) => a - mean);
    auto pinkNoiseRms = pinkNoiseNormalized.fold!((a, b) => a + b ^^ 2).sqrt();
    return pinkNoiseNormalized.map!((a) => a / pinkNoiseRms).array();
}

/*
unittest
{
    import std.stdio;
    import std.algorithm : map;
    writeln(generatePinkNoise(16).map!(a => cast(int)(64 + a * 64)));
}
*/
