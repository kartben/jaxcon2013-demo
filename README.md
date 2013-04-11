jaxcon2013-demo
===============

This repository contains the source code of the JAX 2013 keynote.

led-controller
--------------

<code>led-controller</code> is a Mihini app that controls an RGB LED strip.
Whenver an M3DA command <code>pushPixel</code> is sent to the asset <code>leds</code>, a new pixel is pushed in front of the others

twitterbot.rb
-------------

<code>twitterbot.rb</code> is a Ruby app using the Twitter streaming API to parse a twitter feed and fire M3DA pushPixel commands according to specific policies.
