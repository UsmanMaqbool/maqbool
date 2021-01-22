
<h1 align="center">
  <p align="center">MAQBOOL</p>
  <a href="https://usmanmaqbool.github.io/why-so-deep"><img src="https://usmanmaqbool.github.io/assets/images/maqbool/maqbool.png" alt="why-so-deep" style="height: 164px;"></a>
  

</h1>
<p align="center">Multiple AcuQitation of perceptiBle regiOns for priOr Learning </p>
<p align="center">
  ⭐️ If you like MAQBOOL, give it a star on GitHub! ⭐️
  <br>
  <a href="https://twitter.com/MUsmanMBhutta"><img src="https://img.shields.io/twitter/follow/MUsmanMBhutta.svg?style=social" alt="Twitter Follow" /></a>
  <a href="#license"><img src="https://img.shields.io/github/license/sourcerer-io/hall-of-fame.svg?colorB=ff0000"></a>
</p>

Documentation is avaiable at [project website](https://usmanmaqbool.github.io/why-so-deep). Please follow the installation guide below.

## To Compare the Results

$$
\overbrace{
    \underbrace{vd16}_\text{real} \_
    \underbrace{tokyoTM\_}_\text{trained on} to
    \underbrace{\_tokyo247}_\text{tested on}\_
    \underbrace{maqbool}_\text{method}\_
    \underbrace{DT\_100}_\text{distance tree size (MAQBOOL only)}\_
    \underbrace{512}_\text{feature dimension}.
    \underbrace{dat}
   }^\text{file name}
$$
## To Run
```
run Maqbool_main.m
```
Change the setting in `m_setting.m` and set datasets path for NetVLAD in `localpaths.m`


## Installation
Install Support (Ubuntu 20.04, Matlab 2019b, Cuda Driver 10.1)

```
git clone https://github.com/UsmanMaqbool/Maqbool.git
```
### Install Prerequisites
```
cd Maqbool/ && mkdir 3rd-party-support
```
clone these repositiories [Matconvnet](#Matconvnet), [NetVLAD](Matconvnet), [Edge Boxes](Matconvnet) and [Edges Boxes Toolbox](Matconvnet).




#### Matconvnet
```
git clone https://github.com/vlfeat/matconvnet.git
```
[Ful Instuctions to install matconvnet](https://www.vlfeat.org/matconvnet/install/)

For centos OS, please use previous version `wget https://github.com/vlfeat/matconvnet/archive/v1.0-beta18.zip`

```matlab
cd 3rd-party-support/matconvnet
addpath matlab 
vl_compilenn('enableGpu', true)
```

Possible Errors:

- Also you need to disable the `C++11` flag in `.matlab/R2017a/mex_C++_glnxa64.xml` to `C++0x` 
- if there is NVCC error, try installing Cudatoolkit
`sudo apt install nvidia-cuda-toolkit`
- if there is GCC version issue, try switching using update-alternatives. You can follow the tutorial below `Downgrade to GCC 7/8`

    [Useful guide to install specific version of gcc](https://unix.stackexchange.com/questions/410723/how-to-install-a-specific-version-of-gcc-in-kali-linux)

    GCC 7 is available on linux it can be installed as follow :
    ```
    sudo apt install g++-7 gcc7 g++-8 gcc8
    ```    

    To switch between gcc7 or gcc8

    ```
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 1 --slave /usr/bin/g++ g++ /usr/bin/g++-8
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 2 --slave /usr/bin/g++ g++ /usr/bin/g++-9
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 1 --slave /usr/bin/g++ g++ /usr/bin/g++-7
    sudo update-alternatives --config gcc

    # sample output:

    Selection |   Path       |     Priority  | Status
    ---------|------------------------|----------------|-----------
    * 0     |       /usr/bin/gcc-9 |  2     |    auto mode
    1       |     /usr/bin/gcc-6  | 2        | manual mode
    2       |     /usr/bin/gcc-7  | 1      |   manual mode
          Selection |   Path       |     Priority  | Status

    Press <enterto keep the current choice[*], or type selection number: 2
    ```  

#### NetVLAD
```
git clone https://github.com/Relja/netvlad.git
```
Download the databases file (tokyo247.mat) and set the correct dsetSpecDir in localPaths.m and also add paths.libReljaMatlab 

#### Edge Boxes
```
git clone https://github.com/zchrissirhcz/edges
```
Not official edges, but fixed error for matlab > 2017
in matlab 'cd edges' and 'run linux_startup.m' and replace the 'edgeBoxes.m' with our edges boxes (to get the edges images as well')

#### Edge Boxes ToolBox
```
git clone https://github.com/zchrissirhcz/toolbox.git
```
in matlab 'cd toolbox' and 'run linux_startup.m'

```