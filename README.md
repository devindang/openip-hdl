# openip-hdl

### Descriptions:

Open IP in Hardware Description Language.

- supported language: Verilog HDL, VHDL
- reach me at balddevin@outlook.com

### Catalogs:

| Order | Module Name                                                  | Descriptions                                                 |
| ----- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1     | [cordic_log](https://github.com/devindang/openip-hdl/tree/main/cordic_log) | Calculate natural logarithm using hyperbolic CORDIC algorithm. |
| 2     | [nr_fft](https://github.com/devindang/openip-hdl/tree/main/nr_fft) | Calculate Fast Fourier Transform (FFT) for NR bandwidth.     |
| 3     | [booth_mul](https://github.com/devindang/openip-hdl/tree/main/booth_mul) | 64x64 Booth-Wallace multiplier, pipelined to 3 stages*.      |
| 4     | [srt_div](https://github.com/devindang/openip-hdl/tree/main/srt_div) | 64-bits radix2-SRT, radix-4 SRT division*.                   |

* : The design documents can be found [HERE](https://github.com/devindang/dv-cpu-rv/blob/main/docs/dv-cpu-doc.pdf).

### Scripts:

| Order | Scripts Name                                                 | Descriptions                                                 |
| ----- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1     | [vsim.pl](https://github.com/devindang/openip-hdl/blob/main/perl_scripts/vsim.pl) | Perl scripts for extracting Mentor Modelsim list information. [Usage](https://www.cnblogs.com/devindd/articles/17426494.html) |
| 2     | [clean.pl](https://github.com/devindang/openip-hdl/blob/main/perl_scripts/clean.pl) | Perl scripts for cleaning temp files produced by Modelsim, VCS, Verdi, to use, place this file into your root directory of your project, an effective perl interpreter is required. |
| 3     | [makefile](https://github.com/devindang/openip-hdl/blob/main/perl_scripts/makefile) | Makefile for execute compilation, simulation, invoke Verdi, and make clean. |
| 4     | [clean.sh](https://github.com/devindang/openip-hdl/blob/main/perl_scripts/clean.sh) | Shell scripts to clean Modelsim simulation temp files, place this file into your vsim/ directory, clean.pl will detect this file to perform clean. |

### License

Copyright (c) 2023, devindang

The software is licensed under [3-clause BSD License](https://opensource.org/license/bsd-3-clause/).
