module serendipity.settings;

struct SerendipitySettings
{
    static fromArgs(string[] args)
    {
        import std.getopt : getopt, config;
        SerendipitySettings result;

        getopt(args,
            config.required, "device", &result.device,
            config.required, "rate", &result.rate,
            "depth", &result.depth,
        );

        return result;
    }

    string device;
    uint rate;
    uint depth = 16;
}
