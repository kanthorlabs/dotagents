# tinkerbox plugin contract

A plugin is a directory with `main.py`.
The runner sends the input on stdin and reads the output from stdout.
A plugin reads its settings from `TINKERBOX_*` environment variables.
