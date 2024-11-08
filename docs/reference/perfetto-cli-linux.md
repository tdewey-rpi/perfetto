# PERFETTO(1)

## NAME

perfetto - capture traces

## DESCRIPTION

`perfetto` can be used in one of two modes:

__normal mode__
: the configuration is specified in a protocol buffer or text file. This allows
  for full customisation of collected traces.

__lightweight mode__
: all tracing options are supplied as commandline flags,
  but the available data sources are restricted to ftrace and atrace. This mode
  is similar to
  [`systrace`](https://developer.android.com/topic/performance/tracing/command-line).

## NORMAL MODE

The general syntax for using `perfetto` in *normal mode* is as follows:

```
 sudo tracebox --output FILE --txt --config CONFIG_FILE
```

Where example configuration files are provided under `/var/lib/perfetto/configs`

The following table lists the available options when using `perfetto` in
*normal* mode.

`-c`, `--config` _CONFIG_FILE_
:    Specifies the path to a configuration file. In normal mode, some
     configurations may be encoded in a configuration protocol buffer.
     This file must comply with the protocol buffer schema defined in AOSP
     [`trace_config.proto`](/protos/perfetto/config/trace_config.proto).
     You select and configure the data sources using the DataSourceConfig member
     of the TraceConfig, as defined in AOSP
     [`data_source_config.proto`](/protos/perfetto/config/data_source_config.proto).

`--txt`
:    Instructs `perfetto` to parse the config file as pbtxt. This flag is
     experimental, and it's not recommended that you enable it for production.

## LIGHTWEIGHT MODE

For ease of use, the `perfetto` package includes support for a subset of
configurations via command line arguments. On-device, these
configurations behave equivalently to the same configurations provided
by a *CONFIG_FILE* (see below).

The general syntax for using `perfetto` in *lightweight mode* is as follows:

```
 sudo tracebox [ --time TIMESPEC ] [ --buffer SIZE ] [ --size SIZE ]
    [ ATRACE_CAT | FTRACE_GROUP/FTRACE_NAME]...
```


The following table lists the available options when using `perfetto` in
*lightweight mode*.

`-t`, `--time` _TIME[s|m|h]_
:    Specifies the trace duration in seconds, minutes, or hours.
     For example, `--time 1m` specifies a trace duration of 1 minute.
     The default duration is 10 seconds.

`-b`, `--buffer` _SIZE[mb|gb]_
:    Specifies the ring buffer size in megabytes (mb) or gigabytes (gb).
     The default parameter is `--buffer 32mb`.

`-s`, `--size` _SIZE[mb|gb]_
:    Specifies the max file size in megabytes (mb) or gigabytes (gb).
     By default `perfetto` uses only in-memory ring-buffer.


This is followed by a list of event specifiers:

`FTRACE_GROUP/FTRACE_NAME`
:    Specifies the ftrace events you want to record a trace for.
     For example, the following command traces sched/sched_switch events:
     `sudo tracebox -t 10s --out FILE sched/sched_switch`

## GENERAL OPTIONS

The following table lists the available options when using `perfetto` in either
mode.

`-d`, `--background`
:    Perfetto immediately exits the command-line interface and continues
     recording your trace in background.

`-o`, `--out` _OUT_FILE_
:    Specifies the desired path to the output trace file, or `-` for stdout.
     `perfetto` writes the output to the file described in the flags above.
     The output format compiles with the format defined in
     [AOSP `trace.proto`](/protos/perfetto/trace/trace.proto).

`--query`
:     Queries the service state and prints it as human-readable text.

`--query-raw`
:     Similar to `--query`, but prints raw proto-encoded bytes of
      `tracing_service_state.proto`.

`-h`,  `--help`
:     Prints out help text for the named tool.


