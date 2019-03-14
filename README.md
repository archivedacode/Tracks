# Tracks
MTAudioProcessingTap with MPMediaItem

Utilises Swift for the Interface code, and Objective C for a minimal audio engine using the MTAudioProcessingTap to handle the fetching of PCM samples.

MTAudioProcessingTap provides a quick and easy'ish way to get access to the PCM samples from an MPMediaItem (the representative item for a track from the iTunes library). The only slight downside to the MTAudioProcessingTap in my experience, is that its not quite as efficient as I'd like it to be, which can interfere with performance on slower devices.
