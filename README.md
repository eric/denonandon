# Denon and on

A simple tool to ensure that the power state on Zone 2 of a Denon reciever
matches the Main Zone.

## Why?

Denon receivers have the ability to listen for AirPlay and automatically
turn on when it receives a stream. When this happens, it turns on the Main
Zone and starts playing, but Zone 2 stays in it's previous state.

I have not found a configuration setting to ensure that the Zone 2 power
state stays the same as the Main Zone, so this tool polls the Denon
HTTP API every 3 seconds and ensures that the Zone 2 state matches
the Main Zone.

## Why not use telnet?

Newer Denon receivers speak a protocol over telnet, but I found that it
was less reliable than the HTTP interface.

The HTTP interface is not documented, but by reviewing the javascript
that is used by the web interface, it was easy to find the relevant
commands.

## How do you run it?

Assuming the name of your stereo is "stereo", you can use:

```
  $ bundle exec bin/denonandon stereo.local
```