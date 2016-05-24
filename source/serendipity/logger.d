module serendipity.logger;

import coloredlogger : ColoredLogger;
import std.experimental.logger : LogLevel;
import std.stdio : stdout;

///
class SerendipityLogger: ColoredLogger
{
    ///
    this()
    {
        super(stdout, LogLevel.all);
    }
}
