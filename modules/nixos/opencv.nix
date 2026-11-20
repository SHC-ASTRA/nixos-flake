# opencv is the most expensive thing clucky builds, and CUDA keeps it out of every public
# cache, so it's worth not building it more times than we have to.
{
  nixpkgs.overlays = [
    (_final: prev: {
      opencv4 = prev.opencv4.override {
        # `opencv` and `python3Packages.opencv4` otherwise differ by one cmake flag, so
        #   anything using both compiles the whole CUDA library twice
        enablePython = true;
        # `doCheck` is off, so these only ever get compiled, never run
        runAccuracyTests = false;
      };
      # ffplay is the only thing that wants sdl & we don't need it for a rover
      ffmpeg = prev.ffmpeg.override {
        withSdl2 = false;
        buildFfplay = false;
      };
    })
  ];
}
