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
        );

        return result;
    }

    string device;
    uint rate;
}
