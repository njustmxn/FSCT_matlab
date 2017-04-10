## Fast Scale-adaptive Correlation Tracking
 

----------


#### **USAGE:**

1. Download the [OTB1.0](http://cvlab.hanyang.ac.kr/tracker_benchmark/datasets.html). You can download all the sequences or the specific one.
2. Unzip the sequences to a specific path. For example, D:\Dataset\Car1
3. Modify the variable basePath in the m-file "FSCT.m" to you dataset path.
4. Then press F5 directly to run the demo.

**Platform: windows x64, matlab2010a or later**

----------

#### **NOTE:**

Our paper:
> 马晓楠, 刘晓利, 李银伢. 自适应尺度的快速相关滤波跟踪算法[J]. 计算机辅助设计与图形学学报. 2017, 29(3), 450-458.


If you want to use these code, please cite our paper.


----------


#### **FILES:**

The following files are composed by njustmxn@163.com. Some methods are 
inspired by Joao F. Henriques's KCF source code.

> 
chooseImgSeq.m
FSCT.m
gaussLabel.m
imgPatch.m
loadImgSeqInfo.m
logpolar.m
lptform.m
patch2pattern.m

The following files come from other researcher's open source code.
> 
MxArray.hpp
MxArray.cpp
mexResize.cpp
opencv_core242.dll
opencv_imgproc242.dll

The following files are part of [Piotr's Toolbox](http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html), and are provided for
convenience only:
> 
fhog.m
gradientMex.mexw64


You are encouraged to get the full version of this excellent library, at which point they can be safely deleted.
> 
Copyright (c) 2012, Piotr Dollar
All rights reserved.
> 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 
> 
1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 
> 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> 
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.

