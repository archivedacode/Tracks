# Tracks
MTAudioProcessingTap with MPMediaItem

Utilises Swift for the Interface code, and Objective C for a minimal audio engine using the MTAudioProcessingTap to handle the fetching of PCM samples.

MTAudioProcessingTap provides a quick and easy'ish way to get access to the PCM samples from an MPMediaItem (a track from the iTunes library). Using this method allows for quick access to the left and right stereo samples directly, to then perform some processing such as filtering or DSP effects. Apple handles the heavy lifting on your part, you simply get handed a left and right sample in floating point.

As can be seen, nothing unusual happening on the left channel here ;)

This audio engine currently in use on the M10 Equalizer for iOS, and the latest and last versions of EQ10.
